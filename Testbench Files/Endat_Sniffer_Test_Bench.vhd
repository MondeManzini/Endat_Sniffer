-------------------------------------------------------------------------------
-- DESCRIPTION
-- ===========
--
-- This file contains  modules which make up a testbench
-- suitable for testing the "device under test".
---- Version Number : A            00.00.01
-- Date           : 2021-05-06
-- Release Date   : XXXX-XX-XX
-- Last Updated by : Monde Manzini

-- Version Number : B            00.00.02
-- Date           : 2021-08-31
-- Release Date   : XXXX-XX-XX
-- Last Updated by : Monde Manzini
--                  Removed delay betweeen clock signal message breaks

-- Version Number : C            00.00.03
-- Date           : 2021-09-02
-- Release Date   : XXXX-XX-XX
-- Last Updated by : Monde Manzini
--                  Pulled the clock signal high at the end of the message
--                  Pulled the data signal high at the end of the message
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
signal endat_mode_out_i                 : std_logic_vector(8 downto 0);         
signal endat_Position_out_i             : std_logic_vector(31 downto 0);     
signal endat_Data_1_out_i               : std_logic_vector(31 downto 0);
signal endat_Data_2_out_i               : std_logic_vector(31 downto 0);         
signal endat_data_ready_i               : std_logic;
signal data_cnt_i                       : integer;
signal UART_TXD_i                       : std_logic;

------------ Test Signals ---------------------
signal display_version_lock             : std_logic;
signal EndatSniffer_Version_Ready_i     : std_logic;
signal EndatSniffer_Version_Name_i      : std_logic_vector(255 downto 0);
signal EndatSniffer_Version_Number_i    : std_logic_vector(63 downto 0);
signal Version_EndatSniffer             : std_logic_vector(7 downto 0);  
signal EndatSniffer_Version_Request_i   : std_logic;
signal EndatSniffer_Version_Load_i      : std_logic;
signal Endat_Request_i                  : std_logic;
signal mode_data_i                      : std_logic_vector(5 downto 0); 
signal pos_data_i                       : std_logic_vector(31 downto 0); 
signal add_data_1_i                     : std_logic_vector(31 downto 0);
signal add_data_2_i                     : std_logic_vector(31 downto 0);        
signal clock_latch                      : std_logic;
signal num_clks_latch                   : integer range 0 to 100;
signal stop_clock                       : std_logic;
signal mode_enable                      : std_logic;
signal endat_tx_i                       : std_logic;
signal pos_enable                       : std_logic;
signal mode_done_bit                    : std_logic;
signal pos_done_bit                     : std_logic;
signal add_data_1_enable                : std_logic;
signal add_data_1_done_bit              : std_logic;
signal add_data_2_enable                : std_logic;
signal add_data_2_done_bit              : std_logic;
signal crc_enable                       : std_logic;
signal dummy_enable                     : std_logic;
signal end_message                      : std_logic;
signal end_mode                         : std_logic;
signal add_test_data                    : std_logic_vector(31 downto 0);
signal mod_test_data                    : std_logic_vector(5 downto 0);
signal pos_test_data                    : std_logic_vector(31 downto 0);

----------------------------------------------------------------------
-- Baud Rate for Mux Signals and Component
----------------------------------------------------------------------
signal baud_rate_i                            : integer range 0 to 7;

component Baud_Rate_Generator is
  port (
    Clk                                 : in  std_logic;
    RST_I                               : in  std_logic;
    baud_rate                           : in  integer range 0 to 7;
    Baud_Rate_Enable                    : out std_logic  
    );
end component Baud_Rate_Generator;

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
type endat_emulate_states is (load_params, Idle, op_state, t_low_state, t_high_state, tm_recov, 
                              tr_recov);
--type endat_emulate_states is (request_data, start_cond, test_select, send_mode, read_pos, 
--                              send_data, read_data_1, read_data_2, read_data_3, read_data_4);

