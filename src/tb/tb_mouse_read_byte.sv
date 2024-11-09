
module tb_mouse_read_byte ();

`timescale 10 ns / 1ps
logic clk;
logic rst_n;

// logic mouse_clk;
logic mouse_data;

logic [7:0] byte_reg;
logic is_byte_readed;


always begin #2 $dumpvars; clk <= ~clk; end
// assign mouse_clk = clk;

initial $dumpfile("dump.svc");

initial begin
    clk = 1;
    rst_n = 0;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    rst_n = 1;

    mouse_data = 1;
    byte_reg = 0;

    // 1 packet -----------------------------------

    // signal 0
    @(negedge clk);
    mouse_data = 0;
    
    // data
    @(negedge clk);
    mouse_data = 0;

    @(negedge clk);
    mouse_data = 0;
    
    @(negedge clk);
    mouse_data = 1;

    @(negedge clk);
    mouse_data = 0;

    @(negedge clk);
    mouse_data = 0;
   
    @(negedge clk);
    mouse_data = 1;
   
    @(negedge clk);
    mouse_data = 0;

    @(negedge clk);
    mouse_data = 0;

    // parity
    @(negedge clk);
    mouse_data = 1;

    // closing
    @(negedge clk);
    mouse_data = 1;

    $display("byte_reg: %x\n", byte_reg);
    $display("is_byte_readed: %d\n", is_byte_readed);

    // 2 packet -----------------------------------

    // signal 0
    @(negedge clk);
    mouse_data = 0;
    
    // data
    @(negedge clk);
    mouse_data = 1;

    @(negedge clk);
    mouse_data = 0;
    
    @(negedge clk);
    mouse_data = 0;

    @(negedge clk);
    mouse_data = 0;

    @(negedge clk);
    mouse_data = 0;
   
    @(negedge clk);
    mouse_data = 0;
   
    @(negedge clk);
    mouse_data = 0;

    @(negedge clk);
    mouse_data = 0;

    // parity
    @(negedge clk);
    mouse_data = 1;

    // closing
    @(negedge clk);
    mouse_data = 1;

    $display("byte_reg: %x\n", byte_reg);
    $display("is_byte_readed: %d\n", is_byte_readed);

    // 3 packet -----------------------------------

    // signal 0
    @(negedge clk);
    mouse_data = 0;
    
    // data
    @(negedge clk);
    mouse_data = 1;

    @(negedge clk);
    mouse_data = 1;
    
    @(negedge clk);
    mouse_data = 0;

    @(negedge clk);
    mouse_data = 0;

    @(negedge clk);
    mouse_data = 0;
   
    @(negedge clk);
    mouse_data = 0;
   
    @(negedge clk);
    mouse_data = 0;

    @(negedge clk);
    mouse_data = 0;

    // parity
    @(negedge clk);
    mouse_data = 1;

    // closing
    @(negedge clk);
    mouse_data = 1;

    @(negedge clk);

    $display("byte_reg: %x\n", byte_reg);
    $display("is_byte_readed: %d\n", is_byte_readed);

    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);


    $exit();
end

mouse_read_byte dut (
    .rst_n(rst_n)                     ,
    .i_driver_clk(clk)                ,
    // .io_mouse_clk(mouse_clk)          ,
    .io_mouse_data(mouse_data)        ,
    .o_byte(byte_reg)                 ,
    .o_is_byte_readed(is_byte_readed)
);

endmodule

