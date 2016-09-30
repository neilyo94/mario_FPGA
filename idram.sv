module id_ram (
    input logic clk,    // Clock
    input logic we, // Write Enable
    input logic [23:0] data_in,  // Input data
    output logic [23:0] data_out,
    input logic [4:0] address
);
    logic [23:0] mem[0:31];
    always_ff @(posedge clk) begin
            if (we) begin
            mem[address] <= data_in;
            end
            data_out <= mem[address];

    end
endmodule
