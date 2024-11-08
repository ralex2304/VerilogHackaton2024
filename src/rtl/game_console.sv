module game_console (
    input  logic             clk,
    input  logic             arst_n,

    // Accel
    input  logic       [7:0] accel_data_x,
    input  logic       [7:0] accel_data_y,
    // Mouse
    input  logic       [7:0] mouse_x,
    input  logic             is_mouse_x_neg,
    input  logic       [7:0] mouse_y,
    input  logic             is_mouse_y_neg,
    // Switches
    input  logic      [15:0] switches,
    // Buttons
    input  logic             button_c,
    input  logic             button_u,
    input  logic             button_d,
    input  logic             button_r,
    input  logic             button_l,
    // Monitor
    input  logic      [10:0] monitor_h_coord,
    input  logic       [9:0] monitor_v_coord,
    input  logic             monitor_enable,
    output logic       [3:0] monitor_r,
    output logic       [3:0] monitor_g,
    output logic       [3:0] monitor_b,
    // Quad display
    output logic      [31:0] quad_disp
);

localparam SCREEN_WIDTH  = 800;
localparam SCREEN_HEIGHT = 600;
localparam BALL_RADIUS   = 10;
localparam BLOCK_SIZE    = 10;
localparam NUM_IMAGES    = 4;

logic [$clog2(SCREEN_WIDTH/2)-1:0] screen_ball_x;
logic  [$clog2(SCREEN_HEIGHT)-1:0] screen_ball_y;
logic                              ball_is_safe;
logic [$clog2(SCREEN_WIDTH/2)-1:0] screen_x, game2_screen_x;
logic  [$clog2(SCREEN_HEIGHT)-1:0] screen_y, game2_screen_y;
logic                              show_banner;
logic     [$clog2(NUM_IMAGES)-1:0] banner_num;

logic [3:0] banner_r, game_r, game2_r;
logic [3:0] banner_g, game_g, game2_g;
logic [3:0] banner_b, game_b, game2_b;

game_engine # (
    .SCREEN_WIDTH  (SCREEN_WIDTH / 2),
    .SCREEN_HEIGHT (SCREEN_HEIGHT),
    .BALL_RADIUS   (BALL_RADIUS),
    .BLOCK_SIZE    (BLOCK_SIZE),
    .NUM_IMAGES    (NUM_IMAGES)
) engine (
    .clk                (clk),
    .arst_n             (arst_n),

    // Accel
    .i_accel_dx         (accel_data_x),
    .i_accel_dy         (accel_data_y),
    // Switches
    .i_switches         (switches),
    // Buttons
    .i_btn_center       (button_c),
    .i_btn_left         (button_l),
    .i_btn_right        (button_r),
    .i_btn_up           (button_u),
    .i_btn_down         (button_d),
    // Graphic
    .i_screen_x         (screen_x),
    .i_screen_y         (screen_y),
    .o_screen_ball_x    (screen_ball_x),
    .o_screen_ball_y    (screen_ball_y),
    .o_is_safe          (ball_is_safe),
    .o_show_banner      (show_banner),
    .o_banner_num       (banner_num),
    // Quad display
    .o_disp_data        (quad_disp)
);

