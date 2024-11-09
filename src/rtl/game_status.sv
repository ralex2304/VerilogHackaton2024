// rating: проверяет текущий is_win / is_lose
//         хранит текущий рейтинг


module game_status # (
    parameter RATING_WIDTH = 8,
    parameter NUM_IMAGES   = 4
)(
    input  logic                                clk,
    input  logic                                rst_n,

    // safe zone
    input  logic                                i_is_win,
    input  logic                                i_is_lose,
    input  logic                                i_ready,
    output logic                                o_regenerate_level,

    // button
    input  logic                                i_pause_game,
    input  logic                                i_start_game,

    output logic             [RATING_WIDTH-1:0] o_current_rating,
    output logic                                o_game_running,
    output logic       [$clog2(NUM_IMAGES)-1:0] o_image_number
);

logic [RATING_WIDTH-1:0] rating_count;

logic reset_rating;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n || reset_rating) begin
        rating_count <= 0;
    end else begin
        if (i_is_lose || i_is_win)
            rating_count <= i_is_win ? rating_count + 1 : '0;
    end
end

assign o_current_rating = rating_count;

// game state
typedef enum logic [2:0] {
    INITIAL          = 3'h0,
    LEVEL_GENERATING = 3'h1,
    LEVEL_RUNNING    = 3'h2,
    LEVEL_PAUSED     = 3'h3,
    GAME_OVER        = 3'h4
} game_state;

game_state gstate, gstate_next;
// logic is_paused;

always_comb begin
    case (gstate)
        INITIAL:            gstate_next = i_start_game ? LEVEL_GENERATING : INITIAL;
        LEVEL_GENERATING:   gstate_next = i_ready ? LEVEL_RUNNING : LEVEL_GENERATING;
        LEVEL_RUNNING:      if (i_is_lose || i_is_win) begin
                                gstate_next = i_is_win ? LEVEL_GENERATING : GAME_OVER;
                            end else begin
                                gstate_next = i_pause_game ? LEVEL_PAUSED : LEVEL_RUNNING;
                            end
        LEVEL_PAUSED:       gstate_next = i_start_game ? LEVEL_RUNNING : LEVEL_PAUSED;
        GAME_OVER:          gstate_next = i_start_game ? LEVEL_GENERATING : GAME_OVER;
        default:            gstate_next = INITIAL;
    endcase
end

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        gstate <= INITIAL;
    end else begin
        gstate <= gstate_next;
    end
end

assign o_game_running     = (gstate == LEVEL_RUNNING);
assign o_regenerate_level = (gstate != LEVEL_GENERATING) && (gstate_next == LEVEL_GENERATING);
assign reset_rating       = (gstate == GAME_OVER) && (gstate_next != GAME_OVER);

always_comb begin
    case (gstate)
        INITIAL:            o_image_number = 2'b00;
        LEVEL_PAUSED:       o_image_number = 2'b01;
        GAME_OVER:          o_image_number = 2'b10;
        LEVEL_GENERATING:   o_image_number = 2'b11;

        default:            o_image_number = 2'b00;
    endcase
end

endmodule
