localparam CONTROL_PACKET_WIDTH = 8;
localparam POSITION_PACKET_WIDTH = 8;

module mouse_driver # (

)(
    input logic                                 rst_n                   ,
    input logic                                 clk                     , // main clock

    // inout
    input logic                                 io_data_mouse           ,
    input logic                                 io_clk_mouse            , 

    output logic                                o_send_packet           ,
    // output logic                                o_is_data_packet        ,
    // output logic [CONTROL_PACKET_WIDTH-1:0]     o_control_packet        ,
    // main packet:
    output logic                                o_left_button_pressed   ,
    output logic                                o_right_button_pressed  ,
    output logic                                o_x_overflow            ,
    output logic                                o_y_overflow            ,
    output logic                                o_x_sign                ,
    output logic                                o_y_sign                ,
    output logic [POSITION_PACKET_WIDTH-1:0]    o_dx                    ,
    output logic [POSITION_PACKET_WIDTH-1:0]    o_dy
);

// logic is_mouse_ready;

typedef enum {
    CONTROL_PART    = 1,
    X_PART          = 2,
    Y_PART          = 3,
    PACKET_IS_READY = 4
} wait_packet;

wait_packet wpacket;

logic [3*BYTE_WIDTH-1:0] full_packet;
logic [BYTE_WIDTH-1:0] packet_part;
// logic is_packet_part_ready;

mouse_read_byte mouse_read_interface (
    .rst_n              (rst_n                  ),
    .i_driver_clk       (clk                    ),
    .io_mouse_data      (io_mouse_data          ),
    .o_byte             (packet_part            ),
    .o_is_byte_readed   (is_packet_part_ready   ),    
);

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wpacket = CONTROL_PART;
        full_packet <= 0;
        o_send_packet <= 0;
    end else begin
        if (is_packet_part_ready) begin
            case (wpacket)
                CONTROL_PART: begin
                    full_packet[BYTE_WIDTH-1:0] <= packet_part;
                    wpacket <= X_PART;
                end
                X_PART: begin
                    full_packet[2*BYTE_WIDTH-1:BYTE_WIDTH] <= packet_part;
                    wpacket <= Y_PART; 
                end
                Y_PART: begin
                    full_packet[3*BYTE_WIDTH-1:2*BYTE_WIDTH] <= packet_part;
                    wpacket <= PACKET_IS_READY;
                    o_send_packet <= 1;
                end
                default: // REVIEW
            endcase
        end

        if (wpacket == PACKET_IS_READY) begin
            wpacket <= CONTROL_PART;
            o_send_packet <= 0;
            full_packet <= 0;
        end
    end
end

assign {o_dy                  , o_dx, 
        o_y_sign              , o_x_sign, 
        o_y_overflow          , o_x_overflow, 
        o_right_button_pressed, o_left_button_pressed} = full_packet;

endmodule