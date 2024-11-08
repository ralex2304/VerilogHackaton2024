module top_sberday (
  input   logic             pixel_clk    ,
  input   logic             sim_rst      ,
  input   logic             button_c     ,
  input   logic             button_u     ,
  input   logic             button_d     ,
  input   logic             button_r     ,
  input   logic             button_l     ,
  //
  input   logic  [7:0]      accel_data_x ,
  input   logic  [7:0]      accel_data_y ,
  //
  input   logic             sw0          ,
  input   logic             sw1          ,
  input   logic             sw2          ,
  output  logic  [10:0]     sdl_sx       ,
  output  logic  [ 9:0]     sdl_sy       ,
  output  logic             sdl_de       ,
  output  logic  [7:0]      sdl_r        ,
  output  logic  [7:0]      sdl_g        ,
  output  logic  [7:0]      sdl_b
);
//------------- Variables                                        -------------//
localparam SCREEN_WIDTH  = 800;
localparam SCREEN_HEIGHT = 600;

logic                      [10:0] h_coord;
logic                       [9:0] v_coord;
logic                       [3:0] red;
logic                       [3:0] green;
logic                       [3:0] blue;
logic                           disp_enbl;
logic  [$clog2(SCREEN_WIDTH)-1:0] screen_ball_x;
logic [$clog2(SCREEN_HEIGHT)-1:0] screen_ball_y;
logic                             ball_is_safe;
logic  [$clog2(SCREEN_WIDTH)-1:0] screen_x;
logic [$clog2(SCREEN_HEIGHT)-1:0] screen_y;
//____________________________________________________________________________//
/*
//------------- Demo module                                      -------------//
  game game_demo (
    //--------------------- Clock & Reset                ----------------------------//
      .pixel_clk              ( pixel_clk       ),
      .rst_n                  ( ~sim_rst        ),
    //--------------------- Buttons                      ----------------------------//
      .button_c               ( button_c        ),
      .button_u               ( button_u        ),
      .button_d               ( button_d        ),
      .button_r               ( button_r        ),
      .button_l               ( button_l        ),
    //--------------------- Accelerometer                ----------------------------//
      .accel_data_x           ( accel_data_x    ),
      .accel_data_y           ( accel_data_y    ),
      // verilator lint_off PINCONNECTEMPTY
      .accel_x_end_of_frame   (                 ),
      .accel_y_end_of_frame   (                 ),
      //verilator lint_on PINCONNECTEMPTY
    //--------------------- Pixcels Coordinates          ----------------------------//
      .h_coord                ( h_coord[10:0]   ),  // only bottom 11 bits needed to count to 800
      .v_coord                ( v_coord[ 9:0]   ),  // only bottom 10 bits needed to count to 600
    //--------------------- VGA outputs from demo        ----------------------------//
      .red                    ( red             ),  // 4-bit color output
      .green                  ( green           ),  // 4-bit color output
      .blue                   ( blue            ),  // 4-bit color output
    //--------------------- Switches for demo            ----------------------------//
      .SW                     ( {sw2, sw1, sw0} ),  // We are using switches to change background
    //--------------------- Demo regime status           ----------------------------//
      // verilator lint_off PINCONNECTEMPTY
      .demo_regime_status     (                 )   // Red led on the board which show REGIME
      // verilator lint_on PINCONNECTEMPTY
  );
//____________________________________________________________________________//
*/
game_engine # (
    .SCREEN_WIDTH  (SCREEN_WIDTH),
    .SCREEN_HEIGHT (SCREEN_HEIGHT)
) engine (
    .clk                (pixel_clk),
    .arst_n             (~sim_rst),

    // Accel
    .i_accel_dx         (8'b1), // TODO
    .i_accel_dy         (8'b1),
    // Switches
    .i_switches         ('0), // TODO
    // Buttons
    .i_btn_center       (), // TODO
    .i_btn_left         (),
    .i_btn_right        (),
    .i_btn_up           (button_u),
    .i_btn_down         (),
    // Mouse
    .i_mouse_dx         (),
    .i_mouse_dy         (),
    // Graphic
    .i_screen_x         (screen_x),
    .i_screen_y         (screen_y),
    .o_screen_ball_x    (screen_ball_x),
    .o_screen_ball_y    (screen_ball_y),
    .o_is_safe          (ball_is_safe),
    // Quad display
    .o_disp_data        ()
);

graphic # (
    .SCREEN_WIDTH       (SCREEN_WIDTH),
    .SCREEN_HEIGHT      (SCREEN_HEIGHT),
    .BALL_RADIUS        (20),

    .BALL_COLOR         (12'hF00),  // Red
    .SAFE_COLOR         (12'h0F0),  // Green
    .BKG_COLOR          (12'h00F)   // Blue
) graphic_inst (
    .o_screen_x         (screen_x),
    .o_screen_y         (screen_y),

    .i_is_safe          (ball_is_safe),

    .i_screen_ball_x    (screen_ball_x),
    .i_screen_ball_y    (screen_ball_y),

    // VGA
    .o_red              (red),     // 4-bit color output
    .o_green            (green),   // 4-bit color output
    .o_blue             (blue),    // 4-bit color output

    .i_disp_enbl        (disp_enbl),    // display enable (0 = all colors must be blank)
    .i_h_coord          (h_coord[10:0]),    // horizontal pixel coordinate
    .i_v_coord          (v_coord[ 9:0])
);

//------------- SDL controller                                   -------------//
  display_ctrl display_ctrl (
    .pixel_clk  ( pixel_clk     ), // Pixel clock 36MHz
    .rst_n      ( ~sim_rst      ), // Active low synchronous reset
    /* verilator lint_off PINCONNECTEMPTY */
    .h_sync     (               ), // horizontal sync signal
    .v_sync     (               ), // vertical sync signal
    /* verilator lint_on PINCONNECTEMPTY */
    .disp_enbl  ( disp_enbl     ), // display enable (0 = all colors must be blank)
    .h_coord    ( h_coord       ), // horizontal pixel coordinate
    .v_coord    ( v_coord       )  // vertical pixel coordinate
  );

  always_ff @( posedge pixel_clk ) begin
    sdl_sx <= h_coord   ;
    sdl_sy <= v_coord   ;
    sdl_de <= disp_enbl ;
    sdl_r  <= {2{red  }};
    sdl_g  <= {2{green}};
    sdl_b  <= {2{blue }};
  end
//____________________________________________________________________________//

endmodule
