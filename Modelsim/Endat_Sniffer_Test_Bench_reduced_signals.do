onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 25 {Main Clock and Reset}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/CLK_I
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/RST_I
add wave -noupdate -divider {Real Time Clock Handler}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/PPS_in
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Seconds_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Minutes_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Hours_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Day_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Date_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Month_Century_out
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Year_out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Ready
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Slave_Address_i
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Slave_Address_Out
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/Busy
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/i2c_Controller_State
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/i2c_Intialization_State
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/i2c_ReadData_State
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/I2C_Control/Count
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/I2C_Control/Config_Count
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Handler_1/I2C_Control/Read_Count
add wave -noupdate -divider {RTC Testbench}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/I2C_Test_State
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Test_I2C_Config_State
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Test_I2C_Read_State
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Counters_State
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Seconds_TestData_i
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Test_Byte_i
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/TestData_i
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/data_test/Cycle_Count
add wave -noupdate -divider -height 30 DeMux
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/UART_RXD
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Demux_1/Dig_Outputs_Ready
add wave -noupdate -divider -height 30 {Digital Output}
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_1
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_2
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_3
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_4
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_5
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_6
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_7
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Output_Handler_1/SPI_Outport_8
add wave -noupdate -divider -height 30 {Digital Input}
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_1
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_2
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_3
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_4
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_5
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_6
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_7
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Input_Handler_1/SPI_Inport_8
add wave -noupdate -divider -height 30 {Analog Input}
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH1_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH2_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH3_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH4_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH5_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH6_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH7_o
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Handler_1/CH8_o
add wave -noupdate -divider -height 30 Mux
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/UART_TXD
add wave -noupdate -radix hexadecimal /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/data2send
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Ana_In_Request_i
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Dig_In_Request_i
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Dig_Out_Request_i
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Main_Mux_1/Version_Data_Request
add wave -noupdate -divider -height 30 Endat
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/initialation_Status_i
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
add wave -noupdate -divider {SPI I/O Driver}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_In_1/nCS_Output_1
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_In_1/nCS_Output_2
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_In_1/Sclk
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_In_1/Mosi
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_In_1/Miso
add wave -noupdate -divider {SPI Analog Drivers}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/CS1
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/CS2
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/CS3
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/CS4
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/Sclk
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/Mosi
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/SPI_Analog_Driver_1/Miso
add wave -noupdate -divider {I2C Driver}
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Driver_1/scl
add wave -noupdate /ape_test_system_fpga_firmware_test_bench/Real_Time_Clock_I2C_Driver_1/sda
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12563451777 ps} 0} {{Cursor 2} {31580041580 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 242
configure wave -valuecolwidth 96
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {105 ms}
