module graphic # (
    parameter SCREEN_WIDTH   = 400,
    parameter SCREEN_HEIGHT  = 600,
    parameter BALL_RADIUS    = 10
) (
    input logic                       [11:0] i_ball_color,
    input logic                       [11:0] i_safe_color,
    input logic                       [11:0] i_bkg_color,

    output logic [$clog2(SCREEN_WIDTH )-1:0] o_screen_x,
    output logic [$clog2(SCREEN_HEIGHT)-1:0] o_screen_y,

    input  logic                             i_is_safe,

    input  logic [$clog2(SCREEN_WIDTH )-1:0] i_screen_ball_x,
    input  logic [$clog2(SCREEN_HEIGHT)-1:0] i_screen_ball_y,

    // VGA
    output logic                       [3:0] o_red,        // 4-bit color output
    output logic                       [3:0] o_green,      // 4-bit color output
    output logic                       [3:0] o_blue,       // 4-bit color output

    input logic                              i_disp_enbl,  // display enable (0 = all colors must be blank)
    input logic                       [10:0] i_h_coord,    // horizontal pixel coordinate
    input logic                       [ 9:0] i_v_coord
);

    localparam BALL_RADIUS_SQ = BALL_RADIUS * BALL_RADIUS;

    logic signed  [9:0] h_ball_pos_diff;
    logic signed [10:0] v_ball_pos_diff;
    logic        [21:0] ball_dist_squared;

    assign h_ball_pos_diff = signed'(10'(i_h_coord) - 10'(i_screen_ball_x));
    assign v_ball_pos_diff = signed'((i_v_coord) - 11'(i_screen_ball_y));

    assign ball_dist_squared = h_ball_pos_diff * h_ball_pos_diff +
                               v_ball_pos_diff * v_ball_pos_diff;

    always_comb begin
        if (!i_disp_enbl) begin
            o_red   = 4'b0000;
            o_green = 4'b0000;
            o_blue  = 4'b0000;
        end else if (ball_dist_squared <= BALL_RADIUS_SQ) begin
            {o_red, o_green, o_blue} = i_ball_color;
        end else if (i_is_safe) begin
            {o_red, o_green, o_blue} = i_safe_color;
        end else begin
            {o_red, o_green, o_blue} = i_bkg_color;
        end

        o_screen_x = i_h_coord[$clog2(SCREEN_WIDTH )-1:0];
        o_screen_y = i_v_coord[$clog2(SCREEN_HEIGHT)-1:0];
    end



endmodule
