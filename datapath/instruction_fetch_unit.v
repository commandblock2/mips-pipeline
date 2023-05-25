/*
 * Instruction fetch unit
 * TODO: more to be finished
*/
`ifndef _instruction_fetch_unit
`define _instruction_fetch_unit

`include "datapath/instruction_memory.v"

        module instruction_fetch_unit (
                input system_clock,
                input reset,
                input branch_eq,
                input zero,
                input [31:0] extended_immediate,
                input jump,
                output [31:0] instruction
            );
            wire [9:0] memory_index;
            wire [31:0] memory_data_out;

            instruction_memory memory(
                                   .system_clock(system_clock),
                                   .address(memory_index),
                                   .data_out(memory_data_out)
                               );

            reg [31:0] program_counter;  // PC register

            always @(negedge reset)
            begin
                program_counter <= 0;
            end

            always @ (posedge system_clock)
            begin
                if (branch_eq && zero)
                    program_counter <= program_counter + 4 + (extended_immediate << 2);  // Branch taken
                else if (jump)
                    program_counter <= {program_counter[31:28], instruction[25:0], 2'b00};
                else
                    program_counter <= program_counter + 4;  // Update PC

            end

            assign memory_index = program_counter[11:2];  // Update memory index
            assign instruction = memory_data_out;

            initial
            begin
                program_counter <= 0;
            end
        endmodule
`endif
