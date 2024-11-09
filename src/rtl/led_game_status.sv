
module led_game_status # (

)(
    input logic         rst_n       ,
    input logic         clk         ,

    input logic [1:0]   game1_state , // 1 == is_win, 0 == is_lose
    input logic [1:0]   game2_state ,

    output logic [2:0]  led16       ,
    output logic [2:0]  led17
);

localparam [2:0] RED   = 3'b100;
localparam [2:0] GREEN = 3'b010;
localparam [2:0] BLUE  = 3'b001;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        case (game1_state)
            2'b00: led16 <= 0;
            2'b01: led16 <= 0;
            2'b10: led16 <= 0;
            2'b11: led16 <= 0;
        endcase
    end else begin
        case (game1_state)
            2'b00: led16 <= BLUE;       // paused
            2'b01: led16 <= GREEN;      // win
            2'b10: led16 <= RED;        // lose
            2'b11: led16 <= RED & BLUE; // what?)
        endcase
    end
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        case (game1_state)
            2'b00: led17 <= 0;
            2'b01: led17 <= 0;
            2'b10: led17 <= 0;
            2'b11: led17 <= 0;
        endcase
    end else begin
        case (game1_state)
            2'b00: led17 <= BLUE;       // paused
            2'b01: led17 <= GREEN;      // win
            2'b10: led17 <= RED;        // lose
            2'b11: led17 <= RED & BLUE; // what?)
        endcase
    end
end

endmodule