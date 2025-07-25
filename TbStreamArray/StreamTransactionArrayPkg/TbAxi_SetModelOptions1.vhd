--
--  File Name:         TbAxi_SetModelOptions1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Set AXI Ready Time.   Check Timeout on Valid (nominally large or infinite?)
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    11/2022   2022.11    Initial revision
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
architecture SetModelOptions1 of TestCtrl is

  signal TestDone, TestPhaseStart : integer_barrier := 1 ;
   
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbAxi_SetModelOptions1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs
    SetAlertStopCount(FAILURE, integer'right) ;  -- Allow FAILURES

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  

    -- Wait for test to finish
    WaitForBarrier(TestDone, 35 ms) ;
    AlertIf(now >= 35 ms, "Test finished due to timeout") ;
    -- AlertIf(GetAffirmCount < 1, "Test is not Self-Checking"); -- Now handled by EndOfTestReports
    
    TranscriptClose ; 
--    AffirmIfTranscriptsMatch(PATH_TO_VALIDATED_RESULTS) ;
    
    EndOfTestReports ; 
    std.env.stop ;
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  -- AxiTransmitterProc
  --   Generate transactions for AxiTransmitter
  ------------------------------------------------------------
  AxiTransmitterProc : process
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
    variable IntVal : integer ; 
    variable BoolVal : boolean ; 
  begin
    WaitForClock(StreamTxRec, 1, 1) ; 
    
    GetModelOptions(StreamTxRec, 1, AxiStreamOptionsType'pos(TRANSMIT_READY_TIME_OUT), IntVal) ;
    log("Default TRANSMIT_READY_TIME_OUT " & to_string(IntVal)) ; 
    SetModelOptions(StreamTxRec, 1, AxiStreamOptionsType'pos(TRANSMIT_READY_TIME_OUT), 5) ;
    GetModelOptions(StreamTxRec, 1, AxiStreamOptionsType'pos(TRANSMIT_READY_TIME_OUT), IntVal) ;
    AffirmIfEqual(IntVal, 5, "TRANSMIT_READY_TIME_OUT ") ; 


    GetAxiStreamOptions(StreamTxRec, 1, DEFAULT_ID, User) ;
    log("Default DEFAULT_ID " & to_string(User)) ; 
    SetAxiStreamOptions(StreamTxRec, 1, DEFAULT_ID, "1010") ;
    GetAxiStreamOptions(StreamTxRec, 1, DEFAULT_ID, User) ;
    AffirmIfEqual(User, "1010", "DEFAULT_ID ") ; 
    

    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamTxRec, 1, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiTransmitterProc ;


  ------------------------------------------------------------
  -- AxiReceiverProc
  --   Generate transactions for AxiReceiver
  ------------------------------------------------------------
  AxiReceiverProc : process
    variable User : std_logic_vector(USER_LEN-1 downto 0) ;  -- 4
    variable IntVal : integer ; 
    variable BoolVal : boolean ; 
  begin
    WaitForClock(StreamRxRec, 1, 4) ; 
    
    GetModelOptions(StreamRxRec, 1, AxiStreamOptionsType'pos(RECEIVE_READY_DELAY_CYCLES), IntVal) ;
    log("Default RECEIVE_READY_DELAY_CYCLES " & to_string(IntVal)) ; 
    SetModelOptions(StreamRxRec, 1, AxiStreamOptionsType'pos(RECEIVE_READY_DELAY_CYCLES), 5) ;
    GetModelOptions(StreamRxRec, 1, AxiStreamOptionsType'pos(RECEIVE_READY_DELAY_CYCLES), IntVal) ;
    AffirmIfEqual(IntVal, 5, "RECEIVE_READY_DELAY_CYCLES ") ; 

    GetAxiStreamOptions(StreamRxRec, 1, DEFAULT_ID, User) ;
    log("Default DEFAULT_ID " & to_string(User)) ; 
    SetAxiStreamOptions(StreamRxRec, 1, DEFAULT_ID, "1010") ;
    GetAxiStreamOptions(StreamRxRec, 1, DEFAULT_ID, User) ;
    AffirmIfEqual(User, "1010", "DEFAULT_ID ") ; 

    GetModelOptions(StreamRxRec, 1, AxiStreamOptionsType'pos(RECEIVE_READY_BEFORE_VALID), BoolVal) ;
    log("Default RECEIVE_READY_BEFORE_VALID " & to_string(BoolVal)) ; 
    SetModelOptions(StreamRxRec, 1, AxiStreamOptionsType'pos(RECEIVE_READY_BEFORE_VALID), FALSE) ;
    GetModelOptions(StreamRxRec, 1, AxiStreamOptionsType'pos(RECEIVE_READY_BEFORE_VALID), BoolVal) ;
    AffirmIfEqual(BoolVal, FALSE, "RECEIVE_READY_BEFORE_VALID ") ; 
    
    SetModelOptions(StreamRxRec, 1, AxiStreamOptionsType'pos(RECEIVE_READY_BEFORE_VALID), TRUE) ;
    GetModelOptions(StreamRxRec, 1, AxiStreamOptionsType'pos(RECEIVE_READY_BEFORE_VALID), BoolVal) ;
    AffirmIfEqual(BoolVal, TRUE, "RECEIVE_READY_BEFORE_VALID ") ; 
 
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(StreamRxRec, 1, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process AxiReceiverProc ;

end SetModelOptions1 ;

Configuration TbAxi_SetModelOptions1 of TbStream is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SetModelOptions1) ; 
    end for ; 
  end for ; 
end TbAxi_SetModelOptions1 ; 