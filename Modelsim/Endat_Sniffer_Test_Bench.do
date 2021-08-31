onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock and Reset}
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/clk
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/reset_n
add wave -noupdate -divider {State Machines}
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/Endat_Sniffer_State
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/Read_data_state
add wave -noupdate -divider {Pre-Load Bits}
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/MODE_BITS
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/POS_BITS
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/ADD_BITS
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/CRC_BITS
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/endat_clk
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/endat_data
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/endat_enable
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/EndatSniffer_1/endat_mode_out
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/EndatSniffer_1/endat_Position_out
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/EndatSniffer_1/endat_Data_1_out
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/EndatSniffer_1/endat_Data_2_out
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/data_cnt
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/endat_data_Ready
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/endat_clk_enable
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/endat_clk_cnt
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/endat_in_done
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/endat_clk_done
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/endat_Data_Ready_i
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/data_1_cnt
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/data_2_cnt
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/mode_cnt
add wave -noupdate /endat_sniffer_test_bench/EndatSniffer_1/position_cnt
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/EndatSniffer_1/mode
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/EndatSniffer_1/position
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/EndatSniffer_1/data_1
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/EndatSniffer_1/data_2
add wave -noupdate -divider {Test Bench}
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/endat_emulate_state
add wave -noupdate /endat_sniffer_test_bench/Endat_test/clock_cnt
add wave -noupdate /endat_sniffer_test_bench/Endat_test/send_read_cnt
add wave -noupdate /endat_sniffer_test_bench/Endat_test/data_cnt
add wave -noupdate /endat_sniffer_test_bench/transceiver_state
add wave -noupdate /endat_sniffer_test_bench/mode_data_i
add wave -noupdate /endat_sniffer_test_bench/Endat_test/mode_cycle_count
add wave -noupdate /endat_sniffer_test_bench/Endat_test/pos_cycle_count
add wave -noupdate /endat_sniffer_test_bench/Endat_test/data_cycle_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {945647349 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {108400395 ps} {779127836 ps}
