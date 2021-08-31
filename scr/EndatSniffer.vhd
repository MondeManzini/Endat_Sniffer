--------------------------------------------------------------------------------
-- EnDat Sniffer
-- Writen by Glen Taylor, assisted by Pieter Pretorius
-- 
-- The Endat sniffer module is used to sniff the EnDat communication betweeen 
-- the ACU and the Heidenhain 2510 Shaft Encoder on the MeerKat Antenna.
-- This module can be used to Sniff any EnDat encode using the differntail 
-- sniffer hardware designed to read both the Clock anf Data diferentail line.
--
-- Version Number : A            00.00.01
-- Date           : 2021-05-06
-- Release Date   : XXXX-XX-XX
-- Last Updated by : Glen Taylor

-- Version Number : 00.00.02
-- Date           : 2021-07-15
-- Release Date   : XXXX-XX-XX
-- Last Updated by : Monde Manzini
--                  Fixed all syntax errors
--                  Added initialization on some signals

--------------------------------------------------------------------------------

LIBRARY ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

entity EndatSniffer is
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
  clk                  : in  std_logic;     -- FPGA 50MHz clock
  reset_n              : in  std_logic;     -- FPGA Reset
  endat_clk            : in  std_logic;     -- Clock input from the EnDat sniffer Hardware
  endat_data           : in  std_logic;     -- Data input from the EnDat sniffer Hardware
  endat_enable         : in  std_logic;     -- request to sniff EnDat tranmission
  -- Input / Output ports
  endat_mode_out       : out std_logic_vector(8 downto 0);  -- All data  -- 8 downto 0 originally
  endat_Position_out   : out std_logic_vector(31 downto 0);  -- All data -- Updated to 33 downto 0
  endat_Data_1_out     : out std_logic_vector(31 downto 0);  -- All data
  endat_Data_2_out     : out std_logic_vector(31 downto 0);  -- All data
  data_cnt             : out integer; 
  -- Output ports 
  endat_data_Ready     : out std_logic
 ); 
end EndatSniffer;

architecture Arch_DUT of EndatSniffer is

  type state_endat_sniffer   is (Idle, Wait_Start, Read_Data, End_Message);                  -- type of state machine. 
  signal Endat_Sniffer_State    : state_endat_sniffer; 
  type Read_data_states   is (Dummy_State, Read_Mode, Wait_Mode_Cnt, Read_Position, Read_data_1, Read_data_2, Send_data);                  -- type of state machine. 
  signal Read_data_state    : Read_data_states;

  signal  endat_clk_enable    : std_logic;

  signal endat_clk_cnt        : std_logic;
  signal endat_in_done        : std_logic;
  signal endat_clk_done       : std_logic;
  signal endat_Data_Ready_i   : std_logic;
  signal NumBit_1             : integer;
  signal NumBit_2             : integer; 

  signal data_1_cnt           : integer range 0 to 32;
  signal data_2_cnt           : integer range 0 to 32;
  signal mode_cnt             : integer range 0 to 32;
  signal position_cnt         : integer range 0 to 34;

  -- Temposrary vectors to read the position and Data
  --signal  mode                : std_logic_vector (9 downto 0); GT to confirm
  signal  mode                : std_logic_vector (8 downto 0);   -- 8 downto 0 
  signal  position            : std_logic_vector (31 downto 0);  -- Updated to std_logic_vector(33 downto 0)
  signal  data_1              : std_logic_vector (31 downto 0);
  signal  data_2              : std_logic_vector (31 downto 0);
  

begin
   
endat_protocol: process (clk, reset_n)

   -- variable clk_cnt   :  integer range 0 to 32;
   variable clock_cnt      : integer range 0 to 5;

begin
if reset_n = '0' then
      Endat_Sniffer_State     <=  idle;
      endat_Data_Ready_i      <=  '0';
      endat_clk_enable        <=  '0';
      endat_clk_cnt           <=  '0';
      endat_in_done           <=  '0';
      endat_clk_done          <=  '0';
      mode                    <=  (OTHERS => '0');
      position                <=  (OTHERS => '0');
      data_1                  <=  (OTHERS => '0'); 
      data_2                  <=  (OTHERS => '0');
      endat_mode_out          <=  (OTHERS => '0');
      endat_Position_out      <=  (OTHERS => '0');
      endat_Data_1_out        <=  (OTHERS => '0');
      endat_Data_2_out        <=  (OTHERS => '0');
      -----
      clock_cnt := 0;
