module game_engine # (
    parameter SCREEN_WIDTH  = 800,
    parameter SCREEN_HEIGHT = 600
)(
    input  logic                             clk,
    input  logic                             arst_n,

    // Accel
    input  logic                       [7:0] i_accel_dx,
    input  logic                       [7:0] i_accel_dy,
    // Switches
    input  logic                      [15:0] i_switches,
    // Buttons
    input  logic                             i_btn_center,
    input  logic                             i_btn_left,
    input  logic                             i_btn_right,
    input  logic                             i_btn_up,
    input  logic                             i_btn_down,
    // Mouse
    input  logic                       [8:0] i_mouse_dx,
    input  logic                       [8:0] i_mouse_dy,
    // Graphic
    input  logic  [$clog2(SCREEN_WIDTH)-1:0] i_screen_x,
    input  logic [$clog2(SCREEN_HEIGHT)-1:0] i_screen_y,
    output logic  [$clog2(SCREEN_WIDTH)-1:0] o_screen_ball_x,
    output logic [$clog2(SCREEN_HEIGHT)-1:0] o_screen_ball_y,
    output logic                             o_is_safe,
    // Quad display
    output logic                      [31:0] o_disp_data
);

safe_zone # (
    .SCREEN_WIDTH  (SCREEN_WIDTH),
    .SCREEN_HEIGHT (SCREEN_HEIGHT),
    .BLOCK_SIZE    (10)
) safe_zone_inst (
    .clk                (clk),
    .arst_n             (arst_n),

    .i_regenerate_level (i_btn_up), // FIXME
    .o_rdy              (),

    .i_x                (i_screen_x), // TODO
    .i_y                (i_screen_y),
    .o_is_safe          (o_is_safe)
);

ball_positioner # (
    .SCREEN_WIDTH  (800),
    .SCREEN_HEIGHT (600),
    .BALL_RADIUS   (20)
) ball_positioner_inst (
    .clk        (clk),
    .arst_n     (arst_n),

    .i_accel_x  (i_accel_dx),
    .i_accel_y  (i_accel_dy),

    .o_ball_x   (o_screen_ball_x),
    .o_ball_y   (o_screen_ball_y)
);

endmodule
