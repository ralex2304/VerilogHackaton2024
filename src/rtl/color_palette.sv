module color_palette # () (
    input  logic    [7:0] color_id,

    output logic    [11:0] color1,
    output logic    [11:0] color2,
    output logic    [11:0] color3
);

always_comb begin

    case (color_id)
        8'h00: begin
            color1 = 12'hF00;
            color2 = 12'h0F0;
            color3 = 12'h00F;
        end
        8'h01: begin
            color1 = 12'hFF0;
            color2 = 12'h0FF;
            color3 = 12'hF0F;
        end
        8'h02: begin
            color1 = 12'hFaa;
            color2 = 12'haaF;
            color3 = 12'haFa;
        end
        default: begin
            color1 = 12'hF00;
            color2 = 12'h0F0;
            color3 = 12'h00F;
        end
    endcase

end

endmodule
