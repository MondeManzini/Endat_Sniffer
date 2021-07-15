--------------------------------------------------------------------------------
-- EnDat Sniffer
-- Writen by Glen Taylor, assisted by Pieter Pretorius
-- 
-- The Endat sniffer module is used to sniff the EnDat communication betweeen 
-- the ACU and the Heidenhain 2510 Shaft Encoder on the MeerKat Antenna.
-- This module can be used to Sniff any EnDat encode using the differntail 
-- sniffer hardware designed to read both the Clock anf Data diferentail line.
--
-- Version Number : A
-- Date           : 202-05-06
-- Release Date   : XXXX-XX-XX
-- Last Updated by : Glen Taylor
--------------------------------------------------------------------------------

LIBRARY ieee;
use ieee.std_logic_1164.all;

entity EndatSniffer is
  generic 
  ( 
    MODE_BITS          : integer   :=  8;    -- Width of the mode data
    POS_BITS           : integer   :=  26;   -- Width of Position
    ADD_BITS           : integer   :=  25;   -- Width of Additional Data
    CRC_BITS           : integer   :=  5;    -- Width of CRC 
  );      

 port
 (
  -- Input ports
  clk                  : in  std_logic;     -- FPGA 50MHz clock
  reset_n              : in  std_logic;     -- FPGA Reset
  endat_clk            : in  std_logic;     -- Clock input from the EnDat sniffer Hardware
  endat_data           : in  std_logic;     -- Data input from the EnDat sniffer Hardware
  endat_enable         : in  std_logic;     -- request to sniff EnDat tranmission
  -- Input / Output ports
  endat_mode_out       : out std_logic_vector(8 downto 0);  -- All data
  endat_Position_out   : out std_logic_vector(31 downto 0);  -- All data
  endat_Data_1_out     : out std_logic_vector(31 downto 0);  -- All data
  endat_Data_2_out     : out std_logic_vector(31 downto 0);  -- All data
  data_cnt             : out integer; 
  -- Output ports 
  endat_data_Ready  : out std_logic
 );
end EndatSniffer;

architecture Sniffer of EndatSniffer is

  type state_endat_sniffer   is (idle, wait_start, read_data);                  -- type of state machine. 
  signal Endat_Sniffer_State    : state_endat_sniffer; 
  type Read_data_state   is (read_mode, read_data, Send_data);                  -- type of state machine. 
  signal Read_data_states    : Read_data_state;

  signal  endat_clk_enable      : std_logic;

  signal  endat_clk_cnt         : std_logic;
  signal  endat_in_done         : std_logic;
  signal  endat_clk_done        : std_logic;
  signal  endat_Data_Ready_i    : std_logic;
  signal  NumBit_1              : integer;
  signal  NumBit_2              : integer;  
  -- Temposrary vectors to read the position and Data
  signal  mode                : std_logic_vector (9 downto 0);
  signal  position            : std_logic_vector (31 downto 0);
  signal  data_1              : std_logic_vector (31 downto 0);
  signal  data_2              : std_logic_vector (31 downto 0);
  

begin
   
  -- Process Statement (optional)
--     variable clk_cnt   :   integer range 0 to 32;
  begin
    if reset_n = '0' then
       Endat_Sniffer_State     <=  idle;
       endat_Data_Ready_i      <=  '0';
       mode                    <=  (OTHERS => '0');
       position                <=  (OTHERS => '0');
       data_1                  <=  (OTHERS => '0'); 
       data_2                  <=  (OTHERS => '0');
      
  elsif (rising_edge(clk)) then

    case Endat_Sniffer_State is
    when idle =>
        endat_Data_Ready    <=  '0';       
        if endat_enable = '1' then
           Endat_Sniffer_State   <= wait_start; 
        end if;
             
    when wait_start =>
         if endat_clk = '0' then  -- Start Detected (endat_data = '0' and ??)
            Endat_Sniffer_State   <= read_data;     -- goto read data
            Read_data_state <= Read_mode;           -- ensure the mode is read first
            mode            <=  (OTHERS => '0');    -- Clear Regster and insert the first zero in mode bit 9.
            position        <=  (OTHERS => '0');    -- Clear Regster
            data_1          <=  (OTHERS => '0');    -- Clear Regster 
            data_2          <=  (OTHERS => '0');    -- Clear Regster
            mode_cnt        <=  8;                  -- Clear mode bit cnt
            Position_cnt    <=  33;                  -- Clear mode bit cnt
            data_1_cnt      <=  30;                  -- Clear mode bit cnt
            data_2_cnt      <=  30;                  -- Clear mode bit cnt
            endat_clk_done  <= '0';                 -- clear done Flag
         end if;
         
    when read_data =>
