--
--  File Name:         TbStream_SendGetAllAsync1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Validates Stream Model Independent Transactions
--      Send, Get, Check, 
--      WaitForTransaction, GetTransactionCount
--      GetAlertLogID, GetErrorCount, 
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    01/2022   2022.01    Initial revision
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2022 by SynthWorks Design Inc.  
--  
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--  
--      https://www.apache.org/licenses/LICENSE-2.0
--  
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--  
architecture SendGetAllAsync1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbStream_SendGetAllAsync1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for simulation elaboration/initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    -- AlertIf(GetAffirmCount < 1, "Test is not Self-Checking"); -- Now handled by EndOfTestReports
    
    TranscriptClose ; 
--    AffirmIfTranscriptsMatch(PATH_TO_VALIDATED_RESULTS) ;
    
    -- Expecting two check errors at 128 and 256
    EndOfTestReports(ExternalErrors => (0, 0, 0)) ; 
    std.env.stop ;
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  TransmitterProc : process
    variable CoverID : CoverageIdType ; 
  begin

    wait until nReset = '1' ;  
    WaitForClock(StreamTxRec, 1, 2) ; 
    
-- Send and Get    
    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
      SendAsync( StreamTxRec, 1, X"0000_0000" + I ) ; 
    end loop ; 

-- Send and Check    
    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
      SendAsync( StreamTxRec, 1, X"0000_1000" + I ) ; 
    end loop ; 

-- SendBurst and GetBurst    
    log("Send 32 word burst") ;
    for I in 1 to 32 loop 
      Push( StreamTxRec(1).BurstFifo, X"0000_2000" + I  ) ; 
    end loop ; 
    SendBurstAsync(StreamTxRec, 1, 32) ;

-- SendBurst and CheckBurst    
    log("Send 32 word burst") ;
    for I in 1 to 32 loop 
      Push( StreamTxRec(1).BurstFifo, X"0000_3000" + I ) ; 
    end loop ; 
    SendBurstAsync(StreamTxRec, 1, 32) ;

-- SendBurst and CheckBurst    
    log("SendBurstVector 13 word burst") ;
    SendBurstVectorAsync(StreamTxRec, 1, 
        (X"0000_4001", X"0000_4003", X"0000_4005", X"0000_4007", X"0000_4009",
         X"0000_4011", X"0000_4013", X"0000_4015", X"0000_4017", X"0000_4019",
         X"0000_4021", X"0000_4023", X"0000_4025") ) ;
   

-- SendBurstIncrement and CheckBurstIncrement    
    log("SendBurstIncrement 16 word burst") ;
    SendBurstIncrementAsync(StreamTxRec, 1, X"0000_5000", 16) ; 

-- SendBurstRandom and CheckBurstRandom    
    log("SendBurstRandom 24 word burst") ;
    SendBurstRandomAsync   (StreamTxRec, 1, X"0000_6000", 24) ; 
    
-- Coverage:  SendBurstRandom and CheckBurstRandom    
    CoverID := NewID("Cov1") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, GenBin(16#7000#, 16#7007#) & GenBin(16#7010#, 16#7017#) & GenBin(16#7020#, 16#7027#) & GenBin(16#7030#, 16#7037#)) ; 

    log("SendBurstRandom 42 word burst") ;
    SendBurstRandomAsync   (StreamTxRec, 1, CoverID, 42, 32) ; 

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamTxRec, 1, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process TransmitterProc ;


  ------------------------------------------------------------
  -- AxiReceiverProc
  --   Generate transactions for AxiReceiver
  ------------------------------------------------------------
  ReceiverProc : process
    variable ExpData, RxData : std_logic_vector(DATA_WIDTH-1 downto 0) ;  
    variable NumBytes : integer ; 
    variable CoverID : CoverageIdType ; 
    variable slvBurstVector : slv_vector(1 to 5)(31 downto 0) ; 
    variable intBurstVector : integer_vector(1 to 5) ; 
    variable Available : boolean ; 
  begin
    WaitForClock(StreamRxRec, 1, 2) ; 
    
--    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
      loop 
        TryGet(StreamRxRec, 1, RxData, Available) ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1, 1) ; 
      end loop ; 
      AffirmIfEqual(RxData, X"0000_0000" + I, "RxData") ;
    end loop ; 

--    log("Transmit 32 words") ;
    for I in 1 to 32 loop 
      loop 
        TryCheck(StreamRxRec, 1, X"0000_1000" + I, Available) ; 
        exit when Available ; 
        WaitForClock(StreamRxRec, 1, 1) ; 
      end loop ; 
    end loop ; 

--    log("Send 32 word burst") ;
    loop 
      TryGetBurst (StreamRxRec, 1, NumBytes, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1, 1) ; 
    end loop ;
    AffirmIfEqual(NumBytes, 32, "Receiver: 32 Received") ;
    for I in 1 to 32 loop 
      RxData := Pop( StreamRxRec(1).BurstFifo ) ;      
      AffirmIfEqual(RxData, X"0000_2000" + I , "RxData") ;
    end loop ; 

--    log("Send 32 word burst") ;
    for I in 1 to 32 loop 
      Push( StreamRxRec(1).BurstFifo, X"0000_3000" + I  ) ; 
    end loop ; 
    loop 
      TryCheckBurst (StreamRxRec, 1, 32, Available) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1, 1) ; 
    end loop ;

    loop 
      TryCheckBurstVector(StreamRxRec, 1, 
        (X"0000_4001", X"0000_4003", X"0000_4005", X"0000_4007", X"0000_4009",
         X"0000_4011", X"0000_4013", X"0000_4015", X"0000_4017", X"0000_4019",
         X"0000_4021", X"0000_4023", X"0000_4025"), Available ) ;
      exit when Available ; 
      WaitForClock(StreamRxRec, 1, 1) ; 
    end loop ;

    loop 
      TryCheckBurstIncrement(StreamRxRec, 1, X"0000_5000", 16, Available) ; 
      exit when Available ; 
      WaitForClock(StreamRxRec, 1, 1) ; 
    end loop ;

    loop 
      TryCheckBurstRandom   (StreamRxRec, 1, X"0000_6000", 24, Available) ; 
      exit when Available ; 
      WaitForClock(StreamRxRec, 1, 1) ; 
    end loop ;

    CoverID := NewID("Cov2") ; 
    InitSeed(CoverID, 5) ; -- Get a common seed in both processes
    AddBins(CoverID, 1, 
        GenBin(16#7000#, 16#7007#) & GenBin(16#7010#, 16#7017#) & 
        GenBin(16#7020#, 16#7027#) & GenBin(16#7030#, 16#7037#)) ; 

    loop 
      TryCheckBurstRandom   (StreamRxRec, 1, CoverID, 42, 32, Available) ; 
      exit when Available ; 
      WaitForClock(StreamRxRec, 1, 1) ; 
    end loop ;


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 1, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ReceiverProc ;

end SendGetAllAsync1 ;

Configuration TbStream_SendGetAllAsync1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SendGetAllAsync1) ; 
    end for ; 
  end for ; 
end TbStream_SendGetAllAsync1 ; 