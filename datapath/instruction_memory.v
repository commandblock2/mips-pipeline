`ifndef _instruction_memory
`define _instruction_memory
        module instruction_memory #(
            parameter SIZE_EXP2 = 10
        )(
                input system_clock,
                input [SIZE_EXP2 - 1:0] address,
                output reg [31:0] data_out
            );
            reg [31:0] memory [0:2 ^ SIZE_EXP2 - 1];

            always @ (posedge system_clock)
                data_out <= memory[address];
        endmodule
`endif