type mode_states is (Idle, mode_gen, mode_write);
type position_states is (Idle, pos_data_write, next_pos_bit);
type add_data_1_states is (Idle, add_data_1_write, add_data_1_gen, add_data_1_read, check_data_1_res);
type add_data_2_states is (Idle, add_data_2_write, add_data_2_gen, add_data_2_read, check_data_2_res);

signal endat_emulate_state           : endat_emulate_states;
-- signal transceiver_state             : transceiver_states;
-- signal clock_gen_state               : clock_gen_states;
signal mode_state                    : mode_states;  
signal position_state                : position_states;  
signal add_data_1_state                : add_data_1_states;
signal add_data_2_state                : add_data_2_states;

signal  sClok,snrst,sStrobe,PWM_sStrobe,newClk,Clk : std_logic := '0';
signal  stx_data,srx_data : std_logic_vector(3 downto 0) := "0000";
signal  sCnt         : integer range 0 to 7 := 0;
signal  cont         : integer range 0 to 100;  
signal  oClk,OneuS_sStrobe, Quad_CHA_sStrobe, Quad_CHB_sStrobe,OnemS_sStrobe,cStrobe,sStrobe_A,
        Ten_mS_sStrobe,Twenty_mS_sStrobe, Fifty_mS_sStrobe, Hun_mS_sStrobe, Sec_sStrobe, OnenS_sStrobe : std_logic;

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
variable clk_pls_trac       : integer range 0 to 120;
variable clk_div_load_cnt   : integer range 0 to 50;
variable clk_div_load       : integer range 0 to 50;
variable pos_div_load       : integer range 0 to 50;
variable num_clks           : integer range 0 to 50;
variable data_1_cycle_count   : integer range 0 to 33;
variable data_2_cycle_count   : integer range 0 to 33;
variable add_data_1_div_load  : integer range 0 to 50;
variable add_data_2_div_load  : integer range 0 to 50;
variable count_tm             : integer range 0 to 1500;
variable count_tr             : integer range 0 to 25;
variable var_tm               : integer range 0 to 200;
variable tm_cnt               : integer range 0 to 5;

