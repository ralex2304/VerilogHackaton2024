module init_banner_rom (
  input  logic [12:0] addr,
  output logic [11:0] word
);

logic [11:0] init_image [100*50];

assign word = init_image[addr];

initial $readmemh("../../figures/spirt.txt", init_image);

endmodule
