module ball_positioner # (
    parameter SCREEN_WIDTH  = 800,
    parameter SCREEN_HEIGHT = 600,
    parameter BALL_RADIUS   = 20
)(
    input  logic        clk,
    input  logic        arst_n,

    input  logic  [7:0] i_accel_x,
    input  logic  [7:0] i_accel_y,

    output logic [9:0] o_ball_x,
    output logic [9:0] o_ball_y
);

localparam START_POS_X = SCREEN_WIDTH  / 2;
localparam START_POS_Y = SCREEN_HEIGHT / 2;

reg signed [10:0] ball_pos_x, ball_pos_y;
reg signed [10:0] velocity_x, velocity_y;

always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        ball_pos_x <= START_POS_X;
        ball_pos_y <= START_POS_Y;
        velocity_x <= 0;
        velocity_y <= 0;
    end else begin

        velocity_x <= velocity_x + {3'b0, signed'(i_accel_x)};
        velocity_y <= velocity_y + {3'b0, signed'(i_accel_y)};

        ball_pos_x <= ball_pos_x + velocity_x;
        ball_pos_y <= ball_pos_y + velocity_y;

        if (ball_pos_x < BALL_RADIUS) begin
            ball_pos_x <= BALL_RADIUS;
            velocity_x <= -velocity_x;
        end else if (ball_pos_x > SCREEN_WIDTH - BALL_RADIUS) begin
            ball_pos_x <= SCREEN_WIDTH - BALL_RADIUS;
            velocity_x <= -velocity_x;
        end

        // copypaste pohui =)
        if (ball_pos_y < BALL_RADIUS) begin
            ball_pos_y <= BALL_RADIUS;
            velocity_y <= -velocity_y;
        end else if (ball_pos_y > SCREEN_HEIGHT - BALL_RADIUS) begin
            ball_pos_y <= SCREEN_HEIGHT - BALL_RADIUS;
            velocity_y <= -velocity_y;
        end
    end
end

assign o_ball_x = unsigned'(ball_pos_x[9:0]);
assign o_ball_y = unsigned'(ball_pos_y[9:0]);

endmodule

