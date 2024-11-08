// rating: проверяет текущий is_win / is_lose
//         хранит текущий рейтинг

// not started
// running 
// paused
// game over

module game_status # (
    // parameters
    localparam RATING_WIDTH     = 8,
    localparam GAME_STATE_WIDTH = 2
)(
    input logic                                 clk             ,
    input logic                                 rst_n           ,  

    // safe zone (?)
    input logic                                 i_is_win        ,
    input logic                                 i_round_ended   ,

    // button
    input logic                                 i_pause_game    ,  
    output logic                                o_is_game_paused,    

    output logic    [RATING_WIDTH - 1 : 0]      o_current_rating,
    output logic    [GAME_STATE_WIDTH - 1 : 0]  o_game_status   ,
);

// rating

logic [RATING_WIDTH - 1 : 0] rating_count;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rating_count <= 0;
    end else begin
        if (i_round_ended)
            rating_count <= i_is_win ? rating_count + 1
                                     : 1'b0;
    end
end

assign o_current_rating = rating_count;

// game state

typedef enum bit[GAME_STATE_WIDTH - 1 : 0] {
    LEVEL_GENERATING = 2'b00,
    LEVEL_RUNNING    = 2'b01,
    GAME_OVER        = 2'b10
} game_state;

game_state gstate;
// logic is_paused;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        gstate <= LEVEL_GENERATING;
    end else begin
        if (!i_pause_game) begin // NOTE ?
            if (i_round_ended) begin
                gstate <= i_is_win ? LEVEL_GENERATING
                                   : GAME_OVER;
            end
        end
    end
end 

assign o_game_status = gstate;

// game pause

assign o_is_game_paused = i_pause_game;


endmodule