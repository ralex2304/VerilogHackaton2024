module timer # (
    parameter TIMER_WIDTH = 16,
    parameter CLK_FREQ    = 100_000_000
)(
    input logic                         clk             ,
    input logic                         rst_n           ,
    input logic                         i_reset_timer   ,

    output logic [TIMER_WIDTH - 1 : 0]  o_current_time
);

logic [TIMER_WIDTH - 1 : 0] timer;

localparam CLK_TIMER_WIDTH = $clog2(CLK_FREQ);
logic [CLK_TIMER_WIDTH - 1 : 0] clk_timer;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timer <= 0;
        clk_timer <= 0;
    end else begin
        if (i_reset_timer) begin
            timer <= 0;
        end

        clk_timer <= clk_timer + 1;

        if (clk_timer == CLK_FREQ) begin
            timer <= timer + 1;
        end
    end
end

endmodule
