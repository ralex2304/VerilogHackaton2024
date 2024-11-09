module timer # (
    parameter TIMER_WIDTH = 16,
    parameter CLK_FREQ    = 36_000_000
)(
    input logic                     clk,
    input logic                     rst_n,

    input logic                     i_pause,
    input logic                     i_reset_timer,

    output logic [TIMER_WIDTH-1:0]  o_current_time
);

localparam CLK_TIMER_WIDTH = $clog2(CLK_FREQ);

logic [TIMER_WIDTH-1:0] timer;
logic [CLK_TIMER_WIDTH-1:0] clk_timer;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timer     <= '0;
        clk_timer <= '0;
    end else if (i_reset_timer) begin
        timer     <= '0;
    end else begin
        clk_timer <= clk_timer + (i_pause ? 0 : 1);
        if (clk_timer == CLK_FREQ && !i_pause) begin
            timer <= timer + 1;
            $display("1 second");
        end
    end
end

assign o_current_time = timer;

endmodule
