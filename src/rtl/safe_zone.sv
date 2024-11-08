module safe_zone # (
    parameter SCREEN_WIDTH  = 800,
    parameter SCREEN_HEIGHT = 600,
    parameter BLOCK_SIZE    = 10
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

assign gen_finished    = (x == ($clog2(SUBARRAYS_X_NUM))'(SUBARRAYS_X_NUM - 1) &&
                          y == ($clog2(SUBARRAYS_Y_NUM))'(SUBARRAYS_Y_NUM - 1));
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
        y   <= y + ($clog2(SUBARRAYS_Y_NUM))'(x == ($clog2(SUBARRAYS_X_NUM))'(SUBARRAYS_X_NUM - 1));
        x   <= (x == ($clog2(SUBARRAYS_X_NUM))'(SUBARRAYS_X_NUM - 1)) ? '0 : (x + 1);
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

pseudo_random_generator prg_inst (
    .clk    (clk),
    .arst_n (arst_n),
    .o_prng (random)
);

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

localparam MEMADDR_WIDTH = $clog2(SCREEN_WIDTH/BLOCK_SIZE * SCREEN_HEIGHT/BLOCK_SIZE);

logic [MEMADDR_WIDTH-1:0] mem_addr_gen, mem_addr_req, mem_addr;

assign mem_addr_gen = (MEMADDR_WIDTH'(x) * SUB_SIZE + MEMADDR_WIDTH'(subx) +
                      (MEMADDR_WIDTH'(y) * SUB_SIZE + MEMADDR_WIDTH'(suby)) * (SCREEN_WIDTH/BLOCK_SIZE));

assign mem_addr_req = (MEMADDR_WIDTH'(i_x) / BLOCK_SIZE +
                      (MEMADDR_WIDTH'(i_y) / BLOCK_SIZE) * (SCREEN_WIDTH/BLOCK_SIZE));

assign mem_addr = o_rdy ? mem_addr_req : mem_addr_gen;

logic [9:0] mem_resp;

assign o_is_safe = mem_resp[mem_addr_req % 10];

//`define VIVADO

`ifdef VIVADO

safe_zone_4800_mem_gen safe_zone_mem (
  .a(mem_addr / 10),  // input wire [8 : 0] a
  .d(subarray[suby]), // input wire [9 : 0] d
  .clk(clk),          // input wire clk
  .we(~o_rdy),        // input wire we
  .spo(mem_resp)      // output wire [9 : 0] spo
);

`else // NON VIVADO SIM

logic [9:0] mem_data [480];

assign mem_resp = mem_data[mem_addr / 10];

always @(posedge clk) begin
    if (~o_rdy) begin
        mem_data[mem_addr / 10] <= subarray[suby];
    end
end

`endif

endmodule