-- Start of Read_data_states
         case Read_data_states is                               
            when Read_mode =>
                if endat_clk = '1' and endat_clk_done = '0' then   
                    mode(mode_cnt)  <= endat_data;
                    mode_cnt        <= mode_cnt - 1;
                    endat_clk_done  <= '1';
                elsif endat_clk = '0' and endat_clk_done = '1' and mode_cnt > 0 then
                      endat_clk_done  <= '0';
                end if;      
                 
                if (mode_cnt = 0) then
                   If endat_clk   = '0' and endat_data = '0'and endat_clk_done  = '1' then
                      endat_mode_out       <= mode;
                      endat_clk_done       <= '0';
                   elsif endat_clk   = '1' and endat_data = '1'and endat_clk_done  = '0' then  
                      position(0)       <= '1'; --insert strat bit
                      position_cnt      <= 1;
                      endat_clk_done    <= '0';
                      Read_data_state   <= Read_Position; 
                end if;
 
            when Read_Positon =>
                if (position_cnt = 0) then
                   endat_Position_out   <= position;                 
                   If endat_clk = '1' and endat_data = '1' then
                      Read_data_state   <= Send_data;
                   elsif endat_clk = '1' and endat_data = '0' then                      
                         Read_data_state <= Read_data_1;
                         endat_clk_done       <= '0';
                   end if
                elsif endat_clk = '1' and endat_clk_done = '0' then   
                    position(position_cnt)  <= endat_data;
                    position_cnt            <= position_cnt - 1;
                    endat_clk_done          <= '1';
                elsif endat_clk = '0' and endat_clk_done = '1'then
                      endat_clk_done        <= '0';
                end if;      

            when Read_data_1 =>
                if (data_1_cnt = 0) then
                   endat_data_1_out     <= data_1;                 
                   if endat_clk = '1' and endat_data = '1' then
                      Read_data_state      <= Send_data;
                   elsif endat_clk = '1' and endat_data = '0' then                      
                         Read_data_state      <= Read_data_2;
                         endat_clk_done       <= '0'; 
                   end if;
                elsif endat_clk = '1' and endat_clk_done = '0' then   
                    data_1(data_1_cnt)  <= endat_data;
                    data_1_cnt          <= data_1_cnt - 1;
                    endat_clk_done      <= '1';
                elsif endat_clk = '0' and endat_clk_done = '1'then
                      endat_clk_done    <= '0';
                end if;      
  
            when Read_data_2 =>
                if (data_2_cnt = 0) then                  
                   if endat_clk = '1' and endat_data = '0' then
                      Read_data_state      <= Send_data;
                      endat_data_2_out     <= data_2;
                      endat_clk_done       <= '0'; 
                   end if;
                elsif endat_clk = '1' and endat_clk_done = '0' then   
                    data_2(data_2_cnt)  <= endat_data;
                    data_2_cnt          <= data_2_cnt - 1;
                    endat_clk_done      <= '1';
                elsif endat_clk = '0' and endat_clk_done = '1'then
                      endat_clk_done    <= '0';
                end if;      
                 
             when Send_data => 
                  Endat_Sniffer_State   <= end_message;
                  endat_clk_done        <= '0';
                  endat_Data_Ready      <= '1';
                  

            end case;
-- end of Read_data_states 
        when end_message =>
             endat_clk_done        <= '0';
             endat_Data_Ready      <= '0';
             if endat_clk = '1' and endat_data = '1' then
                Endat_Sniffer_State   <= end_message;
             end if;
    end case;
-- end of Endat_Sniffer_State    
    
    
    
    
    
      