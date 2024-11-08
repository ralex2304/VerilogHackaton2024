module graphic # (
    localparam SCREEN_WIDTH  = 800,
    localparam SCREEN_HEIGHT = 600
) (
    output logic  [$clog2(SCREEN_WIDTH)-1:0] o_screen_x,
    output logic [$clog2(SCREEN_HEIGHT)-1:0] o_screen_y,
    input  logic                             i_is_safe,

    input  logic  [$clog2(SCREEN_WIDTH)-1:0] i_screen_ball_x,
    input  logic [$clog2(SCREEN_HEIGHT)-1:0] i_screen_ball_y,

    // VGA
    output logic                       [3:0] red,        // 4-bit color output
    output logic                       [3:0] green,      // 4-bit color output
    output logic                       [3:0] blue,       // 4-bit color output

    input logic                              disp_enbl,  // display enable (0 = all colors must be blank)
    input logic                       [10:0] h_coord,    // horizontal pixel coordinate
    input logic                       [ 9:0] v_coord
);

// TODO

endmodule;
