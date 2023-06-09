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
                input branch,
                input stall_stage_ifid,
                input [31:0] branch_address,
                input jump,
                input [31:0] jump_address,
                output [31:0] program_counter,
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
                if (stall_stage_ifid)
                    program_counter <= program_counter;
                else if (branch)
                    program_counter <= branch_address;
                else if (jump)
                    program_counter <= jump_address;
                else
                    program_counter <= program_counter + 4;

            end

            assign memory_index = program_counter[11:2];  // Update memory index
            assign instruction = memory_data_out;

            initial
            begin
                program_counter <= 0;
            end
        endmodule
`endif
