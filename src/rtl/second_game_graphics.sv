module second_game_graphics # (
    parameter SECOND_GAME_START_X = 400,
    parameter SECOND_GAME_START_Y =   0,
    parameter SECOND_GAME_SCREEN_WIDTH   = 400,
    parameter SECOND_GAME_SCREEN_HEIGHT  = 600,
    parameter SECOND_GAME_PLAYER_SIZE = 20
) (
    input logic                                   [11:0] i_player_color,
    input logic                                   [11:0] i_obstacle_color,
    input logic                                   [11:0] i_bkg_color,

    output logic [$clog2(SECOND_GAME_SCREEN_WIDTH )-1:0] o_screen_x,
    output logic [$clog2(SECOND_GAME_SCREEN_HEIGHT)-1:0] o_screen_y,

    input  logic                                         i_is_obstacle,

    input  logic [$clog2(SECOND_GAME_SCREEN_WIDTH )-1:0] i_screen_square_x,
    input  logic [$clog2(SECOND_GAME_SCREEN_HEIGHT)-1:0] i_screen_square_y,

    // VGA
    output logic                                   [3:0] o_red,        // 4-bit color output
    output logic                                   [3:0] o_green,      // 4-bit color output
    output logic                                   [3:0] o_blue,       // 4-bit color output

    input logic                                          i_disp_enbl,  // display enable (0 = all colors must be blank)
    input logic                                   [10:0] i_h_coord,    // horizontal pixel coordinate
    input logic                                   [ 9:0] i_v_coord
);

logic signed [9:0]  screen_square_x;
logic signed [10:0] screen_square_y;

logic signed [10:0] h_coord;
logic signed [10:0] v_coord;

assign screen_square_x = signed'(10'(i_screen_square_x));
assign screen_square_y = signed'(11'(i_screen_square_y));

assign h_coord = 11'(signed'(12'(i_h_coord)) - 12'(SECOND_GAME_START_X));
assign v_coord = signed'(11'(i_v_coord));

always_comb begin
    if (!i_disp_enbl) begin
        o_red   = 4'b0000;
        o_green = 4'b0000;
        o_blue  = 4'b0000;
    end else if (   screen_square_x - SECOND_GAME_PLAYER_SIZE <= h_coord && h_coord <= screen_square_x + SECOND_GAME_PLAYER_SIZE
                 && screen_square_y - SECOND_GAME_PLAYER_SIZE <= v_coord && v_coord <= screen_square_y + SECOND_GAME_PLAYER_SIZE) begin
        {o_red, o_green, o_blue} = i_player_color;
    end else if (i_is_obstacle) begin
        {o_red, o_green, o_blue} = i_obstacle_color;
    end else begin
        {o_red, o_green, o_blue} = i_bkg_color;
    end

    o_screen_x = h_coord[$clog2(SECOND_GAME_SCREEN_WIDTH )-1:0];
    o_screen_y = v_coord[$clog2(SECOND_GAME_SCREEN_HEIGHT)-1:0];
end

endmodule
