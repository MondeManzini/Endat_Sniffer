-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- This file contains  modules which make up a testbench
-- suitable for testing the "device under test".
--
-------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_arith.all;
    use ieee.numeric_std.all;
    use ieee.std_logic_unsigned.all;
    use std.textio.all;
    use work.txt_util.all;
    use work.Version_Ascii.all;

library modelsim_lib;
    use modelsim_lib.util.all;

entity Endat_Sniffer_Test_Bench is

end Endat_Sniffer_Test_Bench;

architecture Archtest_bench of Endat_Sniffer_Test_Bench is
	
  component test_bench_T
    generic (
      Vec_Width  : positive := 4;
      ClkPer     : time     := 20 ns;
      StimuFile  : string   := "data.txt";
      ResultFile : string   := "results.txt"
  ); 
  
    port (
      oVec : out std_logic_vector(Vec_Width-1 downto 0);
      oClk : out std_logic;
      iVec : in std_logic_vector(3 downto 0)
      );
end component;

signal Version_Register_i       : STD_LOGIC_VECTOR(199 downto 0);

-- Timestamp from Tcl Script
signal Version_Timestamp_i      : STD_LOGIC_VECTOR(111 downto 0);       -- 20181120105439
  
-- Firmware Module
constant EndatSniffer_name_i   : STD_LOGIC_VECTOR(23 downto 0) := x"524643";  -- Endat_FirmwareC

-- Version Major Number - Hardcoded
constant Version_Major_High_i   : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- 0x
constant Version_Major_Low_i    : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- x3

constant Dot_i                  : STD_LOGIC_VECTOR(7 downto 0) := x"2e";  -- .
-- Version Minor Number - Hardcoded
constant Version_Minor_High_i   : STD_LOGIC_VECTOR(7 downto 0) := x"32";  -- 0x
constant Version_Minor_Low_i    : STD_LOGIC_VECTOR(7 downto 0) := x"30";  -- x0
-- Null Termination
constant Null_i                 : STD_LOGIC_VECTOR(7 downto 0) := x"00";  -- termination

signal Module_Number_i                    : std_logic_vector(7 downto 0);

----------------------------------------------------------------------
-- Endat Sniffer Component and Signals
----------------------------------------------------------------------
component EndatSniffer IS
generic 
( 
  MODE_BITS          : integer   :=  8;    -- Width of the mode data
  POS_BITS           : integer   :=  26;   -- Width of Position
  ADD_BITS           : integer   :=  25;   -- Width of Additional Data
  CRC_BITS           : integer   :=  5    -- Width of CRC 
);      

port
(
-- Input ports
clk                 : in  std_logic;     -- FPGA 50MHz clock
reset_n             : in  std_logic;     -- FPGA Reset
endat_clk           : in  std_logic;     -- Clock input from the EnDat sniffer Hardware
endat_data          : in  std_logic;     -- Data input from the EnDat sniffer Hardware
endat_enable        : in  std_logic;     -- request to sniff EnDat tranmission
-- Input / Output ports
endat_mode_out      : out std_logic_vector(8 downto 0);  -- All data
endat_Position_out  : out std_logic_vector(31 downto 0);  -- All data
endat_Data_1_out    : out std_logic_vector(31 downto 0);  -- All data
endat_Data_2_out    : out std_logic_vector(31 downto 0);  -- All data
data_cnt            : out integer; 
-- Output ports 
endat_data_Ready    : out std_logic
);                   
END component EndatSniffer;

----------------------------------------------------------------------
-- Endat Sniffer Mux Component and Signals
----------------------------------------------------------------------
component EndatSniffer_Mux IS
port
(
  CLK_I               : in  std_logic;     
  RST_I               : in  std_logic;     
  UART_TXD            : out std_logic;
  endat_clk           : in  std_logic;     
  endat_data          : in  std_logic;     
  endat_enable        : in  std_logic;     
  endat_mode_out      : out std_logic_vector(8 downto 0);  
  endat_Position_out  : out std_logic_vector(31 downto 0);  
  endat_Data_1_out    : out std_logic_vector(31 downto 0);  
  endat_Data_2_out    : out std_logic_vector(31 downto 0);  
  data_cnt            : out integer; 
  endat_data_Ready    : out std_logic;
  Endat_Request       : out std_logic;
  Baud_Rate_Enable    : in  std_logic
);                   
END component EndatSniffer_Mux;

