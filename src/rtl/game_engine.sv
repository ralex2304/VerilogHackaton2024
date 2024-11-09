module game_engine # (
    parameter SCREEN_WIDTH  = 400,
    parameter SCREEN_HEIGHT = 600,
    parameter BALL_RADIUS   = 10,
    parameter BLOCK_SIZE    = 10,
    parameter NUM_IMAGES    = 4,
    parameter RATING_WIDTH  = 8
)(
    input  logic                             clk,
    input  logic                             arst_n,

    // Accel
    input  logic                       [7:0] i_accel_dx,
    input  logic                       [7:0] i_accel_dy,
    // Switches
    input  logic                      [15:0] i_switches,
    // Graphic
    input  logic  [$clog2(SCREEN_WIDTH)-1:0] i_screen_x,
    input  logic [$clog2(SCREEN_HEIGHT)-1:0] i_screen_y,
    output logic  [$clog2(SCREEN_WIDTH)-1:0] o_screen_ball_x,
    output logic [$clog2(SCREEN_HEIGHT)-1:0] o_screen_ball_y,
    output logic                             o_is_safe,
    // State
    input  logic                             i_pause,
    input  logic                             i_regenerate_level,
    output logic                             o_safe_zone_rdy,
    output logic                             o_win,
    output logic                             o_lose,
    input  logic          [RATING_WIDTH-1:0] i_rating,
    // Quad display
    output logic                      [15:0] o_timer
);

logic round_ending;

safe_zone # (
    .SCREEN_WIDTH  (SCREEN_WIDTH),
    .SCREEN_HEIGHT (SCREEN_HEIGHT),
    .BLOCK_SIZE    (BLOCK_SIZE)
) safe_zone_inst (
    .clk                (clk),
    .arst_n             (arst_n),

    .i_regenerate_level (i_regenerate_level),
    .o_rdy              (o_safe_zone_rdy),

    .i_x                (round_ending ? o_screen_ball_x : i_screen_x),
    .i_y                (round_ending ? o_screen_ball_y : i_screen_y),
    .o_is_safe          (o_is_safe)
);

ball_positioner # (
    .SCREEN_WIDTH  (SCREEN_WIDTH),
    .SCREEN_HEIGHT (SCREEN_HEIGHT),
    .BALL_RADIUS   (BALL_RADIUS)
) ball_positioner_inst (
    .clk              (clk),
    .arst_n           (arst_n),

    .i_reset_position (i_regenerate_level),

    .i_accel_x        (i_accel_dx),
    .i_accel_y        (i_accel_dy),

    .o_ball_x         (o_screen_ball_x),
    .o_ball_y         (o_screen_ball_y),

    .i_pause          (i_pause)
);

logic [15:0] timer, lvl_begin, wait_time;

timer # (
    .TIMER_WIDTH (16),
    .CLK_FREQ    (36_000_00) // FIXME fix timer
) timer_inst (
    .clk            (clk),
    .rst_n          (arst_n),

    .i_pause        (i_pause),
    .i_reset_timer  (i_regenerate_level),

    .o_current_time (timer)
);

always_ff @(posedge clk or negedge arst_n) begin
    if (~arst_n) begin
        lvl_begin <= '0;
        wait_time <= '0;
    end else if (i_regenerate_level) begin
        lvl_begin <= timer;
        wait_time <= (i_rating <= 8) ? (16'd10 - 16'(i_rating)) : 2;
    end
end

assign round_ending = (timer - lvl_begin > wait_time) && !i_pause;

always_comb begin
    o_win  = 1'b0;
    o_lose = 1'b0;
    if (round_ending && o_is_safe) begin
        o_win  = 1'b1;
    end else if (round_ending) begin
        o_lose = 1'b1;
    end
end

endmodule