begin
  if RST_I_i = '0' then
    endat_tx_i          <= '0';
    endat_clk_i         <= '1';
    endat_data_i        <= '0';
    Request_Data_cnt    := 0;
    clock_cnt           := 0;
    mode_cycle_count    := 8;
    pos_cycle_count     := 0;
    data_cycle_count    := 0;
    data_1_cycle_count  := 0;
    data_2_cycle_count  := 0;
    add_data_cnt        := 0;
    count_tm            := 0;
    count_tr            := 0; 
    add_data_1_enable       <= '0';
    add_data_1_done_bit     <= '0';
    add_data_2_enable       <= '0';
    add_data_2_done_bit     <= '0';
    add_test_data           <= (OTHERS => '0');
    clk_div_load_cnt    := 0;
    clk_div_load        := 0;
    pos_div_load        := 0;
    clk_pls_trac        := 0;
    num_clks            := 0;
    num_clks_latch      <= 0;
    clock_latch         <= '0';
    stop_clock          <= '0';
    mode_enable         <= '0';
    dummy_enable        <= '0';
    pos_enable          <= '0';
    pos_done_bit        <= '0';
    mode_done_bit       <= '0';
    data_cnt            := 0;
    pos_data_i          <= (OTHERS => '0');
    mode_data_i         <= (OTHERS => '0');
    endat_emulate_state <= load_params;

  elsif CLK_I_i'event and CLK_I_i = '1' then  

    ------------------------------------------------------------
    ----------------ENDAT Emulating State-----------------------
    ------------------------------------------------------------

    case endat_emulate_state is 
      when load_params =>
        mode_data_i         <= b"000111";       -- Mode 1 Command 07 000111
        pos_data_i          <= x"89384756";     -- Position Command 7E1FC3F8
        clk_div_load        := 13;              -- 12.5 counts
        mode_cycle_count    := 6;               -- 6 Mode Bits
        pos_div_load        := 32;              -- Position Number of Bits - 28 Bits for RCN 2510 Encoder
        add_data_1_i        <= x"FE1FC3F8";     -- Additional Data 1 Command 7E1FC3F8
        add_data_2_i        <= x"7E1FC3F8";     -- Additional Data 1 Command 7E1FC3F8
        add_data_1_div_load := 30;              -- Position Number of Bits
        add_data_2_div_load := 30;              -- Position Number of Bits
        endat_emulate_state <= Idle;            
        
      when Idle => 
        clock_cnt         := 0;
        pos_cycle_count   := pos_div_load;
        clock_latch       <= '0';
        endat_data_i      <= '1'; 
        endat_clk_i       <= '1'; 
        count_tm            := 0;
        count_tr            := 0; 
        mode_done_bit     <= '0';
        end_message       <= '0';
        crc_enable        <= '0';
        mode_enable       <= '0';
        pos_enable        <= '0';
        mod_test_data     <= b"000000";
        pos_test_data     <= X"00000000";
        --------- TX Generator -----------
        if Request_Data_cnt = 650 then  -- 100 ms Retrieve 0 for 5000_000
          Request_Data_cnt  := 0;
          endat_tx_i        <= '1';     
        else
          Request_Data_cnt  := Request_Data_cnt + 1;
          endat_tx_i    <= '0';
        end if;
        --------- End of TX Generator -----------

        if endat_tx_i = '1' then                 
          tm_cnt  := tm_cnt + 1;
          endat_emulate_state <= t_low_state;
        end if;     

        if tm_cnt = 4 then
          tm_cnt := 0;
        --else
          --endat_emulate_state <= t_low_state;
        end if;

        -- Test from different t_m times
        case tm_cnt is
          when 1 =>
            var_tm := 62;

          when 2 =>
            var_tm := 125;

          when 3 =>
            var_tm := 187;

          when others =>
            var_tm := 0;

        end case;

      when t_low_state =>
        if clock_cnt = clk_div_load then         
          endat_clk_i         <= '0';               -- Falling edge
          clock_cnt           := 0;
          clock_latch         <= '1';
          if num_clks < 9 then                     -- Mode message
            num_clks            := num_clks + 1;
            endat_emulate_state <= op_state;
          elsif num_clks > 15 then                 
            if (pos_done_bit = '1') then             -- Position operation   
              num_clks            := num_clks + 1;
              pos_done_bit        <= '0';
              endat_emulate_state <= op_state;
            elsif crc_enable = '1' then                   -- Last two CRC bits
              crc_enable          <= '0';
              num_clks            := num_clks + 1;
              endat_emulate_state <= op_state;
            else
              endat_emulate_state <= op_state;
            end if;
          else
            endat_emulate_state <= op_state;
          end if;
        else
          clock_cnt           := clock_cnt + 1;
        end if;   

      when op_state =>                              -- Decides which operation
        if num_clks <= 2 then                       -- First two dummy bits
          endat_data_i        <= '1';
          dummy_enable        <= '1'; 
          endat_emulate_state <= t_high_state;
        elsif num_clks > 2 and num_clks < 9 then    -- Mode operation
          mode_enable         <= '1';
          endat_emulate_state <= t_high_state;
        elsif (num_clks = 9) then                   -- Bit 1 of Last two mode dummy bits
          dummy_enable        <= '1';  
          endat_data_i        <= '0';
          endat_emulate_state <= t_high_state;
        elsif (num_clks = 10) then                  -- Bit 2 of Last two mode dummy bits
          dummy_enable        <= '1';  
          endat_data_i        <= '1';
          endat_emulate_state <= t_high_state;
        elsif num_clks > 10 and num_clks < 16 then  -- Clock stretching 5 clocks
          dummy_enable        <= '1';  
          endat_data_i        <= '0';
          endat_emulate_state <= t_high_state;
          elsif num_clks > 52 and num_clks < 78 then  -- Additional Data 1 operation
          add_data_1_enable   <= '1';
          endat_emulate_state <= t_high_state;
        elsif num_clks > 77 and num_clks < 83 then  -- Last 5 CRC Additional Data 1 bits
          add_data_1_enable          <= '1';
          endat_emulate_state <= t_high_state;
          elsif num_clks = 83 then                   -- 1 dummy bit for additional data 1
          dummy_enable        <= '1'; 
          endat_emulate_state <= t_high_state; 
        elsif num_clks > 83 and num_clks < 110 then  -- Additional Data 2 operation
          add_data_2_enable   <= '1';
          endat_emulate_state <= t_high_state;
        elsif num_clks > 109 and num_clks < 114 then  -- Last 5 CRC Additional Data 2 bits
          add_data_2_enable          <= '1';
          endat_emulate_state <= t_high_state;
        elsif num_clks = 114 then                   -- End of message                
          end_message         <= '1';  
          endat_emulate_state <= t_high_state;
        else
          endat_emulate_state <= t_high_state;
        end if;      

      when t_high_state =>
        if clock_cnt = clk_div_load then         
          endat_clk_i <= '1';                         -- Rising edge
          clock_cnt   := 0;
          if mode_done_bit = '1' then            -- mode state
            mode_done_bit       <= '0';
            endat_emulate_state <= t_low_state;
          elsif dummy_enable = '1' then               -- Last two mode dummy bits
            dummy_enable        <= '0';  
            num_clks            := num_clks + 1;
            endat_emulate_state <= t_low_state;
          elsif num_clks = 16 then                    
            pos_enable          <= '1'; 
            endat_data_i        <= '1';                -- Position Start Bit  
            endat_emulate_state <= t_low_state;
          elsif num_clks > 16 and num_clks < 19 then    -- F1 and F2 Bits                
            pos_enable          <= '1'; 
            endat_data_i        <= '0';                -- Position Start Bit  
            endat_emulate_state <= t_low_state;
          elsif num_clks > 18 and num_clks < 48 then   -- Position operation
            pos_enable          <= '1';
            endat_emulate_state <= t_low_state;
          elsif num_clks > 47 and num_clks < 53 then   -- Position 5 CRC Position bits
            crc_enable          <= '1';  
            endat_data_i        <= '1';
            endat_emulate_state <= t_low_state;       -- 1 dummy clock bit before data 1
          elsif end_message = '1' then 
            end_message         <= '0';
            num_clks            := 0;
            endat_emulate_state <= tm_recov;       -- End of message
            endat_data_i        <= '1';               -- Pull data high on end
            endat_clk_i         <= '1';               -- Pull clock high on end
          end if;
        else
          clock_cnt             := clock_cnt + 1;
        end if; 

      when tm_recov => 
        if count_tm = var_tm then
          count_tm            := 0;
          endat_emulate_state <= tr_recov;
        else
          count_tm            := count_tm + 1;
          endat_data_i        <= '1';
        end if;

      when tr_recov => 
        if count_tr = 25 then
          count_tr            := 0;
          endat_emulate_state <= load_params;
          endat_data_i        <= '1';
        else
          count_tr            := count_tr + 1;
          endat_data_i        <= '0';
        end if;

    end case;         -- End Endat case