signal Baud_Rate_Enable_i               : std_logic;
signal endat_clk_i                      : std_logic;
signal endat_data_i                     : std_logic;
signal endat_enable_i                   : std_logic;
signal endat_mode_out_i                 : std_logic_vector(8 downto 0);         
signal endat_Position_out_i             : std_logic_vector(31 downto 0);     
signal endat_Data_1_out_i               : std_logic_vector(31 downto 0);
signal endat_Data_2_out_i               : std_logic_vector(31 downto 0);         
signal endat_data_ready_i               : std_logic;
signal data_cnt_i                       : integer;
signal UART_TXD_i                       : std_logic;
signal display_version_lock             : std_logic;
signal EndatSniffer_Version_Ready_i     : std_logic;
signal EndatSniffer_Version_Name_i      : std_logic_vector(255 downto 0);
signal EndatSniffer_Version_Number_i    : std_logic_vector(63 downto 0);
signal Version_EndatSniffer             : std_logic_vector(7 downto 0);  
signal EndatSniffer_Version_Request_i   : std_logic;
signal EndatSniffer_Version_Load_i      : std_logic;
signal Endat_Request_i                  : std_logic;
signal mode_data_i                      : std_logic_vector(8 downto 0); 
signal pos_data_i                       : std_logic_vector(31 downto 0); 
signal add_data_1_i                     : std_logic_vector(31 downto 0);
signal add_data_2_i                     : std_logic_vector(31 downto 0);        
signal clock_latch                      : std_logic;
-------------------------------------------------------------------------------
-- New Code Signal and Components
------------------------------------------------------------------------------- 
signal RST_I_i                  : std_logic;
signal CLK_I_i                  : std_logic;

type memory_array is array (0 to 255) of std_logic_vector(7 downto 0);
signal data2store                   : memory_array;

----------------------------------------
----------------------------------------
-- General Signals
-------------------------------------------------------------------------------
type endat_emulate_states is (Idle, clock_gen) 
                              ;
--type endat_emulate_states is (request_data, start_cond, test_select, send_mode, read_pos, 
--                              send_data, read_data_1, read_data_2, read_data_3, read_data_4);
type transceiver_states is (Idle, mode_gen, mode_write, pos_data_gen, pos_data_write,
                            add_data_1_gen, add_data_1_write, add_data_2_gen, add_data_2_write) 
                            ;
signal endat_emulate_state           : endat_emulate_states;
signal transceiver_state             : transceiver_states;

signal  sClok,snrst,sStrobe,PWM_sStrobe,newClk,Clk : std_logic := '0';
signal  stx_data,srx_data : std_logic_vector(3 downto 0) := "0000";
signal  sCnt         : integer range 0 to 7 := 0;
signal  cont         : integer range 0 to 100;  
signal  oClk,OneuS_sStrobe, Quad_CHA_sStrobe, Quad_CHB_sStrobe,OnemS_sStrobe,cStrobe,sStrobe_A,Ten_mS_sStrobe,Twenty_mS_sStrobe, Fifty_mS_sStrobe, Hun_mS_sStrobe, Sec_sStrobe : std_logic;

constant Baudrate : integer := 115200;
constant bit_time_4800      : time                         := 52.08*4 us;
constant bit_time_9600      : time                         := 52.08*2 us;    
constant bit_time_19200     : time                         := 52.08 us;
constant bit_time_57600     : time                         := 17.36 us;    
constant bit_time_115200    : time                         := 8.68 us;  
constant default_bit_time   : time                         := 52.08 us;  --19200  
constant start_bit          : std_logic := '0';
constant stop_bit           : std_logic := '1';
signal   bit_time           : time;


-- Build State
-- Good Build State 
------------------------------------------
-- Messages following the software scripts 
------------------------------------------
                                                                                                                                                 
--------------------------------------------------------------------------------------------------------------------------------------------------------
  -- SPI Input Signals
--------------------------------------------------------------------------------------------------------------------------------------------------------
begin
    RST_I_i           <= snrst;
    CLK_I_i           <= sClok;
    
Firmware_Controller_Version_Updator: process(RST_I_i,CLK_I_i)
 variable EndatSniffer_Version_cnt: integer range 0 to 10;
