--
--  File Name:         TbAxi4_MemoryBurstSparse1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Testing of Burst Features in AXI Model
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    04/2020   2020.04    Initial revision
--    12/2020   2020.12    Updated signal and port names
--
--
--  This file is part of OSVVM.
--  
--  Copyright (c) 2020 by SynthWorks Design Inc.  
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

architecture MemoryBurstSparse1 of TestCtrl is

  signal TestDone, WriteDone : integer_barrier := 1 ;
  constant BURST_MODE : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_WORD_MODE ;   
--  constant BURST_MODE : AddressBusFifoBurstModeType := ADDRESS_BUS_BURST_BYTE_MODE ;   
  constant DATA_WIDTH : integer := IfElse(BURST_MODE = ADDRESS_BUS_BURST_BYTE_MODE, 8, AXI_DATA_WIDTH)  ;  

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbAxi4_MemoryBurstSparse1") ;
    SetLogEnable(PASSED, TRUE) ;   -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;     -- Enable INFO logs
    SetLogEnable(DEBUG, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 1 ms) ;
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AffirmIfTranscriptsMatch(PATH_TO_VALIDATED_RESULTS) ;

    EndOfTestReports(TimeOut => (now >= 1 ms)) ; 
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  ------------------------------------------------------------
  -- ManagerProc
  --   Generate transactions for AxiManager
  ------------------------------------------------------------
  ManagerProc : process
    variable ByteData : std_logic_vector(7 downto 0) ;
    variable BurstVal : AddressBusFifoBurstModeType ; 
  begin
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 1, 2) ; 
    
----------------------------------------  Test 1, Word Aligned
    log("Write with ByteAddr = 8, 12 Bytes -- word aligned") ;
    Push(WriteBurstFifo, X"UUUU_UU01") ;
    Push(WriteBurstFifo, X"UUUU_02UU") ;
    Push(WriteBurstFifo, X"UU03_UUUU") ;
    Push(WriteBurstFifo, X"04UU_UUUU") ;
    
    Push(WriteBurstFifo, X"UUUU_0605") ;
    Push(WriteBurstFifo, X"UU08_07UU") ;
    Push(WriteBurstFifo, X"0A09_UUUU") ;

    Push(WriteBurstFifo, X"UU0D_0C0B") ;
    Push(WriteBurstFifo, X"100F_0EUU") ;
    
    WriteBurst(ManagerRec, 1, X"0000_1000", 9) ;


    ReadBurst (ManagerRec, 1, X"0000_1000", 9) ;
    
   CheckExpected(ReadBurstFifo, X"----_--01") ;
   CheckExpected(ReadBurstFifo, X"----_02--") ;
   CheckExpected(ReadBurstFifo, X"--03_----") ;
   CheckExpected(ReadBurstFifo, X"04--_----") ;
    
   CheckExpected(ReadBurstFifo, X"----_0605") ;
   CheckExpected(ReadBurstFifo, X"--08_07--") ;
   CheckExpected(ReadBurstFifo, X"0A09_----") ;

   CheckExpected(ReadBurstFifo, X"--0D_0C0B") ;
   CheckExpected(ReadBurstFifo, X"100F_0E--") ;
    
    
----------------------------------------  Test 2, Byte Aligned
    Push(WriteBurstFifo, X"UU02_01UU") ;
    Push(WriteBurstFifo, X"05UU_0403") ;
    Push(WriteBurstFifo, X"8877_UU06") ;
    Push(WriteBurstFifo, X"BBAA_99UU") ;
    
    Push(WriteBurstFifo, X"UUUU_DDCC") ;
    Push(WriteBurstFifo, X"FFUU_UUEE") ;
    Push(WriteBurstFifo, X"1110_UUUU") ;

    Push(WriteBurstFifo, X"UUUU_UU12") ;
    Push(WriteBurstFifo, X"UUUU_13UU") ;
    Push(WriteBurstFifo, X"UU14_UUUU") ;
    Push(WriteBurstFifo, X"15UU_UUUU") ;
    
    WriteBurst(ManagerRec, 1, X"0000_2001", 11) ;

    ReadBurst(ManagerRec, 1, X"0000_2001", 11) ;
   CheckExpected(ReadBurstFifo, X"--02_01--") ;
   CheckExpected(ReadBurstFifo, X"05--_0403") ;
   CheckExpected(ReadBurstFifo, X"8877_--06") ;
   CheckExpected(ReadBurstFifo, X"BBAA_99--") ;

   CheckExpected(ReadBurstFifo, X"----_DDCC") ;
   CheckExpected(ReadBurstFifo, X"FF--_--EE") ;
   CheckExpected(ReadBurstFifo, X"1110_----") ;

   CheckExpected(ReadBurstFifo, X"----_--12") ;
   CheckExpected(ReadBurstFifo, X"----_13--") ;
   CheckExpected(ReadBurstFifo, X"--14_----") ;
   CheckExpected(ReadBurstFifo, X"15--_----") ;


    WaitForBarrier(WriteDone) ;
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 1, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;


  ------------------------------------------------------------
  -- MemoryProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  MemoryProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ; 
  begin
    WaitForClock(SubordinateRec, 1, 2) ; 
   
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 1, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MemoryProc ;


end MemoryBurstSparse1 ;

Configuration TbAxi4_MemoryBurstSparse1 of TbAxi4Memory is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(MemoryBurstSparse1) ; 
    end for ; 
--!!    for Subordinate_1 : Axi4Subordinate 
--!!      use entity OSVVM_AXI4.Axi4Memory ; 
--!!    end for ; 
  end for ; 
end TbAxi4_MemoryBurstSparse1 ; 