-------------------------------------------------
---------------- Mode State ---------------------
-------------------------------------------------
    case mode_state is
      when Idle =>
        if mode_enable = '1' then
          mode_state <= mode_gen;
        end if;

      when mode_gen =>
        mode_enable       <= '0';
        mode_state        <= mode_write;
        mode_cycle_count  := mode_cycle_count - 1;

      when mode_write =>
        if mode_cycle_count > 0 then
          endat_data_i  <= mode_data_i(mode_cycle_count);  -- LSB first (0)
          mode_done_bit      <= '1';
          mode_state    <= Idle;
        elsif mode_cycle_count = 0 and (endat_mode_out_i > x"00" & '0') then
          endat_data_i  <= '0';
          mode_done_bit <= '1';
          mode_state    <= Idle;
        end if;
    end case; -- End mode states

-------------------------------------------------
-------------- Position State -------------------
-------------------------------------------------
    case position_state is
      when Idle =>
        if pos_enable = '1' then
          position_state  <= pos_data_write; 
        end if;

      when pos_data_write =>
        pos_enable <= '0';
        if pos_cycle_count < pos_div_load then
          endat_data_i    <= pos_data_i(pos_cycle_count);
          position_state  <= next_pos_bit;
          pos_done_bit    <= '1';
        elsif pos_cycle_count = (pos_div_load + 1) then
          pos_done_bit    <= '1';
          position_state  <= Idle;
          pos_cycle_count := 0;
          endat_data_i    <= '1';
        --else
        --  position_state <= next_pos_bit;
        end if;

      when next_pos_bit =>
        pos_cycle_count := pos_cycle_count + 1;
        position_state  <= Idle;

    end case; -- End position state

    -------------------------------------------------
    -------------- Additional Data 1 State ----------
    -------------------------------------------------
    case add_data_1_state is
      when Idle =>
        if add_data_1_enable = '1' then
          add_data_1_state  <= add_data_1_gen; 
        end if;

      when add_data_1_gen =>
        add_data_1_enable <= '0';
        add_data_1_state  <= add_data_1_write;
        data_1_cycle_count  := data_1_cycle_count - 1;

    when add_data_1_write =>
      endat_data_i      <= add_data_1_i(data_1_cycle_count);  -- LSB first (0)                     
      add_data_1_state  <= add_data_1_read;

    when add_data_1_read =>
      add_test_data(data_1_cycle_count) <= endat_data_i;
      if data_1_cycle_count = 0 then
        add_data_1_state  <= check_data_1_res;
      else
        add_data_1_done_bit <= '1';
        add_data_1_state    <= Idle;
      end if;

    when check_data_1_res =>
      if add_test_data = add_data_1_i then
        report "The Additional Data 1 test Passed." severity note;
        add_data_1_done_bit   <= '1';
        add_data_1_state      <= Idle;
      else
        report "The Additional Data 1 test Failed" severity note;
        add_data_1_done_bit   <= '1';
        add_data_1_state      <= Idle;
      end if;
    end case;               -- End Additional Data 1 

    -------------------------------------------------
    -------------- Additional Data 2 State ----------
    -------------------------------------------------
    case add_data_2_state is
      when Idle =>
        if add_data_2_enable = '1' then
          add_data_2_state  <= add_data_2_gen; 
        end if;

      when add_data_2_gen =>
        add_data_2_enable   <= '0';
        add_data_2_state    <= add_data_2_write;
        data_2_cycle_count  := data_2_cycle_count - 1;

    when add_data_2_write =>
      endat_data_i      <= add_data_2_i(data_2_cycle_count);  -- LSB first (0)                     
      add_data_2_state  <= add_data_2_read;

    when add_data_2_read =>
        add_test_data(data_2_cycle_count) <= endat_data_i;
      if data_2_cycle_count = 0 then
        add_data_2_state    <= check_data_2_res;
      else
        add_data_2_done_bit <= '1';
        add_data_2_state    <= Idle;
      end if;

    when check_data_2_res =>
      if add_test_data = add_data_2_i then
        report "The Additional Data 1 test Passed." severity note;
        add_data_2_done_bit   <= '1';
        add_data_2_state      <= Idle;
      else
        report "The Additional Data 1 test Failed" severity note;
        add_data_2_done_bit   <= '1';
        add_data_2_state      <= Idle;
      end if;
    end case;         -- End Additional Data 2 case
 
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

   nS_strobe: process
    begin
      OnenS_sStrobe <= '0', '1' after 1 ns, '0' after 1.1 ns;  
      wait for 1 ns;
    end process nS_strobe;
  
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

