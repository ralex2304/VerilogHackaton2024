localparam CONTROL_PACKET_WIDTH = 8;
localparam POSITION_PACKET_WIDTH = 8;

module mouse_driver # (

)(
    input logic                                 rst_n                   ,
    input logic                                 clk                     , // main clock

    input logic                                 io_data_mouse           ,
    input logic                                 io_clk_mouse            ,

    output logic                                o_left_button_pressed   ,
    output logic                                o_right_button_pressed  ,
    output logic                                o_x_overflow            ,
    output logic                                o_y_overflow            ,
    output logic                                o_x_sign                ,
    output logic                                o_y_sign                ,
    output logic [POSITION_PACKET_WIDTH-1:0]    o_dx                    ,
    output logic [POSITION_PACKET_WIDTH-1:0]    o_dy
);

typedef enum {
    CONTROL_PART    = 1,
    X_PART          = 2,
    Y_PART          = 3,
    PACKET_IS_READY = 4
} wait_packet;

wait_packet wpacket;

logic [3*BYTE_WIDTH-1:0] full_packet;
logic [BYTE_WIDTH-1:0] packet_part;
logic is_packet_part_ready;
logic packet_readed;

mouse_read_byte mouse_read_interface (
    .rst_n              (rst_n                  ),

    .io_mouse_clk       (io_clk_mouse           ),
    .io_mouse_data      (io_data_mouse          ),
    .o_byte             (packet_part            ),
    .o_is_byte_readed   (is_packet_part_ready   )
);

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wpacket <= CONTROL_PART;
        full_packet <= 0;
        packet_readed <= 1'b1;
    end else begin
        if (is_packet_part_ready && !packet_readed) begin
            packet_readed <= 1'b1;
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
                end
            endcase
        end else begin
            if (!is_packet_part_ready) begin
                packet_readed <= 1'b0;
            end

            if (wpacket == PACKET_IS_READY) begin
                full_packet <= 0;
                wpacket <= CONTROL_PART;
            end
        end
    end
end

logic [1:0] padding;

assign {o_dy                  , o_dx,
        o_y_sign              , o_x_sign,
        o_y_overflow          , o_x_overflow,
        padding,
        o_right_button_pressed, o_left_button_pressed} = (wpacket == PACKET_IS_READY) ? full_packet : '0;

endmodule
