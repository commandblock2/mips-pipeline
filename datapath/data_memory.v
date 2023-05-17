`ifndef _data_memory
`define _data_memory

module data_memory (
    input system_clock,
    input write_enable,
    input [31:0] address,
    input [31:0] write_data,
    output [31:0] read_data
);

    reg [31:0] memory[1023:0];

    // Read operation
    assign read_data = memory[address[31:2]];

    // Write operation
    always @(posedge system_clock) begin
        if (write_enable) begin
            memory[address[31:2]] <= write_data;
        end
    end

endmodule

`endif