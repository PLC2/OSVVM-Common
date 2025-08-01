--
--  File Name:         TbAxi4_SubordinateReadWriteAsync2.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Test transaction source
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    12/2020   2020.12    Initial
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

architecture SubordinateReadWriteAsync2 of TestCtrl is

  signal TestDone, Sync : integer_barrier := 1 ;
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("TbAxi4_SubordinateReadWriteAsync2") ;
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
    WaitForBarrier(TestDone, 35 ms) ;
    
    TranscriptClose ; 
    -- Printing differs in different simulators due to differences in process order execution
    -- AffirmIfTranscriptsMatch(PATH_TO_VALIDATED_RESULTS) ;

    EndOfTestReports(TimeOut => (now >= 35 ms)) ; 
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
    log("Write and Read with ByteAddr = 0, 4 Bytes") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Write(ManagerRec, 1, X"AAAA_AAA0", X"5555_5555" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Read(ManagerRec, 1,  X"1111_1110", Data) ;
    AffirmIfEqual(Data, X"2222_2222", "Manager Read Data: ") ;
    
    log("Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3") ; 
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Write(ManagerRec, 1, X"AAAA_AAA0", X"11" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Write(ManagerRec, 1, X"AAAA_AAA1", X"22" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Write(ManagerRec, 1, X"AAAA_AAA2", X"33" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Write(ManagerRec, 1, X"AAAA_AAA3", X"44" ) ;
    
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Read(ManagerRec, 1,  X"1111_1110", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"AA", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Read(ManagerRec, 1,  X"1111_1111", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"BB", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Read(ManagerRec, 1,  X"1111_1112", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"CC", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Read(ManagerRec, 1,  X"1111_1113", Data(7 downto 0)) ;
    AffirmIfEqual(Data(7 downto 0), X"DD", "Manager Read Data: ") ;

    log("Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Write(ManagerRec, 1, X"BBBB_BBB0", X"2211" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Write(ManagerRec, 1, X"BBBB_BBB1", X"33_22" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Write(ManagerRec, 1, X"BBBB_BBB2", X"4433" ) ;

    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Read(ManagerRec, 1,  X"1111_1110", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"BBAA", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Read(ManagerRec, 1,  X"1111_1111", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"CCBB", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Read(ManagerRec, 1,  X"1111_1112", Data(15 downto 0)) ;
    AffirmIfEqual(Data(15 downto 0), X"DDCC", "Manager Read Data: ") ;

    log("Write and Read with 3 Bytes and ByteAddr = 0. 1") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Write(ManagerRec, 1, X"CCCC_CCC0", X"33_2211" ) ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Write(ManagerRec, 1, X"CCCC_CCC1", X"4433_22" ) ;

    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Read(ManagerRec, 1,  X"1111_1110", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"CC_BBAA", "Manager Read Data: ") ;
    WaitForBarrier(Sync) ;
    WaitForClock(ManagerRec, 1, 4) ; 
    Read(ManagerRec, 1,  X"1111_1111", Data(23 downto 0)) ;
    AffirmIfEqual(Data(23 downto 0), X"DDCC_BB", "Manager Read Data: ") ;
    
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
    variable Available : boolean ;     
    variable Count : integer ; 
  begin
    WaitForClock(SubordinateRec, 1, 2) ; 
    -- Write and Read with ByteAddr = 0, 4 Bytes
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetWriteAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    TryGetWriteData(SubordinateRec, 1, Data, Available) ;
    AffirmIf(Available, "TryGetWriteData 1") ;
    AffirmIfEqual(Addr, X"AAAA_AAA0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data, X"5555_5555", "Subordinate Write Data: ") ;
    
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetReadAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    AffirmIfEqual(Addr, X"1111_1110", "Subordinate Read Addr: ") ;
    SendReadDataAsync(SubordinateRec, 1, X"2222_2222") ; 

    
    -- Write and Read with 1 Byte, and ByteAddr = 0, 1, 2, 3
    -- Write(ManagerRec, 1, X"AAAA_AAA0", X"11" ) ;
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetWriteAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    TryGetWriteData(SubordinateRec, 1, Addr, Data(7 downto 0), Available) ;
    AffirmIf(Available, "TryGetWriteData 11") ;
    AffirmIfEqual(Addr, X"AAAA_AAA0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"11", "Subordinate Write Data: ") ;

    -- Write(ManagerRec, 1, X"AAAA_AAA1", X"22" ) ;
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetWriteData(SubordinateRec, 1, X"AAAA_AAA1", Data(7 downto 0), Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    TryGetWriteAddress(SubordinateRec, 1, Addr, Available) ;
    AffirmIf(Available, "TryGetWriteAddress 22") ;
    AffirmIfEqual(Addr, X"AAAA_AAA1", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"22", "Subordinate Write Data: ") ;

    -- Write(ManagerRec, 1, X"AAAA_AAA2", X"33" ) ;
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetWriteData(SubordinateRec, 1, X"AAAA_AAA2", Data(7 downto 0), Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    TryGetWriteAddress(SubordinateRec, 1, Addr, Available) ;
    AffirmIf(Available, "TryGetWriteAddress 33") ;
    AffirmIfEqual(Addr, X"AAAA_AAA2", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"33", "Subordinate Write Data: ") ;  --

    -- Write(ManagerRec, 1, X"AAAA_AAA3", X"44" ) ;
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetWriteAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    TryGetWriteData(SubordinateRec, 1, Addr, Data(7 downto 0), Available) ;
    AffirmIf(Available, "TryGetWriteData 44") ;
    AffirmIfEqual(Addr, X"AAAA_AAA3", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(7 downto 0), X"44", "Subordinate Write Data: ") ;  --


    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetReadAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    AffirmIfEqual(Addr, X"1111_1110", "Subordinate Read Addr: ") ;
    SendReadDataAsync(SubordinateRec, 1, X"AA") ; 

    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetReadAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    AffirmIfEqual(Addr, X"1111_1111", "Subordinate Read Addr: ") ;
    SendReadDataAsync(SubordinateRec, 1, X"BB") ; 

    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetReadAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    AffirmIfEqual(Addr, X"1111_1112", "Subordinate Read Addr: ") ;
    SendReadDataAsync(SubordinateRec, 1, X"CC") ; 

    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetReadAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    AffirmIfEqual(Addr, X"1111_1113", "Subordinate Read Addr: ") ;
    SendReadDataAsync(SubordinateRec, 1, X"DD") ; 



    -- Write and Read with 2 Bytes, and ByteAddr = 0, 1, 2
    -- Write(ManagerRec, 1, X"BBBB_BBB0", X"2211" ) ;
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetWriteAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    TryGetWriteData(SubordinateRec, 1, Addr, Data(15 downto 0), Available) ;
    AffirmIf(Available, "TryGetWriteData 2211") ;
    AffirmIfEqual(Addr, X"BBBB_BBB0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(15 downto 0), X"2211", "Subordinate Write Data: ") ;

    -- Write(ManagerRec, 1, X"BBBB_BBB1", X"3322" ) ;
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetWriteAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    TryGetWriteData(SubordinateRec, 1, Addr, Data(15 downto 0), Available) ;
    AffirmIf(Available, "TryGetWriteData 3322") ;
    AffirmIfEqual(Addr, X"BBBB_BBB1", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(15 downto 0), X"3322", "Subordinate Write Data: ") ;

    -- Write(ManagerRec, 1, X"BBBB_BBB2", X"4433" ) ;  --
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetWriteAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    TryGetWriteData(SubordinateRec, 1, Addr, Data(15 downto 0), Available) ;
    AffirmIf(Available, "TryGetWriteData 4433") ;
    AffirmIfEqual(Addr, X"BBBB_BBB2", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(15 downto 0), X"4433", "Subordinate Write Data: ") ;


    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetReadAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    AffirmIfEqual(Addr, X"1111_1110", "Subordinate Read Addr: ") ;
    SendReadDataAsync(SubordinateRec, 1, X"BBAA") ; 

    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetReadAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    AffirmIfEqual(Addr, X"1111_1111", "Subordinate Read Addr: ") ;
    SendReadDataAsync(SubordinateRec, 1, X"CCBB") ; 

    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetReadAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    AffirmIfEqual(Addr, X"1111_1112", "Subordinate Read Addr: ") ;
    SendReadDataAsync(SubordinateRec, 1, X"DDCC") ; 


    -- Write and Read with 3 Bytes and ByteAddr = 0. 1
    -- Write(ManagerRec, 1, X"CCCC_CCC0", X"332211" ) ;
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetWriteAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    TryGetWriteData(SubordinateRec, 1, Addr, Data(23 downto 0), Available) ;
    AffirmIf(Available, "TryGetWriteData 33_2211") ;
    AffirmIfEqual(Addr, X"CCCC_CCC0", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(23 downto 0), X"33_2211", "Subordinate Write Data: ") ;

    -- Write(ManagerRec, 1, X"CCCC_CCC1", X"443322" ) ;
    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetWriteAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    TryGetWriteData(SubordinateRec, 1, Addr, Data(23 downto 0), Available) ;
    AffirmIf(Available, "TryGetWriteData 4433_22") ;
    AffirmIfEqual(Addr, X"CCCC_CCC1", "Subordinate Write Addr: ") ;
    AffirmIfEqual(Data(23 downto 0), X"4433_22", "Subordinate Write Data: ") ;


    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetReadAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    AffirmIfEqual(Addr, X"1111_1110", "Subordinate Read Addr: ") ;
    SendReadDataAsync(SubordinateRec, 1, X"CCBBAA") ; 

    WaitForBarrier(Sync) ;
    Count := 0 ; 
    loop 
      TryGetReadAddress(SubordinateRec, 1, Addr, Available) ;
      exit when Available ; 
      Count := Count + 1 ; 
      WaitForClock(SubordinateRec, 1, 1) ; 
    end loop ; 
    AffirmIf(Count > 0, "Count " & to_string(Count)) ;
    AffirmIfEqual(Addr, X"1111_1111", "Subordinate Read Addr: ") ;
    SendReadDataAsync(SubordinateRec, 1, X"DDCCBB") ; 


    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(SubordinateRec, 1, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process SubordinateProc ;


end SubordinateReadWriteAsync2 ;

Configuration TbAxi4_SubordinateReadWriteAsync2 of TbAxi4 is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(SubordinateReadWriteAsync2) ; 
    end for ; 
  end for ; 
end TbAxi4_SubordinateReadWriteAsync2 ; 