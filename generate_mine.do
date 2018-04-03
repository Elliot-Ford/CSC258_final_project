vlib work
vlog -timescale 1ns/1ns MineSweeper.v
vsim generate_mine

log {/*}
add wave {/*}

force {clk} 0 0, 1 1 -repeat 2ns
force {resetn} 0 0, 1 3
force {en} 0 0, 1 4

run 10000ns
