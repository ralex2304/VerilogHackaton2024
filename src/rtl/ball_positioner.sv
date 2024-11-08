module ball_positioner # (
    parameter SCREEN_WIDTH  = 400,
    parameter SCREEN_HEIGHT = 600,
    parameter BALL_RADIUS   = 20
)(
    input  logic          clk,
    input  logic          arst_n,

    input  logic    [7:0] i_accel_x,
    input  logic    [7:0] i_accel_y,

    output logic    [8:0] o_ball_x,
    output logic    [9:0] o_ball_y
);

localparam START_POS_X = SCREEN_WIDTH  / 2;
localparam START_POS_Y = SCREEN_HEIGHT / 2;

localparam MAX_FRAC_VEL = 2**14;

logic signed [10:0] ball_pos_x, ball_pos_x_next,
                    ball_pos_y, ball_pos_y_next;
logic signed [10:0] velocity_x, velocity_x_next,
                    velocity_y, velocity_y_next;
logic signed [24:0]  velocity_frac_x, velocity_frac_x_next, 
                     velocity_frac_y, velocity_frac_y_next;

logic [19:0] timer;

always_comb begin
    if (velocity_frac_x > MAX_FRAC_VEL) begin
        velocity_x_next = velocity_x + 1;
        velocity_frac_x_next = 0;
    end else if (velocity_frac_x < -MAX_FRAC_VEL) begin
        velocity_x_next = velocity_x - 1;
        velocity_frac_x_next = 0;
    end else begin
        velocity_x_next = velocity_x;
        velocity_frac_x_next = velocity_frac_x + {17'b0, signed'(i_accel_x)};
    end

    if (velocity_frac_y > MAX_FRAC_VEL) begin
        velocity_y_next = velocity_y + 1;
        velocity_frac_y_next = 0;
    end else if (velocity_frac_y < -MAX_FRAC_VEL) begin
        velocity_y_next = velocity_y - 1;
        velocity_frac_y_next = 0;
    end else begin
        velocity_y_next = velocity_y;
        velocity_frac_y_next = velocity_frac_y + {17'b0, signed'(i_accel_y)};
    end

    ball_pos_x_next = ball_pos_x + velocity_x;
    ball_pos_y_next = ball_pos_y + velocity_y;

    if (ball_pos_x < BALL_RADIUS && velocity_x < 0) begin
        ball_pos_x_next = BALL_RADIUS;
        velocity_x_next = -(velocity_x >> 2);
    end else if (ball_pos_x > SCREEN_WIDTH - BALL_RADIUS && velocity_x > 0) begin
        ball_pos_x_next = SCREEN_WIDTH - BALL_RADIUS;
        velocity_x_next = -(velocity_x >> 2);
    end

    if (ball_pos_y < BALL_RADIUS && velocity_y < 0) begin
        ball_pos_y_next = BALL_RADIUS;
        velocity_y_next = -(velocity_y >> 2);
    end else if (ball_pos_y > SCREEN_HEIGHT - BALL_RADIUS && velocity_y > 0) begin
        ball_pos_y_next = SCREEN_HEIGHT - BALL_RADIUS;
        velocity_y_next = -(velocity_y >> 2);
    end
end

always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        ball_pos_x <= START_POS_X;
        ball_pos_y <= START_POS_Y;
        velocity_x <= 0;
        velocity_y <= 0;
        velocity_frac_x <= 0;
        velocity_frac_y <= 0;
        timer <= 0;
    end else if (timer == 0) begin
        velocity_x <= velocity_x_next;
        velocity_y <= velocity_y_next;
        ball_pos_x <= ball_pos_x_next;
        ball_pos_y <= ball_pos_y_next;
        velocity_frac_x <= velocity_frac_x_next;
        velocity_frac_y <= velocity_frac_y_next;

        $display("accell_x        = %d", signed'(i_accel_x));
        $display("velocity_x      = %d", signed'(velocity_x));
        $display("velocity_frac_x = %d", signed'(velocity_frac_x));
    end
end

always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        timer <= '0;
    end else begin
        timer <= timer + 1;
    end
end

assign o_ball_x = ball_pos_x[8:0];
assign o_ball_y = ball_pos_y[9:0];

endmodule
