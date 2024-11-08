// rating: проверяет текущий is_win / is_lose
//         хранит текущий рейтинг

module rating # (
    // parameters
    localparam RATING_WIDTH = 8
)(
    input logic                             clk             ,
    input logic                             rst_n           ,  

    input logic                             i_is_win        ,
    input logic                             i_round_ended   ,

    output logic    [RATING_WIDTH - 1 : 0]  o_current_rating
);


logic [RATING_WIDTH - 1 : 0] rating_count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rating_count <= 0;
    else   
        if (i_round_ended)
            rating_count <= i_is_win 
                                ? rating_count + 1
                                : 1'b0;
end

assign o_current_rating = rating_count;

endmodule