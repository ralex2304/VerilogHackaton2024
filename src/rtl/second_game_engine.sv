module second_game_engine # (
    parameter SECOND_GAME_START_X = 400,
    parameter SECOND_GAME_START_Y =   0,
    parameter SECOND_GAME_WIDTH   = 400,
    parameter SECOND_GAME_HEIGHT  = 600,

    parameter SECOND_GAME_PLAYER_SIZE = 30,
    parameter SECOND_GAME_SQUARE_SIZE = 20,
    parameter SECOND_GAME_BETWEEN_OBSTACLE_SIZE = 40,
    parameter SECOND_GAME_NUM_OBSTACLES = 5
)(
    input logic         clk,
    input logic         arst_n,

    input logic   [7:0] i_mouse_dx,
    input logic   [7:0] i_mouse_dy,

    input logic         i_is_mouse_dx_neg,
    input logic         i_is_mouse_dy_neg,

    input logic   [8:0] i_screen_x,
    input logic   [8:0] i_screen_y,

    output logic        o_is_obstacle,

    output logic  [8:0] o_ball_x,
    output logic        o_is_gameover
);

localparam SECOND_GAME_SQUARES_NUM_X = SECOND_GAME_WIDTH  / SECOND_GAME_SQUARE_SIZE;
localparam SECOND_GAME_SQUARES_NUM_Y = SECOND_GAME_HEIGHT / SECOND_GAME_SQUARE_SIZE;

/* fucking_shit_left--+    +--fucking_shit_right
*                     V    V
*    =================+    +========================================
*                     |    |
*    =================+    +========================================
*
*   2 variables for each obstacle
*/

logic [8:0] fucking_shit_left_x[SECOND_GAME_NUM_OBSTACLES];
logic [8:0] fucking_shit_left_y[SECOND_GAME_NUM_OBSTACLES];

logic [8:0] fucking_shit_right_x[SECOND_GAME_NUM_OBSTACLES];
logic [8:0] fucking_shit_right_y[SECOND_GAME_NUM_OBSTACLES];

logic [15:0] timer;
logic [8:0] ball_x;

always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin

        integer i;
        timer <= 'b0;
        ball_x <= SECOND_GAME_START_X;
        for (i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
            fucking_shit_left_x[i]  <= 100;
            fucking_shit_left_y[i]  <= (50 + i * (SECOND_GAME_SQUARE_SIZE + SECOND_GAME_BETWEEN_OBSTACLE_SIZE));
            fucking_shit_right_x[i] <= 200;
            fucking_shit_right_y[i] <= (50 + i * (SECOND_GAME_SQUARE_SIZE + SECOND_GAME_BETWEEN_OBSTACLE_SIZE));
        end

    end else begin

        integer i;
        ball_x <= ball_x + i_mouse_dx;
        timer <= timer + 1;
        if (timer == 0) begin

            for (i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
                fucking_shit_left_y [i] <= fucking_shit_left_y [i] + 1;
                fucking_shit_right_y[i] <= fucking_shit_right_y[i] + 1;
            end

        end
    end
end

always_comb begin
    integer i;
    o_is_obstacle = 1'b0;
    o_ball_x = ball_x;
    for (i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
        if (  i_screen_y >= fucking_shit_left_y[i] && i_screen_y <=  fucking_shit_left_y[i] + SECOND_GAME_SQUARE_SIZE &&
            !(i_screen_x >= fucking_shit_left_x[i] && i_screen_x <= fucking_shit_right_x[i] + SECOND_GAME_SQUARE_SIZE)) begin
            o_is_obstacle = 1'b1;
            break;
        end
    end
end

endmodule;