begin
  if RST_I_i = '0' then
    EndatSniffer_Version_Ready_i  <= '0';
    EndatSniffer_Version_Name_i   <= (others=>'0');
    EndatSniffer_Version_Number_i <= (others=>'0');
    EndatSniffer_Version_cnt      := 0;
    EndatSniffer_Version_Load_i   <= '0';
  elsif CLK_I_i'event and CLK_I_i = '1' then  
     
    if Module_Number_i = X"0c" then
        if EndatSniffer_Version_Request_i = '1' then
            
            EndatSniffer_Version_Load_i   <= '1';
        else
            EndatSniffer_Version_Ready_i  <= '0';
        end if;

        if EndatSniffer_Version_Load_i = '1' then
            if EndatSniffer_Version_cnt = 5 then
                EndatSniffer_Version_Ready_i <= '1';
                EndatSniffer_Version_Load_i  <= '0';
                EndatSniffer_Version_cnt     := 0;
            else
                EndatSniffer_Version_cnt     := EndatSniffer_Version_cnt + 1;   
                EndatSniffer_Version_Ready_i <= '0';
            end if;  
        end if;   
    else   
        EndatSniffer_Version_Ready_i <= '0'; 
    end if;   

  end if;
end process Firmware_Controller_Version_Updator;

 EndatSniffer_Version_Name_i   <= E & N & D & A & T & Space & S & N & I & F & F & E & R & Space &
                                           Space & Space & Space & Space & Space & Space & Space & Space &
                                           Space & Space & Space & Space & Space & Space & Space &
                                           Space & Space & Space;
EndatSniffer_Version_Number_i <= Zero & Zero & Dot & Zero & One & Dot & Zero & Five; 
Version_Register_i <=  EndatSniffer_name_i & Null_i & Version_Major_High_i & Version_Major_Low_i & Dot_i &
                        Version_Minor_High_i & Version_Minor_Low_i & Dot_i &
                        Version_Timestamp_i & Null_i;      
-------------------------------------------------------------------------------
-- New test Code
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Leave in code
-------------------------------------------------------------------------------   
T1: test_bench_T
 port map(
   oVec => stx_data,
   oClk => sClok,
   iVec => srx_data
   );
   
-------------------------------------------------------------------------------
-- EndatSniffer Instance
-------------------------------------------------------------------------------
EndatSniffer_1: entity work.EndatSniffer
  PORT map (
    clk                 => CLK_I_i,                  --system clock
    reset_n             => RST_I_i,                  --active low reset
    endat_clk           => endat_clk_i,                 --latch in command
    endat_data          => endat_data_i,                --address of target slave
    endat_enable        => Endat_Request_i,                    --'0' is write, '1' is read
    endat_mode_out      => endat_mode_out_i,                --data to write to slave
    endat_Position_out  => endat_Position_out_i,                   --indicates transaction in progress
    endat_Data_1_out    => endat_Data_1_out_i,                --data read from slave
    endat_Data_2_out    => endat_Data_2_out_i,              --flag if improper acknowledge from slave
    data_cnt            => data_cnt_i,                    --serial data output of i2c bus
    endat_data_Ready    => endat_data_ready_i                    -- serial clock output of i2c bus
    );    

-------------------------------------------------------------------------------
-- EndatSniffer Mux
-------------------------------------------------------------------------------
EndatSniffer_Mux_1: entity work.EndatSniffer_Mux
  PORT map (
    CLK_I               => CLK_I_i,                  
    RST_I               => RST_I_i,                  
    UART_TXD            => UART_TXD_i,           
    endat_mode_out      => endat_mode_out_i,                
    endat_Position_out  => endat_Position_out_i,                  
    endat_Data_1_out    => endat_Data_1_out_i,               
    endat_Data_2_out    => endat_Data_2_out_i,              
    endat_data_Ready    => endat_data_ready_i,
    Endat_Request       => Endat_Request_i,
    Baud_Rate_Enable    => Baud_Rate_Enable_i,
    One_mS              => OnemS_sStrobe
    );  

-------------------------------------------------------------------------------
-- Baud Instance for Mux  
-------------------------------------------------------------------------------     
Baud_1: entity work.Baud_Rate_Generator
port map (
  Clk                                 => CLK_I_i,
  RST_I                               => RST_I_i,
  baud_rate                           => 5,
  Baud_Rate_Enable                    => Baud_Rate_Enable_i 
  );
Firmware_Controller_Version_Tester: process(CLK_I_i, RST_I_i)
  variable display_version_cnt  : integer range 0 to 50;
  
begin

