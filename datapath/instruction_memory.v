`ifndef _instruction_memory
`define _instruction_memory
        module instruction_memory #(
                parameter SIZE_EXP2 = 10
            )(
                input system_clock,
                input [SIZE_EXP2 - 1:0] address,
                output [31:0] data_out
            );
            reg [31:0] memory [0:2 ** SIZE_EXP2 - 1];

            assign data_out = memory[address];


            integer i;
            initial
            begin

                for (i = 0; i < 2 ** SIZE_EXP2; i = i + 1)
                begin
                    memory[i] = 32'b0;
                end

                $readmemh ("testdata/test.txt", memory);

                #1000
                 $finish;
            end
        endmodule
`endif
