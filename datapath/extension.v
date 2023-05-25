`ifndef _extension
`define _extension


        module extension (
                input wire [15:0] immediate,
                input wire extension_type,
                output [31:0] extended_value
            );


            parameter ZERO_EXTENSION = 0;
            parameter SIGN_EXTENSION = 1;


            assign extended_value = (extension_type == ZERO_EXTENSION) ?
                   {immediate[15:0], 16'b0} :
                   {{16{immediate[15]}}, immediate[15:0]}; // Zero extension


        endmodule
`endif
