module game_engine # (
    parameter SCREEN_WIDTH  = 800,
    parameter SCREEN_HEIGHT = 600,
    parameter BALL_RADIUS   = 10,
    parameter BLOCK_SIZE    = 10,
    parameter NUM_IMAGES    = 4
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
    // Graphic
    input  logic  [$clog2(SCREEN_WIDTH)-1:0] i_screen_x,
    input  logic [$clog2(SCREEN_HEIGHT)-1:0] i_screen_y,
    output logic  [$clog2(SCREEN_WIDTH)-1:0] o_screen_ball_x,
    output logic [$clog2(SCREEN_HEIGHT)-1:0] o_screen_ball_y,
    output logic                             o_is_safe,
    output logic                             o_show_banner,
    output logic    [$clog2(NUM_IMAGES)-1:0] o_banner_num,
    // Quad display
    output logic                      [31:0] o_disp_data
);

logic regenerate_level;
logic safe_zone_rdy;
logic game_running;

safe_zone # (
    .SCREEN_WIDTH  (SCREEN_WIDTH),
    .SCREEN_HEIGHT (SCREEN_HEIGHT),
    .BLOCK_SIZE    (BLOCK_SIZE)
) safe_zone_inst (
    .clk                (clk),
    .arst_n             (arst_n),

    .i_regenerate_level (regenerate_level),
    .o_rdy              (safe_zone_rdy),

    .i_x                (i_screen_x),
    .i_y                (i_screen_y),
    .o_is_safe          (o_is_safe)
);

ball_positioner # (
    .SCREEN_WIDTH  (SCREEN_HEIGHT),
    .SCREEN_HEIGHT (SCREEN_HEIGHT),
    .BALL_RADIUS   (BALL_RADIUS)
) ball_positioner_inst (
    .clk        (clk),
    .arst_n     (arst_n),

    .i_accel_x  (i_accel_dx),
    .i_accel_y  (i_accel_dy),

    .o_ball_x   (o_screen_ball_x),
    .o_ball_y   (o_screen_ball_y)
);

game_status # (
    .RATING_WIDTH (8),
    .NUM_IMAGES   (NUM_IMAGES)
) game_status_inst (
    .clk                (clk),
    .rst_n              (arst_n),

    // safe zone
    .i_is_win           (),           // is round win or lose
    .i_round_ended      (),      // is round ended
    .i_ready            (safe_zone_rdy),            // is safe zone end generation
    .o_regenerate_level (regenerate_level),

    // button
    .i_pause_game       (i_btn_left),
    .i_start_game       (i_btn_right),

    .o_current_rating   (o_disp_data[7:0]),
    .o_game_running     (game_running),
    .o_image_number     (o_banner_num)
);

assign o_show_banner = ~game_running;

endmodule
