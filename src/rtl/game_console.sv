module game_console (
    input  logic             clk,
    input  logic             arst_n,

    // Accel
    input  logic       [7:0] accel_data_x,
    input  logic       [7:0] accel_data_y,
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
    output logic      [31:0] quad_disp,
    // LED display
    output logic [1:0] game1_state,
    output logic [1:0] game2_state
);

localparam SCREEN_WIDTH  = 800;
localparam SCREEN_HEIGHT = 600;
localparam BALL_RADIUS   = 10;
localparam BLOCK_SIZE    = 20;
localparam NUM_IMAGES    = 4;
localparam RATING_WIDTH  = 8;

logic [$clog2(SCREEN_WIDTH/2)-1:0] screen_ball_x;
logic  [$clog2(SCREEN_HEIGHT)-1:0] screen_ball_y;
logic                              ball_is_safe;
logic [$clog2(SCREEN_WIDTH/2)-1:0] screen_x, game2_screen_x;
logic  [$clog2(SCREEN_HEIGHT)-1:0] screen_y, game2_screen_y;
logic                              show_banner;
logic                              game_running;
logic     [$clog2(NUM_IMAGES)-1:0] banner_num;
logic                              regen_level;
logic                              safe_zone_rdy;

logic game_win, game2_win;
logic game_lose, game2_lose;

logic [3:0] banner_r, game_r, game2_r;
logic [3:0] banner_g, game_g, game2_g;
logic [3:0] banner_b, game_b, game2_b;

logic [11:0] ball_color, safe_color, bkg_color;

logic [RATING_WIDTH-1:0] rating;

assign game1_state = {game_win, game_lose};
assign game2_state = {game2_win, game2_lose};

game_status # (
    .RATING_WIDTH (RATING_WIDTH),
    .NUM_IMAGES   (NUM_IMAGES)
) game_status_inst (
    .clk                (clk),
    .rst_n              (arst_n),

    .i_is_win           (game_win),
    .i_is_lose          (game_lose || game2_lose),
    .i_ready            (safe_zone_rdy),
    .o_regenerate_level (regen_level),

    // button
    .i_pause_game       (switches[0]),
    .i_start_game       (button_c),

    .o_current_rating   (rating),
    .o_game_running     (game_running),
    .o_image_number     (banner_num)
);

assign show_banner    = ~game_running;
assign quad_disp[7:0] = rating;

game_engine # (
    .SCREEN_WIDTH  (SCREEN_WIDTH / 2),
    .SCREEN_HEIGHT (SCREEN_HEIGHT),
    .BALL_RADIUS   (BALL_RADIUS),
    .BLOCK_SIZE    (BLOCK_SIZE),
    .NUM_IMAGES    (NUM_IMAGES),
    .RATING_WIDTH  (RATING_WIDTH)
) engine (
    .clk                (clk),
    .arst_n             (arst_n),

    // Accel
    .i_accel_dx         (accel_data_x),
    .i_accel_dy         (accel_data_y),
    // Switches
    .i_switches         (switches),
    // Graphic
    .i_screen_x         (screen_x),
    .i_screen_y         (screen_y),
    .o_screen_ball_x    (screen_ball_x),
    .o_screen_ball_y    (screen_ball_y),
    .o_is_safe          (ball_is_safe),
    // State
    .i_pause            (~game_running),
    .i_regenerate_level (regen_level),
    .o_safe_zone_rdy    (safe_zone_rdy),
    .o_win              (game_win),
    .o_lose             (game_lose),
    .i_rating           (rating),
    // Quad display
    .o_timer            (quad_disp[31:16])
);

graphic # (
    .SCREEN_WIDTH       (SCREEN_WIDTH / 2),
    .SCREEN_HEIGHT      (SCREEN_HEIGHT),
    .BALL_RADIUS        (BALL_RADIUS)
) graphic_inst (
    .i_ball_color       (ball_color),
    .i_safe_color       (safe_color),
    .i_bkg_color        (bkg_color),

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
logic [9:0] game2_ball_y;
logic game2_gameover;

second_game_engine #(
    .SECOND_GAME_START_X                (SCREEN_WIDTH / 2),
    .SECOND_GAME_START_Y                (0),
    .SECOND_GAME_WIDTH                  (SCREEN_WIDTH / 2),
    .SECOND_GAME_HEIGHT                 (SCREEN_HEIGHT),

    .SECOND_GAME_PLAYER_SIZE            (30),
    .SECOND_GAME_SQUARE_SIZE            (20),
    .SECOND_GAME_BETWEEN_OBSTACLE_SIZE  (100),
    .SECOND_GAME_NUM_OBSTACLES          (5)
) second_game_engine_inst (
    .clk                                (clk),
    .arst_n                             (arst_n),

    .i_button_l                         (button_l),
    .i_button_r                         (button_r),
    .i_button_u                         (button_u),
    .i_button_d                         (button_d),

    .i_screen_x                         (game2_screen_x),
    .i_screen_y                         (game2_screen_y),

    .i_is_pause                         (~game_running),

    .o_is_obstacle                      (game2_is_obstacle),

    .o_ball_x                           (game2_ball_x),
    .o_ball_y                           (game2_ball_y),
    .o_is_lose                          (game2_lose)
);

second_game_graphics # (
    .SECOND_GAME_START_X        (SCREEN_WIDTH / 2),
    .SECOND_GAME_START_Y        (0),
    .SECOND_GAME_SCREEN_WIDTH   (SCREEN_WIDTH / 2),
    .SECOND_GAME_SCREEN_HEIGHT  (SCREEN_HEIGHT),
    .SECOND_GAME_PLAYER_SIZE    (20)
) second_game_graphics_inst (
    .i_player_color             (ball_color),
    .i_obstacle_color           (safe_color),
    .i_bkg_color                (bkg_color),

    .o_screen_x                 (game2_screen_x),
    .o_screen_y                 (game2_screen_y),

    .i_is_obstacle              (game2_is_obstacle),

    .i_screen_square_x          (game2_ball_x),
    .i_screen_square_y          (game2_ball_y),

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

color_palette color_palette_inst (
    .color_id   (switches[8:1]),

    .color1     (ball_color),
    .color2     (safe_color),
    .color3     (bkg_color)
);

endmodule