elsif(clk'EVENT AND clk = '1') THEN

   case Endat_Sniffer_State is
      when Idle =>
         endat_Data_Ready    <=  '0';       
         if endat_enable = '1' then
            Endat_Sniffer_State   <= Wait_Start; 
         end if;
             
      when wait_start =>
         if endat_clk = '0' then  -- Start Detected (endat_data = '0' and ??)
            Endat_Sniffer_State  <= Read_Data;     -- goto read data
            --Read_data_state      <= Read_Mode;           -- ensure the mode is read first
            Read_data_state      <= Dummy_State;           -- ensure the mode is read first
            mode                 <=  (OTHERS => '0');    -- Clear Regster and insert the first zero in mode bit 9.
            position             <=  (OTHERS => '0');    -- Clear Regster
            data_1               <=  (OTHERS => '0');    -- Clear Regster 
            data_2               <=  (OTHERS => '0');    -- Clear Regster
            mode_cnt             <=  7;                  -- Clear mode bit cnt  -- 8 originally 

            position_cnt         <=  31;                  -- Clear mode bit cnt -- 33 originally
            data_1_cnt           <=  30;                  -- Clear mode bit cnt
            data_2_cnt           <=  30;                  -- Clear mode bit cnt
            endat_clk_done       <= '0';                 -- clear done Flag
         end if;

      when Read_Data =>
-- Start of Read_data_states
         case Read_data_state is     
         
         -- Added Dummy_State
            when Dummy_State => 
               if endat_clk = '1' and endat_clk_done = '0' then   -- First rising edge
                  endat_clk_done <= '1';     
                  clock_cnt      := clock_cnt + 1;
               elsif endat_clk = '0' and endat_clk_done = '1' then  
                  endat_clk_done <= '0';
               end if;

               if clock_cnt = 3 then
                  clock_cnt       := 0;
                  Read_data_state <= Read_Mode;
               end if;
                                     
            when Read_Mode =>
                  if endat_clk = '0' and endat_clk_done = '1' and mode_cnt > 0 then   -- endat_clk = '1' and endat_clk_done 0 original
                     mode(mode_cnt)  <= endat_data;
                     mode_cnt        <= mode_cnt - 1;
                     endat_clk_done  <= '0';             -- endat_clk_done  <= '1';
                     Read_data_state <= Wait_Mode_Cnt; 
                  elsif endat_clk = '1' and endat_clk_done = '0' then
                     endat_clk_done  <= '1';
                     --Read_data_state <= Wait_Mode_Cnt; 
                  end if;     

            when Wait_Mode_Cnt =>
                  -- Confirm with Glen adding of Wait_Mode_Cnt state
                  if (mode_cnt = 0) then
                     If endat_clk = '1' and endat_data = '0' and endat_clk_done = '0' then         -- Has been swapped around
                        endat_mode_out       <= mode;
                        endat_clk_done       <= '1';
                     elsif endat_clk = '0' and endat_data = '1' and endat_clk_done  = '1' then     -- Has been swapped around
                        position(0)       <= '1'; --insert start bit
                        --position_cnt      <= 1; -- Why?
                        endat_clk_done    <= '0';  
                        --Read_data_state   <= Read_Position; 
                     -- Added extra if statement
                     elsif endat_clk = '1' and endat_data = '1' then 
                        Read_data_state   <= Read_Position; 
                     end if;
                  else
                     Read_data_state   <= Read_Mode;
                  end if;

            when Read_Position =>
               if (position_cnt = 0) then
                  endat_Position_out   <= position;                 
                  If endat_clk = '1' and endat_data = '1' then
                     Read_data_state   <= Send_data;
                  elsif endat_clk = '1' and endat_data = '0' then                      
                     Read_data_state   <= Read_data_1;
                     endat_clk_done    <= '0';
                  end if;
               elsif endat_clk = '1' and endat_clk_done = '0' then   
                  position(position_cnt)  <= endat_data;
                  position_cnt            <= position_cnt - 1;
                  endat_clk_done          <= '1';
               elsif endat_clk = '0' and endat_clk_done = '1' then
                  endat_clk_done          <= '0';
               end if;      

            when Read_data_1 =>
               if (data_1_cnt = 0) then
                  endat_data_1_out     <= data_1;                 
                  if endat_clk = '1' and endat_data = '1' then
                     Read_data_state   <= Send_data;
                  elsif endat_clk = '1' and endat_data = '0' then                      
                     Read_data_state   <= Read_data_2;
                     endat_clk_done    <= '0'; 
                  end if;
               elsif endat_clk = '1' and endat_clk_done = '0' then   
                  data_1(data_1_cnt)  <= endat_data;
                  data_1_cnt          <= data_1_cnt - 1;
                  endat_clk_done      <= '1';
               elsif endat_clk = '0' and endat_clk_done = '1' then
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
               elsif endat_clk = '0' and endat_clk_done = '1' then
                  endat_clk_done    <= '0';
               end if;      
                 
            when Send_data => 
               Endat_Sniffer_State   <= End_Message;
               endat_clk_done        <= '0';
               endat_Data_Ready      <= '1';
         end case;
-- end of Read_data_states 

      when End_Message =>
         endat_clk_done        <= '0';
         endat_Data_Ready      <= '0';
         if endat_clk = '1' and endat_data = '1' then
            -- Endat_Sniffer_State   <= end_message; GT to confirm
            Endat_Sniffer_State   <= idle;
         end if;
   end case;
-- end of Endat_Sniffer_State    
end if;
end process endat_protocol;  
end Arch_DUT;
    
    
    
    
    
      