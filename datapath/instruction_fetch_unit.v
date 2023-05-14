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
                input [31:0] program_counter,
                output reg [31:0] instruction,
                output reg valid
            );
            reg [9:0] memory_index;
            wire [31:0] memory_data_out;

            instruction_memory memory(
                                   .system_clock(system_clock),
                                   .address(memory_index),
                                   .data_out(memory_data_out)
                               );

            always @ (posedge system_clock, negedge reset)
            begin
                if (!reset)
                begin
                    instruction <= 0;
                    memory_index <= 0;
                    valid <= 0;
                end
            end

            always @ (posedge system_clock)
            begin
                memory_index <= program_counter[11:2];
                instruction <= memory_data_out;

                valid <= 1;
            end
        endmodule

`endif
