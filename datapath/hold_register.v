/*
 * A register that update on system clock
*/
`ifndef _hold_register
`define _hold_register

        module hold_register (
                input system_clock,
                input reset,
                input hold,
                input wire [N-1:0] input_signal,
                output reg [N-1:0] output_signal
            );

            parameter N = 32;

            always @(posedge system_clock)
            begin
                if (reset)
                    output_signal <= {N{1'b0}};
                else if (hold)
                    output_signal <= output_signal;
                else
                    output_signal <= input_signal;
            end
        endmodule

`endif
