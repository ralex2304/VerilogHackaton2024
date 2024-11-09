localparam MOUSE_ACCEL_DATA_WIDTH = 9;

module mouse_accel # (

)(
    input logic                                 rst_n   ,
    input logic                                 clk     ,

    output logic [MOUSE_ACCEL_DATA_WIDTH-1:0]   o_dx    , 
    output logic [MOUSE_ACCEL_DATA_WIDTH-1:0]   o_dy    ,
);

logic driver_packet_is_ready;

logic left_button_pressed;
logic right_button_pressed;
logic x_overflow;
logic y_overflow;
logic x_sign;
logic y_sign;
logic dx;
logic dy;

mouse_driver mouse_driver_interface (
    .rst_n                  (rst_n                  ),
    .clk                    (clk                    ),
    .o_send_packet          (driver_packet_is_ready ),
    .o_left_button_pressed  (left_button_pressed    ),
    .o_right_button_pressed (right_button_pressed   ),
    .o_x_overflow           (x_overflow             ),
    .o_y_overflow           (y_overflow             ),
    .o_x_sign               (x_sign                 ),
    .o_y_sign               (y_sign                 ),
    .o_dx                   (dx                     ),
    .o_dy                   (dy                     )
);

// FIXME 