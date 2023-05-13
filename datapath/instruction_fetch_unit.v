/*
 * Instruction fetch unit
*/
`ifndef _instruction_fetch_unit
`define _instruction_fetch_unit

        module instruction_fetch_unit(
                input system_clock,
                input reset,
                input [31:0] program_counter,
                output reg [31:0] instruction,
                output reg valid
            );

            // Memory to store instructions
            reg [31:0] memory [0:1023];

            // Internal signals
            reg [31:0] next_program_counter;
            reg [9:0] memory_index;

            // Reset logic
            always @ (posedge system_clock, negedge reset)
            begin
                if (!reset)
                begin
                    instruction <= 0;
                    next_program_counter <= 0;
                    memory_index <= 0;
                    valid <= 0;
                end
            end


            always @ (posedge system_clock)
            begin
                memory_index <= program_counter[9:2];
                instruction <= memory[memory_index];

                // Set next program counter
                next_program_counter <= program_counter + 4;

                // Set valid flag
                valid <= 1;
            end

        endmodule

`endif
