module second_game_graphics # (
    parameter SECOND_GAME_START_X = 400,
    parameter SECOND_GAME_START_Y =   0,
    parameter SECOND_GAME_SCREEN_WIDTH   = 400,
    parameter SECOND_GAME_SCREEN_HEIGHT  = 600,
    parameter SECOND_GAME_PLAYER_SIZE = 20,

    parameter [11:0] SECOND_GAME_PLAYER_COLOR   = 12'hF00,  // Red
    parameter [11:0] SECOND_GAME_OBSTACLE_COLOR = 12'h0F0,  // Green
    parameter [11:0] SECOND_GAME_BKG_COLOR      = 12'h00F   // Blue
) (
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

    always_comb begin
        if (!i_disp_enbl) begin
            o_red   = 4'b0000;
            o_green = 4'b0000;
            o_blue  = 4'b0000;
        end else if (i_screen_square_x - SECOND_GAME_PLAYER_SIZE <= i_h_coord && i_h_coord <= i_screen_square_x + SECOND_GAME_PLAYER_SIZE
                  && i_screen_square_y - SECOND_GAME_PLAYER_SIZE <= i_v_coord && i_v_coord <= i_screen_square_y + SECOND_GAME_PLAYER_SIZE) begin
            {o_red, o_green, o_blue} = SECOND_GAME_PLAYER_COLOR;
        end else if (i_is_obstacle) begin
            {o_red, o_green, o_blue} = SECOND_GAME_OBSTACLE_COLOR;
        end else begin
            {o_red, o_green, o_blue} = SECOND_GAME_BKG_COLOR;
        end

        o_screen_x = i_h_coord[$clog2(SECOND_GAME_SCREEN_WIDTH )-1:0];
        o_screen_y = i_v_coord[$clog2(SECOND_GAME_SCREEN_HEIGHT)-1:0];
    end

endmodule
