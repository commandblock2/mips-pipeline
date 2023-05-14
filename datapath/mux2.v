`ifndef _mux2
`define _mux2
        module mux2 # (
                parameter WIDTH = 32
            )(input [WIDTH-1:0] lhs, rhs,
              input is_lhs,
              output [WIDTH-1:0] data_out
             );
            assign data_out = is_lhs ? lhs : rhs;
        endmodule
`endif
