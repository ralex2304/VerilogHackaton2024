localparam BYTE_WIDTH = 8;

module mouse_read_byte # (

)(
    input logic                         rst_n           ,

    input logic                         io_mouse_clk    ,
    input logic                         io_mouse_data   ,

    output logic   [BYTE_WIDTH-1:0]     o_byte          ,

    output logic                        o_is_byte_readed
);

localparam READ_STAGE_WIDTH = 4;
typedef enum bit[READ_STAGE_WIDTH-1:0] {
    // NO_REQUEST            = 0,

    WAIT_DATA_ON_LOW      = 1,
    RECEIVE_BYTE          = 2,
    RECEIVE_PARITY        = 3,
    WAIT_DATA_ON_HIGH     = 4
    // REMOVE_BYTE_READED    = 5,
} read_stage;

localparam TIMER_WIDTH = 4;
logic [TIMER_WIDTH-1:0] timer;
read_stage rstage;
// logic parety_bit;
logic [$clog2(BYTE_WIDTH)-1:0] shift;

// NOTE negedge clk
always @ (negedge io_mouse_clk or negedge rst_n) begin
    if (!rst_n) begin
        timer <= BYTE_WIDTH - 1;
        shift <= 0;

        o_is_byte_readed <= 0;
        o_byte <= 0; // ?

        rstage <= WAIT_DATA_ON_LOW;
        // parety_bit <= 0;
    end else begin
        if (rstage == WAIT_DATA_ON_LOW) begin
            o_is_byte_readed <= 0;
            o_byte <= 0; // ?
            timer <= BYTE_WIDTH - 1;
            shift <= 0;

            if (io_mouse_data == 0) begin
                rstage <= RECEIVE_BYTE;
            end

        end

        if (rstage == RECEIVE_BYTE) begin
            if (timer == 0) begin
                rstage <= RECEIVE_PARITY;
            end else begin
                o_byte[shift] <= io_mouse_data;
                // o_byte <= o_byte << 1;
                shift <= shift + 1;

                timer <= timer - 1;
            end
        end

        if (rstage == RECEIVE_PARITY) begin
            // parety_bit <= io_mouse_data; // ignores parety bit then
            rstage <= WAIT_DATA_ON_HIGH;
        end

        if (rstage == WAIT_DATA_ON_HIGH) begin
            if (io_mouse_data == 1) begin
                o_is_byte_readed <= 1;

                // rstage <= REMOVE_BYTE_READED;
                rstage <= WAIT_DATA_ON_LOW;
            end
        end

        // if (rstage == REMOVE_BYTE_READED) begin

        //     rstage <= NO_REQUEST;
        // end
    end
end

endmodule

