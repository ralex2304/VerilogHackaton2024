//NOTE вероять 99% эта хуйня не работает

localparam BYTE_WIDTH = 8;

module mouse_send_byte # (

)(
    input logic                         rst_n           ,
    input logic                         i_driver_clk    , // NOTE hz == io_mouse_clk

    inout logic                         io_mouse_clk    ,
    inout logic                         io_mouse_data   ,

    input logic                         i_send_byte     ,
    input logic     [BYTE_WIDTH-1:0]    i_byte          ,

    output logic                        o_is_byte_sended
);

localparam WRITE_STAGE_WIDTH = 4;
typedef enum bit[WRITE_STAGE_WIDTH-1:0] { 
    NO_REQUEST          = 0,

    CLK_TO_LOW          = 1,
    DATA_TO_LOW         = 2,
    RELEASE_CLK_CTRL    = 3,
    WAIT_ON_LOW         = 4,
    SEND_BYTE           = 5,
    SEND_PARITY         = 6,
    RELEASE_DATA_CTRL   = 7,
    WAIT_DATA_LOW_END   = 8,
    WAIT_CLK_LOW_END    = 9,
    WAIT_DATA_HIGH_END  = 10,
    WAIT_CLK_HIGH_END   = 11
} write_stage;

localparam TIMER_WIDTH = 4;
logic [TIMER_WIDTH-1:0] timer;
write_stage wstage;
logic parety_bit;
logic shift;

// REVIEW mb negedge clk
always @ (posedge i_driver_clk or negedge rst_n) begin
    if (!rst_n) begin
        wstage <= NO_REQUEST;
        timer <= BYTE_WIDTH;
        parety_bit <= 0;
        shift <= 0;
    end else begin
        if (i_send_byte) begin
            wstage <= CLK_TO_LOW;
        end
        
        if (wstage == CLK_TO_LOW) begin
            io_mouse_clk <= 0; // clk low to write
            wstage <= DATA_TO_LOW;
        end

        if (wstage == DATA_TO_LOW) begin
            io_mouse_data <= 0;
            wstage <= RELEASE_CLK_CTRL;
        end

        if (wstage == RELEASE_CLK_CTRL) begin
            io_mouse_clk <= 1;
            wstage <= WAIT_ON_LOW;
        end

        if (!io_mouse_clk & (wstage == WAIT_ON_LOW)) begin
            wstage <= SEND_BYTE;
            timer <= BYTE_WIDTH;
        end 

        if (wstage == SEND_BYTE) begin // FIXME mb should use port clkz
            if (timer == 0) begin
                wstage <= SEND_PARITY;
            end else begin
                  parety_bit <= parety_bit + (i_byte[shift] & 1'b1); // REVIEW
                io_mouse_data <= i_byte[shift];
                shift <= shift + 1;
                timer <= timer - 1;
            end
        end

        if (wstage == SEND_PARITY) begin
            io_mouse_data <= parety_bit;
            wstage <= RELEASE_DATA_CTRL;
        end

        if (wstage == RELEASE_DATA_CTRL) begin
            io_mouse_data <= 1;
            wstage <= WAIT_DATA_LOW_END;
        end

        if (wstage == WAIT_DATA_LOW_END) begin
            if (!io_mouse_data) begin
                wstage <= WAIT_CLK_LOW_END;
            end
        end

        if (wstage == WAIT_CLK_LOW_END) begin
            if (!io_mouse_clk) begin
                wstage <= WAIT_DATA_HIGH_END;
            end
        end

        if (wstage == WAIT_DATA_HIGH_END) begin
            if (io_mouse_data) begin
                wstage <= WAIT_CLK_HIGH_END;
            end
        end

        if (wstage == WAIT_CLK_HIGH_END) begin
            if (io_mouse_clk) begin
                o_is_byte_sended <= 1;
                wstage <= NO_REQUEST;
            end
        end
    end
end

endmodule