if RST_I_i = '0' then
   display_version_lock <= '0';
   display_version_cnt  := 1;
   report "The version number of " & hstr(EndatSniffer_Version_Name_i) & " is " & hstr(EndatSniffer_Version_Number_i) severity note;  -- For Modelsim
 elsif (CLK_I_i'event and CLK_I_i = '1') then
     
     if display_version_cnt = 0 then
        display_version_lock <= '0';
    else   
        display_version_cnt := display_version_cnt - 1;
        display_version_lock <= '1';
    end if;
            
     if display_version_lock = '1' then
        report "Version build number is " & hstr(Version_Register_i) & "h" severity note;
        --print(l_file, "#Firmware Version Log File#");
        --print(l_file, "#-------------------------#");
        --print(l_file, str(Version_Register_i) & " "& hstr(Version_Register_i)& "h");
    end if;
    
 end if;

 end process;

Endat_test: process(RST_I_i,CLK_I_i)
variable Request_Data_cnt   : integer range 0 to 1000_000;
variable clock_cnt          : integer range 0 to 400;
variable data_cnt           : integer range 0 to 100;
variable send_read_cnt      : integer range 0 to 20;
variable mode_cycle_count   : integer range 0 to 33;
variable pos_cycle_count    : integer range 0 to 33;
variable data_cycle_count   : integer range 0 to 33;
variable add_data_cnt       : integer range 0 to 5;
begin
  if RST_I_i = '0' then
    endat_enable_i      <= '0';
    endat_clk_i         <= 'Z';
    endat_data_i        <= 'Z';
    Request_Data_cnt    := 0;
    clock_cnt           := 0;
    mode_cycle_count    := 8;
    pos_cycle_count     := 0;
    data_cycle_count    := 0;
    add_data_cnt        := 0;
    clock_latch         <= '0';
    data_cnt            := 0;
    mode_data_i         <= (others => '0');
    endat_emulate_state <= Idle;

  elsif CLK_I_i'event and CLK_I_i = '1' then  
    case endat_emulate_state is 
      when Idle => 
        mode_cycle_count    := 0;
        data_cycle_count    := 0;
        pos_cycle_count     := 0;
        clock_cnt           := 0;
        clock_latch         <= '0';
        if Request_Data_cnt = 6500 then  -- 100 ms Retrieve 0 for 5000_000
          endat_enable_i      <= '1';                              
          Request_Data_cnt    := 0;
          endat_emulate_state <= clock_gen;
        else
          Request_Data_cnt    := Request_Data_cnt + 1;
          endat_enable_i      <= '0';
          endat_emulate_state <= Idle;
        end if;     
        
      when clock_gen =>
        endat_enable_i  <= '0';
        if clock_cnt = 200 then
          endat_clk_i         <= '0';
          clock_cnt           := clock_cnt + 1;
        elsif clock_cnt = 400 then
          clock_cnt           := 0;
          endat_clk_i         <= '1';
        else
          clock_cnt           := clock_cnt + 1;
        end if; 

        case transceiver_state is 
          when Idle =>
            mode_cycle_count  := 9;
            data_cycle_count  := 0;
            pos_cycle_count   := 0;
            transceiver_state <= mode_gen;
            clock_latch       <= '0'; 

          when mode_gen =>
            if endat_clk_i = '0' and clock_latch = '0' then
              clock_latch             <= '1';
              mode_data_i             <= x"38" & '0';         -- Mode Command 00111000
              transceiver_state       <= mode_write;
              mode_cycle_count        := mode_cycle_count - 1;
            end if;

          when mode_write =>
            if mode_cycle_count > 0 then
              endat_data_i        <= mode_data_i(mode_cycle_count);  -- LSB first (0)
              if endat_clk_i = '1' and clock_latch = '1' then
                clock_latch       <= '0';
                transceiver_state <= mode_gen;
              end if;
            elsif mode_cycle_count = 0 and (endat_mode_out_i > x"00" & '0') then
                endat_data_i      <= '0';
                transceiver_state <= pos_data_gen;
            end if;
          
          when pos_data_gen =>
            if endat_clk_i = '0' then
              clock_latch         <= '1';
              pos_data_i          <= x"7E1FC3F8";     -- Position Command 7E1FC3F8
              transceiver_state   <= pos_data_write;
            end if;

          when pos_data_write =>
            if pos_cycle_count < 32 then
              endat_data_i      <= pos_data_i(pos_cycle_count);
              if endat_clk_i = '1' and clock_latch = '1' then
                pos_cycle_count   := pos_cycle_count + 1;
                transceiver_state <= pos_data_gen;
              end if;
            elsif pos_cycle_count = 32 then
              if endat_clk_i = '1' and clock_latch = '1' then
                transceiver_state   <= add_data_1_gen;
                data_cycle_count    := 0;
              end if;
            end if;

          when add_data_1_gen =>
            if endat_clk_i = '0' then
              clock_latch         <= '1';
              add_data_1_i        <= x"7E1FC3F8";     -- Additional Data 1 Command 7E1FC3F8
              transceiver_state   <= add_data_1_write;
            end if;

          when add_data_1_write =>
            if data_cycle_count < 29 then
              endat_data_i      <= add_data_1_i(data_cycle_count);
              if endat_clk_i = '1' and clock_latch = '1' then
                data_cycle_count   := data_cycle_count + 1;
                transceiver_state <= add_data_1_gen;
              end if;
            elsif data_cycle_count = 29 then
              if endat_clk_i = '1' and clock_latch = '1' then
                endat_data_i      <= '0';
                data_cycle_count    := 0;
                transceiver_state   <= add_data_2_gen;
              end if;
            end if;

          when add_data_2_gen =>
            if endat_clk_i = '0' then
              clock_latch         <= '1';
              add_data_2_i        <= x"7E1FC3F8";     -- Additional Data 2 Command 7E1FC3F8
              transceiver_state   <= add_data_2_write;
            end if;

          when add_data_2_write =>
            if data_cycle_count < 32 then
              endat_data_i      <= add_data_2_i(data_cycle_count);
              if endat_clk_i = '1' and clock_latch = '1' then
                data_cycle_count   := data_cycle_count + 1;
                transceiver_state <= add_data_2_gen;
              end if;
            elsif data_cycle_count = 32 then
              if endat_clk_i = '1' and clock_latch = '1' then
                data_cycle_count    := 0;
                transceiver_state   <= Idle;
                endat_emulate_state <= Idle;
              end if;
            end if;

          when others =>

        end case;

      when others =>

    end case;
  end if;
  end process Endat_test;


   strobe: process
   begin
     sStrobe <= '0', '1' after 200 ns, '0' after 430 ns;  
     wait for 200 us;
   end process strobe;

   strobe_SPI: process
   begin
     sStrobe_A <= '0', '1' after 200 ns, '0' after 430 ns;  
     wait for 1 ms;
   end process strobe_SPI;
  
    uS_strobe: process
    begin
      OneuS_sStrobe <= '0', '1' after 1 us, '0' after 1.020 us;  
      wait for 1 us;
    end process uS_strobe;

    mS_strobe: process
    begin
      OnemS_sStrobe <= '0', '1' after 1 ms, '0' after 1.00002 ms;  
      wait for 1.0001 ms;
    end process mS_strobe;

  Ten_mS_strobe: process
    begin
      Ten_mS_sStrobe <= '0', '1' after 10 ms, '0' after 10.00002 ms;  
      wait for 10.0001 ms;
    end process Ten_mS_strobe;

  Twenty_mS_strobe: process
    begin
      Twenty_mS_sStrobe <= '0', '1' after 20 ms, '0' after 20.00002 ms;  
      wait for 20.0001 ms;
    end process Twenty_mS_strobe;

  Fifty_mS_strobe: process
    begin
      Fifty_mS_sStrobe <= '0', '1' after 50 ms, '0' after 50.00002 ms;  
      wait for 50.0001 ms;
    end process Fifty_mS_strobe;  

  Hun_mS_strobe: process
    begin
      Hun_mS_sStrobe <= '0', '1' after 100 ms, '0' after 100.00002 ms;  
      wait for 100.0001 ms;
    end process Hun_mS_strobe;   

    Sec_strobe: process
    begin
      Sec_sStrobe <= '0', '1' after 1000 ms, '0' after 1000.00002 ms;  
      wait for 1000.0001 ms;
    end process Sec_strobe;    
 
  Gen_Clock: process
  begin
    newClk <= '0', '1' after 40 ns;
    wait for 80 ns;
  end process Gen_Clock;
  
  Do_reset: process(sClok)
  begin
    if (sClok'event and sClok='1') then 
      if sCnt = 7 then
        sCnt <= sCnt;
      else 
        sCnt <= sCnt + 1;

        case sCnt is
          when 0 => snrst <= '0';
          when 1 => snrst <= '0';
          when 2 => snrst <= '0';
          when 3 => snrst <= '0';
          when 4 => snrst <= '0';
          when others => snrst <= '1';
        end case;

      end if;
   
  end if;
  end process;

end Archtest_bench;

