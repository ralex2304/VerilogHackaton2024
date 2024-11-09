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
    input logic   [9:0] i_screen_y,

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

logic [8:0]  fucking_shit_left_x[SECOND_GAME_NUM_OBSTACLES];
logic [10:0] fucking_shit_left_y[SECOND_GAME_NUM_OBSTACLES];

logic [8:0]  fucking_shit_right_x[SECOND_GAME_NUM_OBSTACLES];
logic [10:0] fucking_shit_right_y[SECOND_GAME_NUM_OBSTACLES];

// NOTE: change timer size to chenge speed
logic [14:0] timer;
logic [8:0] ball_x;

logic [9:0] hole_size;
logic [1:0] hole_smallanator;

logic [7:0] random;
pseudo_random_generator prg_inst (
    .clk    (clk),
    .arst_n (arst_n),
    .o_prng (random)
);

logic random_sign;

assign random_sign = random[3] ^ random[1] ^ random[2] ^ random[4];

always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin

        integer i;
        timer <= 'b0;
        hole_size <= 75;
        hole_smallanator <= 1;
        ball_x <= 9'(SECOND_GAME_START_X);
        for (i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
            fucking_shit_left_y [i] <= 11'(50 + i * (SECOND_GAME_SQUARE_SIZE + SECOND_GAME_BETWEEN_OBSTACLE_SIZE));
            fucking_shit_right_y[i] <= 11'(50 + i * (SECOND_GAME_SQUARE_SIZE + SECOND_GAME_BETWEEN_OBSTACLE_SIZE));
        end

    end else begin

        integer i;

        if (hole_size > 40 && hole_smallanator == 0) begin
            hole_size <= hole_size - 1;
            hole_smallanator <= hole_smallanator + 1;
        end else begin
            hole_size <= hole_size;
        end

        ball_x <= ball_x + i_mouse_dx;
        timer <= timer + 1;
        if (timer == 0) begin

            for (i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
                if (fucking_shit_left_y[i] > SECOND_GAME_HEIGHT) begin
                    fucking_shit_left_y [i] <= 0;
                    fucking_shit_right_y[i] <= 0;

                    $display("hole_size: %d", 9'(unsigned'(hole_size)));

                    fucking_shit_left_x [i] <= 200 + signed'(random[7:0]) - 9'(signed'(hole_size));
                    fucking_shit_right_x[i] <= 200 + signed'(random[7:0]) + 9'(signed'(hole_size));

                    hole_smallanator <= hole_smallanator + 1;

                end else begin
                    fucking_shit_left_y [i] <= fucking_shit_left_y [i] + 1;
                    fucking_shit_right_y[i] <= fucking_shit_right_y[i] + 1;
                end
            end

        end
    end
end

always_comb begin
    integer i;
    o_is_obstacle = 1'b0;
    o_ball_x = ball_x;
    for (i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
        if (  11'(i_screen_y) >= fucking_shit_left_y[i] && 11'(i_screen_y) <=  fucking_shit_left_y[i] + SECOND_GAME_SQUARE_SIZE &&
            !( 9'(i_screen_x) >= fucking_shit_left_x[i] &&  9'(i_screen_x) <= fucking_shit_right_x[i])) begin
            // $display("left:   %d", fucking_shit_left_x[i]);
            // $display("right:  %d", fucking_shit_right_x[i]);
            // $display("i_screen: %d %d", i_screen_x, i_screen_y);
            o_is_obstacle = 1'b1;
            break;
        end
    end
end

endmodule;
