vlib work

vlog -timescale 1ns/1ns gameboard.v

vsim gameboard_datapath

log {/*}

add wave {/*}

# reset the datapath and start clock
force {clk} 1 1, 0 {10ns} -repeat 20ns
force {reset}   0
force {load_x}  0
force {load_y}  0
force {load_c}  0
force {en_c}    0
force {x_in}    0000111
force {y_in}    0001001
force {color_in} 000
run 20ns
force {reset}   1
run 20ns
force {en_c}    1
run 4960ns
