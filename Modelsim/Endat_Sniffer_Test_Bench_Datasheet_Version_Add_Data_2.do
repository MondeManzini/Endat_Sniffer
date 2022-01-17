onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock and Reset}
add wave -noupdate /endat_sniffer_test_bench/RST_I_i
add wave -noupdate /endat_sniffer_test_bench/CLK_I_i
add wave -noupdate -divider -height 34 {Test Bench}
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/endat_emulate_state
add wave -noupdate /endat_sniffer_test_bench/mode_state
add wave -noupdate /endat_sniffer_test_bench/pos_state
add wave -noupdate /endat_sniffer_test_bench/add_data_1_state
add wave -noupdate /endat_sniffer_test_bench/add_data_2_state
add wave -noupdate /endat_sniffer_test_bench/mode_enable
add wave -noupdate /endat_sniffer_test_bench/dummy_enable
add wave -noupdate /endat_sniffer_test_bench/pos_enable
add wave -noupdate /endat_sniffer_test_bench/add_data_1_enable
add wave -noupdate /endat_sniffer_test_bench/add_data_2_enable
add wave -noupdate /endat_sniffer_test_bench/crc_enable
add wave -noupdate /endat_sniffer_test_bench/Endat_test/num_clks
add wave -noupdate -radix binary /endat_sniffer_test_bench/mode_data_i
add wave -noupdate /endat_sniffer_test_bench/Endat_test/mode_cycle_count
add wave -noupdate /endat_sniffer_test_bench/Endat_test/pos_cycle_count
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/pos_data_i
add wave -noupdate /endat_sniffer_test_bench/Endat_test/data_1_cycle_count
add wave -noupdate /endat_sniffer_test_bench/Endat_test/data_2_cycle_count
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/add_data_1_i
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/add_data_2_i
add wave -noupdate /endat_sniffer_test_bench/Endat_test/clock_cnt
add wave -noupdate /endat_sniffer_test_bench/endat_clk_i
add wave -noupdate /endat_sniffer_test_bench/endat_data_i
add wave -noupdate -radix binary /endat_sniffer_test_bench/mod_test_data
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/pos_test_data
add wave -noupdate -radix hexadecimal /endat_sniffer_test_bench/add_test_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {983048747 ps} 0} {{Cursor 2} {365104809 ps} 0}
quietly wave cursor active 2
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
configure wave -timelineunits ns
update
WaveRestoreZoom {131499202 ps} {131773271 ps}