graphic # (
    .SCREEN_WIDTH       (SCREEN_WIDTH / 2),
    .SCREEN_HEIGHT      (SCREEN_HEIGHT),
    .BALL_RADIUS        (BALL_RADIUS),

    .BALL_COLOR         (12'hF00),  // Red
    .SAFE_COLOR         (12'h0F0),  // Green
    .BKG_COLOR          (12'h00F)   // Blue
) graphic_inst (
    .o_screen_x         (screen_x[8:0]),
    .o_screen_y         (screen_y),

    .i_is_safe          (ball_is_safe),

    .i_screen_ball_x    (screen_ball_x[8:0]),
    .i_screen_ball_y    (screen_ball_y),

    // VGA
    .o_red              (game_r),
    .o_green            (game_g),
    .o_blue             (game_b),

    .i_disp_enbl        (monitor_enable),
    .i_h_coord          (monitor_h_coord),
    .i_v_coord          (monitor_v_coord)
);

logic game2_is_obstacle;
logic [8:0] game2_ball_x;
logic game2_gameover;

second_game_engine #(
    .SECOND_GAME_START_X                (SCREEN_WIDTH / 2),
    .SECOND_GAME_START_Y                (0),
    .SECOND_GAME_WIDTH                  (SCREEN_WIDTH / 2),
    .SECOND_GAME_HEIGHT                 (SCREEN_HEIGHT),

    .SECOND_GAME_PLAYER_SIZE            (30),
    .SECOND_GAME_SQUARE_SIZE            (20),
    .SECOND_GAME_BETWEEN_OBSTACLE_SIZE  (40),
    .SECOND_GAME_NUM_OBSTACLES          (5)
) second_game_engine_inst (
    .clk                                (clk),
    .arst_n                             (arst_n),

    .i_mouse_dx                         (mouse_x),
    .i_mouse_dy                         (mouse_y),
    .i_is_mouse_dx_neg                  (is_mouse_x_neg),
    .i_is_mouse_dy_neg                  (is_mouse_y_neg),

    .i_screen_x                         (game2_screen_x),
    .i_screen_y                         (game2_screen_y),

    .o_is_obstacle                      (game2_is_obstacle),

    .o_ball_x                           (game2_ball_x),
    .o_is_gameover                      (game2_gameover)
);

second_game_graphics # (
    .SECOND_GAME_START_X        (SCREEN_WIDTH / 2),
    .SECOND_GAME_START_Y        (0),
    .SECOND_GAME_SCREEN_WIDTH   (SCREEN_WIDTH / 2),
    .SECOND_GAME_SCREEN_HEIGHT  (SCREEN_HEIGHT),
    .SECOND_GAME_PLAYER_SIZE    (20),

    .SECOND_GAME_PLAYER_COLOR   (12'hF00),  // Red
    .SECOND_GAME_OBSTACLE_COLOR (12'h0F0),  // Green
    .SECOND_GAME_BKG_COLOR      (12'h00F)   // Blue
) second_game_graphics_inst (
    .o_screen_x                 (game2_screen_x),
    .o_screen_y                 (game2_screen_y),

    .i_is_obstacle              (game2_is_obstacle),

    .i_screen_square_x          (game2_ball_x),

    // VGA
    .o_red                      (game2_r),        // 4-bit color output
    .o_green                    (game2_g),      // 4-bit color output
    .o_blue                     (game2_b),       // 4-bit color output

    .i_disp_enbl                (monitor_enable),  // display enable (0 = all colors must be blank)
    .i_h_coord                  (monitor_h_coord),    // horizontal pixel coordinate
    .i_v_coord                  (monitor_v_coord)
);

banners #(
    .SCREEN_WIDTH   (SCREEN_WIDTH),
    .SCREEN_HEIGHT  (SCREEN_HEIGHT),
    .NUM_IMAGES     (NUM_IMAGES)
) banners_inst (
    .i_banner_num   (banner_num),
    .i_disp_enbl    (monitor_enable),
    .i_h_coord      (monitor_h_coord),
    .i_v_coord      (monitor_v_coord),

    .o_red          (banner_r),
    .o_green        (banner_g),
    .o_blue         (banner_b)
);

always_comb begin
    if (show_banner) begin
        {monitor_r, monitor_g, monitor_b} = {banner_r, banner_g, banner_b};
    end else if (monitor_h_coord < SCREEN_WIDTH / 2) begin
        {monitor_r, monitor_g, monitor_b} = {game_r, game_g, game_b};
    end else begin
        {monitor_r, monitor_g, monitor_b} = {game2_r, game2_g, game2_b};
    end
end

endmodule
