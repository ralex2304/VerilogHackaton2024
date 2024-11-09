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
    CONTROL_PART = 1,
    X_PART       = 2,
    Y_PART       = 3,
} wait_packet;

wait_packet wpacket;

logic [3*BYTE_WIDTH-1:0] full_packet;
logic [BYTE_WIDTH-1:0] packet_part;
logic is_packet_part_ready;

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
    end else begin
        if (is_packet_part_ready) begin
            case (wpacket)
                CONTROL_PART: begin
                    full_packet
                end
                
                X_PART: begin
                    
                end

                Y_PART: begin
                    
                end
                default: // REVIEW
            endcase
        end
    end
end


endmodule