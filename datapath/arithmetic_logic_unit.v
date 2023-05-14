/*
 * Ordinary ALU
*/
`ifndef _arithmetic_logic_unit
`define _arithmetic_logic_unit

        module arithmetic_logic_unit(
                input [3:0] control_input,
                input [31:0] operand_a, operand_b,
                output reg [31:0] result_output,
                output zero_output
            );

            localparam ADD = 4'b0010;
            localparam AND = 4'b0000;
            localparam NOR = 4'b1100;
            localparam OR = 4'b0001;
            localparam SLT = 4'b0111;
            localparam SUB = 4'b0110;
            localparam XOR = 4'b1101;


            wire [31:0] subtraction_output;
            wire [31:0] addition_output;
            wire overflow_addition;
            wire overflow_subtraction;
            wire overflow_signal;
            wire less_than_signal;

            assign zero_output = (0 == result_output);

            assign subtraction_output = operand_a - operand_b;
            assign addition_output = operand_a + operand_b;

            assign overflow_addition = (operand_a[31] == operand_b[31] && addition_output[31] != operand_a[31]) ? 1 : 0;
            assign overflow_subtraction = (operand_a[31] == operand_b[31] && subtraction_output[31] != operand_a[31]) ? 1 : 0;

            assign overflow_signal = (control_input == 4'b0010) ? overflow_addition : overflow_subtraction;

            assign less_than_signal = overflow_subtraction ? ~(operand_a[31]) : operand_a[31];

            always @(*)
            begin
                case (control_input)
                    ADD:
                        result_output <= addition_output;
                    AND:
                        result_output <= operand_a & operand_b;
                    NOR:
                        result_output <= ~(operand_a | operand_b);
                    OR:
                        result_output <= operand_a | operand_b;
                    SLT:
                        result_output <= {{31{1'b0}}, less_than_signal};
                    SUB:
                        result_output <= subtraction_output;
                    XOR:
                        result_output <= operand_a ^ operand_b;
                    default:
                        result_output <= 0;
                endcase
            end

        endmodule

`endif
