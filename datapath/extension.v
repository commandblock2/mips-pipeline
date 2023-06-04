`ifndef _extension
`define _extension


        module extension (
                input wire [15:0] immediate,
                input wire [1:0] extension_type,
                output [31:0] extended_value
            );



            wire lui, signed_extension;
            assign {lui, signed_extension} = {extension_type};

            assign extended_value = lui ?
                   {immediate[15:0], 16'b0} :
                   (signed_extension ?
                    {{16{immediate[15]}}, immediate[15:0]}
                    : {16'b0,immediate[15:0]}
                   );


        endmodule
`endif
