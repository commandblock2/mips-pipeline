/*
 * This module takes the 6 bit opcode, and gives if some wires should be connected
*/

`ifndef _control
`define _control

        module control(
                input wire [5:0] opcode,
                output reg branch_eq, branch_ne,
                output reg [1:0] alu_opcode,
                output reg memory_read, memory_write, memory_to_register,
                output reg register_destination, register_write, alu_source,
                output reg shift_upper,
                output reg jump
            );

            // Constants
            localparam LW = 6'b100011;
            localparam BEQ = 6'b000100;
            localparam BNE = 6'b000101;
            localparam SW = 6'b101011;
            localparam ADDI = 6'b001000;
            localparam ADD = 6'b000000;
            localparam JUMP = 6'b000010;
            localparam LUI = 6'b001111;
            localparam ORI = 6'b001101;

            always @(*)
            begin
                // Defaults
                alu_opcode[1:0] <= 2'b10;
                alu_source <= 1'b0;
                branch_eq <= 1'b0;
                branch_ne <= 1'b0;
                memory_read <= 1'b0;
                memory_to_register <= 1'b0;
                memory_write <= 1'b0;
                register_destination <= 1'b1;
                register_write <= 1'b1;
                jump <= 1'b0;
                shift_upper <= 1'b0;

                case (opcode)
                    LW:
                    begin
                        memory_read <= 1'b1;
                        register_destination <= 1'b0;
                        memory_to_register <= 1'b1;
                        alu_opcode[1] <= 1'b0;
                        alu_source <= 1'b1;
                    end

                    BEQ:
                    begin
                        alu_opcode[0] <= 1'b1;
                        alu_opcode[1] <= 1'b0;
                        branch_eq <= 1'b1;
                        register_write <= 1'b0;
                    end

                    BNE:
                    begin
                        alu_opcode[0] <= 1'b1;
                        alu_opcode[1] <= 1'b0;
                        branch_ne <= 1'b1;
                        register_write <= 1'b0;
                    end

                    SW:
                    begin
                        memory_write <= 1'b1;
                        alu_opcode[1] <= 1'b0;
                        alu_source <= 1'b1;
                        register_write <= 1'b0;
                    end

                    ADDI:
                    begin
                        register_destination <= 1'b0;
                        alu_opcode[1] <= 1'b0;
                        alu_source <= 1'b1;
                    end

                    ADD:
                    begin
                    end

                    LUI:
                    begin
                        alu_opcode <= 2'b00;
                        alu_source <= 1'b1;
                        shift_upper <= 1'b1;
                        register_write <= 1'b1;
                        register_destination <= 1'b0;
                    end

                    ORI:
                    begin
                        alu_opcode <= 2'b00;  // ALU performs OR operation
                        alu_source <= 1'b1;   // ALU second operand is immediate
                        register_destination <= 1'b0; // Destination register is rt
                        memory_to_register <= 1'b0; // ALU result is written back to register
                    end

                    JUMP:
                    begin
                        jump <= 1'b1;
                    end
                endcase
            end
        endmodule

`endif
