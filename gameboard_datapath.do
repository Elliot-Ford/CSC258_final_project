vlib work

vlog -timescale 1ns/1ns gameboard.v

vsim gameboard_shape

log {/*}

add wave {/*}

# reset the datapath and start clock
force {clk} 1 1, 0 {10ns} -repeat 20ns
force {reset}   0
force {en_c}    0
run 40ns
force {reset}   1
run 20ns
force {en_c}    1
run 40000ns
