module control(
  input clk,
  input resetn,
  input go,
  input win,
  input lose,

  output reg ldMM, ldMMtoSM, resetMM, resetFM, resetSM
  );

  reg [3:0] current_state, next_state;

  localparam  S_LOAD_MM       = 4'd0,
              S_LOAD_MM_WAIT  = 4'd1,
              S_GAME_STATE    = 4'd2,
              S_GAME_WIN      = 4'd3,
              S_GAME_LOSE     = 4'd4,
              S_RESET         = 4'd5;

  always@(*)
  begin: state_table
          case (current_state)
            S_LOAD_MM:      next_state = go ? S_LOAD_MM_WAIT  : S_LOAD_MM;    // Loop in current state until game start
            S_LOAD_MM_WAIT: next_state = go ? S_LOAD_MM_WAIT  : S_GAME_STATE; // Loop in current state until go signal goes low
            S_GAME_STATE: begin
                            if(win == 1'b1 && lose == 1'b0)
                              next_state = S_GAME_WIN;
                            else if(win == 1'b0 && lose == 1'b1)
                              next_state = S_GAME_LOSE;
                            else
                              next_state = S_GAME_STATE;
                          end
            S_GAME_LOSE:    next_state = go ? S_RESET : S_GAME_LOSE;
            S_GAME_WIN:     next_state = go ? S_RESET : S_GAME_WIN;
            S_RESET:        next_state = S_LOAD_MM;
          endcase
  end // state_table

  // Output logic aka all of our datapath control signals
  always @(*)
  begin: enable_signals
      // By default make all our signals 0
      ldMM = 1'b0;
      ldMMtoSM = 1'b0;
      resetMM = 1'b0;
      resetFM = 1'b0;
      resetSM = 1'b0;

      case (current_state)
          S_LOAD_MM: begin
            ldMM = 1'b1;
            end
          S_GAME_LOSE: begin
            ldMMtoSM = 1'b1;
            end
          S_RESET: begin
            resetMM = 1'b1;
            resetFM = 1'b1;
            resetSM = 1'b1;
            end
      endcase
  end
// current_state registers
always@(posedge clk)
begin: state_FFs
    if(!resetn)
        current_state <= S_LOAD_MM;
    else
        current_state <= next_state;
end // state_FFS

endmodule
