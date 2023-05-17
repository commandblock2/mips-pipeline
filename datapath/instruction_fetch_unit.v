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
                output [31:0] instruction
            );
            reg [9:0] memory_index;
            wire [31:0] memory_data_out;

            instruction_memory memory(
                                   .system_clock(system_clock),
                                   .address(memory_index),
                                   .data_out(memory_data_out)
                               );

            reg [31:0] program_counter;  // PC register

            assign program_counter_next = program_counter + 4;  // PC increment

            always @ (posedge system_clock or negedge reset)
            begin
                if (!reset)
                begin
                    memory_index <= 0;
                    program_counter <= 0;  // Reset PC
                end
                else  // On clock edge
                begin
                    memory_index <= program_counter[11:2];  // Update memory index
                    program_counter <= program_counter_next;  // Update PC
                end
            end

            assign instruction = memory_data_out;
        endmodule

`endif
