module banners #(
    SCREEN_WIDTH  = 800,
    SCREEN_HEIGHT = 600,
    NUM_IMAGES    = 4
) (
    input logic [$clog2(NUM_IMAGES)-1:0] i_banner_num,
    input logic                          i_disp_enbl,
    input logic                   [10:0] i_h_coord,
    input logic                   [ 9:0] i_v_coord,

    output logic                   [3:0] o_red,
    output logic                   [3:0] o_green,
    output logic                   [3:0] o_blue
);

logic  [$clog2(SCREEN_WIDTH)-1:0] screen_x;
logic [$clog2(SCREEN_HEIGHT)-1:0] screen_y;

logic [2:0][3:0] init_banner_pixel, pause_banner_pixel, game_over_banner_pixel, lvl_regen_banner_pixel;

always_comb begin
    banner_pixel_coord = full_banner_pixel_coord;
    if (!i_disp_enbl) begin
        o_red   = 4'b0000;
        o_green = 4'b0000;
        o_blue  = 4'b0000;
    end else if (i_banner_num == 2'b00) begin // initial
        {o_blue, o_green, o_red} = init_banner_pixel;
    end else if (i_banner_num == 2'b01) begin // pause
        {o_blue, o_green, o_red} = pause_banner_pixel;
    end else if (i_banner_num == 2'b10) begin // game over
        {o_blue, o_green, o_red} = game_over_banner_pixel;
    end else if (i_banner_num == 2'b11 && screen_x < SCREEN_WIDTH/2) begin // regenerating level
        banner_pixel_coord = half_screen_banner_pixel_coord;
        {o_blue, o_green, o_red} = lvl_regen_banner_pixel;
    end else begin
        {o_blue, o_green, o_red} = '0;
    end
end

assign screen_x = i_h_coord[$clog2(SCREEN_WIDTH)-1:0];
assign screen_y = i_v_coord[$clog2(SCREEN_HEIGHT)-1:0];

// 100x50 pixels

logic [13-1:0] banner_pixel_coord, full_banner_pixel_coord, half_screen_banner_pixel_coord;

assign full_banner_pixel_coord = 13'(screen_x) - 13'(SCREEN_WIDTH/2 - 50) +
                                 13'((13'(screen_y) - 13'(SCREEN_HEIGHT/2 - 25))*(13'd100));

assign half_screen_banner_pixel_coord = 13'(screen_x) - 13'(SCREEN_WIDTH/4 - 50) +
                                        13'((13'(screen_y) - 13'(SCREEN_HEIGHT/2 - 25))*(13'd100));

logic [2:0][3:0] init_banner_rom_resp;

always_comb begin
    if ((SCREEN_WIDTH/2  - 50 <= screen_x && screen_x < SCREEN_WIDTH/2  + 50) &&
        (SCREEN_HEIGHT/2 - 25 <= screen_y && screen_y < SCREEN_HEIGHT/2 + 25)) begin
        init_banner_pixel = init_banner_rom_resp;
    end else begin
        init_banner_pixel = '0;
    end
end

assign pause_banner_pixel     = init_banner_pixel;
assign game_over_banner_pixel = init_banner_pixel;

always_comb begin
    if ((SCREEN_WIDTH/4  - 50 <= screen_x && screen_x < SCREEN_WIDTH/4  + 50) &&
        (SCREEN_HEIGHT/2 - 25 <= screen_y && screen_y < SCREEN_HEIGHT/2 + 25)) begin
        lvl_regen_banner_pixel = init_banner_rom_resp;
    end else begin
        lvl_regen_banner_pixel = '0;
    end
end

//`define VIVADO

`ifdef VIVADO

init_banner_rom_gen init_banner_rom_inst (
    .a(banner_pixel_coord),     // input wire [12 : 0] a
    .spo(init_banner_rom_resp)  // output wire [11 : 0] spo
);

`else

init_banner_rom init_banner_rom_inst (
    .addr(banner_pixel_coord),
    .word(init_banner_rom_resp)
);

`endif

endmodule
