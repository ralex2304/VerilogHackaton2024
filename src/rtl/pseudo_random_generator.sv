module pseudo_random_generator (
    input logic        clk,
    input logic        arst_n,
    output logic [7:0] o_prng
);
    logic [7:0] prng_buffer;

    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            prng_buffer <= 8'hDA; // Must not be 0 i thing probably idk
        end else begin
            prng_buffer <= {prng_buffer[6:0], prng_buffer[7] ^
                                              prng_buffer[5] ^
                                              prng_buffer[4] ^
                                              prng_buffer[3]};
        end
    end

    assign o_prng = prng_buffer;
endmodule
