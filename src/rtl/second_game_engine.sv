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
    input logic         i_is_pause,

    output logic        o_is_obstacle,

    output logic  [8:0] o_ball_x,
    output logic  [9:0] o_ball_y,

    output logic        o_is_lose
);

localparam SECOND_GAME_SQUARES_NUM_X = SECOND_GAME_WIDTH  / SECOND_GAME_SQUARE_SIZE;
localparam SECOND_GAME_SQUARES_NUM_Y = SECOND_GAME_HEIGHT / SECOND_GAME_SQUARE_SIZE;

localparam SQUARE_RADIUS = SECOND_GAME_SQUARE_SIZE / 2;

/* fucking_shit_left--+    +--fucking_shit_right
*                     V    V
*    =================+    +========================================
*                     |    |
*    =================+    +========================================
*
*   2 variables for each obstacle
*/

logic [8:0]  fucking_shit_left_x[SECOND_GAME_NUM_OBSTACLES];
logic signed [11:0] fucking_shit_left_y[SECOND_GAME_NUM_OBSTACLES];

logic [8:0]  fucking_shit_right_x[SECOND_GAME_NUM_OBSTACLES];
logic signed [11:0] fucking_shit_right_y[SECOND_GAME_NUM_OBSTACLES];

// NOTE: change timer size to chenge speed
logic [17:0] timer;
logic [8:0] ball_x;
logic [9:0] ball_y;

logic [9:0] hole_size;
logic [1:0] hole_smallanator;

logic [7:0] random;
pseudo_random_generator prg_inst (
    .clk    (clk),
    .arst_n (arst_n),
    .o_prng (random)
);

logic is_loss;

always_ff @(posedge clk or negedge arst_n) begin
    is_loss <= 0;
    if (!arst_n) begin

        integer i;
        is_loss <= 0;
        timer <= 'b0;
        hole_size <= 75;
        hole_smallanator <= 1;
        ball_x <=  9'(SECOND_GAME_WIDTH / 2);
        ball_y <= 10'(SECOND_GAME_HEIGHT - 100);
        for (i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
            fucking_shit_left_y [i] <= 12'(signed'(-400 + i * (SECOND_GAME_SQUARE_SIZE + SECOND_GAME_BETWEEN_OBSTACLE_SIZE)));
            fucking_shit_right_y[i] <= 12'(signed'(-400 + i * (SECOND_GAME_SQUARE_SIZE + SECOND_GAME_BETWEEN_OBSTACLE_SIZE)));
            fucking_shit_left_x [i] <= 50;
            fucking_shit_right_x[i] <= 350;
        end

    end else if (i_is_pause) begin

    end else if (is_loss) begin
        for (integer i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
            fucking_shit_left_y [i] = 12'(signed'(-400 + i * (SECOND_GAME_SQUARE_SIZE + SECOND_GAME_BETWEEN_OBSTACLE_SIZE)));
            fucking_shit_right_y[i] = 12'(signed'(-400 + i * (SECOND_GAME_SQUARE_SIZE + SECOND_GAME_BETWEEN_OBSTACLE_SIZE)));
            fucking_shit_left_x [i] = 50;
            fucking_shit_right_x[i] = 350;
        end
    end else begin
        if (hole_size > 40 && hole_smallanator == 0) begin
            hole_size <= hole_size - 1;
            hole_smallanator <= hole_smallanator + 1;
        end else begin
            hole_size <= hole_size;
        end

        ball_x <= ball_x + i_mouse_dx;
        timer <= timer + 1;
        if (timer == 0) begin

            for (integer i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
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

            for (integer i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
                if ( 12'(signed'(ball_y - SQUARE_RADIUS)) >= fucking_shit_left_y[i] && 12'(signed'(ball_y - SQUARE_RADIUS)) <= fucking_shit_left_y [i] + SECOND_GAME_SQUARE_SIZE &&
                    !(9'(ball_x - 9'(SQUARE_RADIUS)) >= fucking_shit_left_x[i] &&  9'(ball_x - 9'(SQUARE_RADIUS)) <= fucking_shit_right_x[i])) begin
                    is_loss <= 1;
                    $display("is_loss: %d", is_loss);
                    break;
                end
                if ( 12'(signed'(ball_y + SQUARE_RADIUS)) >= fucking_shit_left_y[i] && 12'(signed'(ball_y + SQUARE_RADIUS)) <= fucking_shit_left_y [i] + SECOND_GAME_SQUARE_SIZE &&
                    !(9'(ball_x + 9'(SQUARE_RADIUS)) >= fucking_shit_left_x[i] &&  9'(ball_x + 9'(SQUARE_RADIUS)) <= fucking_shit_right_x[i])) begin
                    is_loss <= 1;
                    $display("is_loss: %d", is_loss);
                    break;
                end
                if ( 12'(signed'(ball_y - SQUARE_RADIUS)) >= fucking_shit_left_y[i] && 12'(signed'(ball_y - SQUARE_RADIUS)) <= fucking_shit_left_y [i] + SECOND_GAME_SQUARE_SIZE &&
                    !(9'(ball_x + 9'(SQUARE_RADIUS)) >= fucking_shit_left_x[i] &&  9'(ball_x + 9'(SQUARE_RADIUS)) <= fucking_shit_right_x[i])) begin
                    is_loss <= 1;
                    $display("is_loss: %d", is_loss);
                    break;
                end
                if ( 12'(signed'(ball_y + SQUARE_RADIUS)) >= fucking_shit_left_y[i] && 12'(signed'(ball_y + SQUARE_RADIUS)) <= fucking_shit_left_y [i] + SECOND_GAME_SQUARE_SIZE &&
                    !(9'(ball_x - 9'(SQUARE_RADIUS)) >= fucking_shit_left_x[i] &&  9'(ball_x - 9'(SQUARE_RADIUS)) <= fucking_shit_right_x[i])) begin
                    is_loss <= 1;
                    $display("is_loss: %d", is_loss);
                    break;
                end
            end

        end
    end
end

always_comb begin
    integer i;
    o_is_obstacle = 1'b0;
    o_ball_x = ball_x;
    o_ball_y = ball_y;
    o_is_lose = is_loss;

    for (i = 0; i < SECOND_GAME_NUM_OBSTACLES; i++) begin
        if (  12'(signed'(i_screen_y)) >= fucking_shit_left_y[i] && 12'(signed'(i_screen_y)) <=  fucking_shit_left_y[i] + SECOND_GAME_SQUARE_SIZE &&
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
