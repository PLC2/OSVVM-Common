--
--  File Name:         TbAxi4_BasicBurst.vhd
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
--    09/2017   2020.04    Initial revision
--    12/2020   2020.12    This test is a beta start at bursting
--                         see MemoryBurst1 for testing.
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

architecture BasicBurst of TestCtrl is

  signal TestDone : integer_barrier := 1 ;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbAxi4_BasicBurst") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

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
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;

  begin
    wait until nReset = '1' ;  
    WaitForClock(ManagerRec, 1, 2) ; 
    log("Write with ByteAddr = 0, 4 Bytes") ;
    for i in 3 to 10 loop
      Push(WriteBurstFifo, to_slv(i, 8)) ;
    end loop ;
    WriteBurst(ManagerRec, 1, X"0000_1002", 8) ;
    
--    WaitForClock(ManagerRec, 1, 18) ; 
    
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(ManagerRec, 1, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process ManagerProc ;


  ------------------------------------------------------------
  -- SubordinateProc
  --   Generate transactions for AxiSubordinate
  ------------------------------------------------------------
  SubordinateProc : process
    variable Addr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) ;
    variable Data : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) ;  
--    alias  WReady    : std_logic        is AxiLiteBus.WriteData.WReady ;
    
  begin
--    WReady <= 'Z' ; 
    WaitForClock(SubordinateRec, 1, 2) ; 
    -- Write and Read with ByteAddr = 0, 4 Bytes
    GetWrite(SubordinateRec, 1, Addr, Data) ;
    AffirmIfEqual(Addr, X"0000_1002", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"0403_----", "Subordinate Write Data: ") ;
    GetWriteData(SubordinateRec, 1, Data) ;
    AffirmIfEqual(Data, X"0807_0605", "Subordinate Write Data: ") ;
    GetWriteData(SubordinateRec, 1, Data) ;
    AffirmIfEqual(Data, X"----_0A09", "Subordinate Write Data: ") ;

    
    -- Force the Subordinate to allow the bus to transfer the write burst
--    WReady <= force '1' ; 
    
--    WaitForClock(SubordinateRec, 1, 18) ; 

    -- Wait for outputs to propagate and signal TestDone
--    WaitForClock(SubordinateRec, 1, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;


end BasicBurst ;

Configuration TbAxi4_BasicBurst of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(BasicBurst) ; 
    end for ; 
  end for ; 
end TbAxi4_BasicBurst ; 