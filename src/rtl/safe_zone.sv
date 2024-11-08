module safe_zone # (
    localparam SCREEN_WIDTH  = 800,
    localparam SCREEN_HEIGHT = 600,
    localparam BLOCK_SIZE    = 10
)(
    input  logic                             clk,
    input  logic                             arst_n,

    input  logic                             i_regenerate_level,
    output logic                             o_rdy,

    input  logic  [$clog2(SCREEN_WIDTH)-1:0] i_x,
    input  logic [$clog2(SCREEN_HEIGHT)-1:0] i_y,
    output logic                             o_is_safe
);

localparam SUB_SIZE = 10;
localparam SUBARRAYS_X_NUM = SCREEN_WIDTH  / BLOCK_SIZE / SUB_SIZE;
localparam SUBARRAYS_Y_NUM = SCREEN_HEIGHT / BLOCK_SIZE / SUB_SIZE;

localparam RAND_WIDTH = 8;

logic gen, gen_finished;
logic [$clog2(SUBARRAYS_X_NUM)-1:0] x;
logic [$clog2(SUBARRAYS_Y_NUM)-1:0] y;

logic subgen, subgen_finished;
logic [SUB_SIZE-1:0][SUB_SIZE-1:0] subarray;
logic [$clog2(SUB_SIZE)-1:0] subx, suby;

assign gen_finished    = (x == SUBARRAYS_X_NUM && y == SUBARRAYS_Y_NUM);
assign subgen_finished = (subx == SUB_SIZE && suby == SUB_SIZE);

assign o_rdy = ~gen;

always_ff @(posedge clk) begin
    if (!arst_n) begin
        gen <= 1'b0;
        x   <= '0;
        y   <= '0;
    end else if (i_regenerate_level) begin
        gen <= 1'b1;
        x   <= '0;
        y   <= '0;
    end else if (gen && gen_finished) begin
        gen <= 1'b0;
        x   <= '0;
        y   <= '0;
    end else if (subgen_finished) begin
        y   <= y + ($clog2(SUBARRAYS_Y_NUM))'(x == SUBARRAYS_X_NUM);
        x   <= (x == SUBARRAYS_X_NUM) ? '0 : (x + 1);
    end
end

always_ff @(posedge clk) begin
    if (!arst_n) begin
        subgen <= 1'b0;
        subx   <= '0;
        suby   <= '0;
    end else if (i_regenerate_level) begin
        subgen <= 1'b1;
        subx   <= '0;
        suby   <= '0;
    end else if (subgen && subx == SUB_SIZE && suby == SUB_SIZE) begin
        subgen <= !gen_finished;
        subx   <= '0;
        suby   <= '0;
    end else begin
        suby   <= suby + 4'(subx == SUB_SIZE);
        subx   <= (subx == SUB_SIZE) ? 4'b0 : (subx + 1);
    end
end

logic upper_exists, left_exists, ludiag_exists;

assign upper_exists  = (suby != 0 && subarray[suby - 1][subx]);
assign left_exists   = (subx != 0 && subarray[suby][subx - 1]);
assign ludiag_exists = (subx != 0 && suby != 0 && subarray[subx - 1][suby - 1]);

logic [RAND_WIDTH-1:0] random;
logic random_res;

always_comb begin
    if (upper_exists && left_exists && ludiag_exists)
        random_res = random < 2**RAND_WIDTH * 0.25;
    else if (upper_exists && left_exists)
        random_res = random < 2**RAND_WIDTH * 0.75;
    else if (!upper_exists && !left_exists && !ludiag_exists)
        random_res = random < 2**RAND_WIDTH * 0.25;
    else
        random_res = random < 2**RAND_WIDTH * 0.5;
end

always_ff @(posedge clk) begin
    if (subgen) begin
        subarray[subx][suby] <= random_res;
    end
end

// TODO mem write

endmodule
