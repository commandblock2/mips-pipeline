/*
 * Imagin having a ALU control
*/
`ifndef _arithmetic_log_unit_control
`define _arithmetic_log_unit_control

        module arithmetic_log_unit_control(
                input wire [5:0] function_code,
                input wire [1:0] alu_operation,
                output reg [3:0] alu_control_signal);

            reg [3:0] alu_opcode;

            localparam ALU_ADD = 4'b0010;
            localparam ALU_AND = 4'b0000;
            localparam ALU_NOR = 4'b1100;
            localparam ALU_OR = 4'b0001;
            localparam ALU_SLT = 4'b0111;
            localparam ALU_SUB = 4'b0110;
            localparam ALU_XOR = 4'b1101;

            localparam FUNCTION_ADD = 4'b0000;
            localparam FUNCTION_SUB = 4'b0010;
            localparam FUNCTION_OR = 4'b0101;
            localparam FUNCTION_XOR = 4'b0110;
            localparam FUNCTION_NOR = 4'b0111;
            localparam FUNCTION_SLT = 4'b1010;

            always @(*)
            begin
                case(function_code[3:0])
                    FUNCTION_ADD:
                        alu_opcode = ALU_ADD;  
                    FUNCTION_SUB:
                        alu_opcode = ALU_SUB;  
                    FUNCTION_OR:
                        alu_opcode = ALU_OR;   
                    FUNCTION_XOR:
                        alu_opcode = ALU_XOR;  
                    FUNCTION_NOR:
                        alu_opcode = ALU_NOR;  
                    FUNCTION_SLT:
                        alu_opcode = ALU_SLT;  
                    default:
                        alu_opcode = ALU_ADD;
                endcase
            end

            always @(*)
            begin
                case(alu_operation)
                    2'b00:
                        alu_control_signal = ALU_ADD;  /* add */
                    2'b01:
                        alu_control_signal = ALU_SUB;  /* sub */
                    2'b10:
                        alu_control_signal = alu_opcode;
                    2'b11:
                        alu_control_signal = ALU_ADD;  /* add */
                    default:
                        alu_control_signal = ALU_ADD;
                endcase
            end

        endmodule

`endif
