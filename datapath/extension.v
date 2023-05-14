`ifndef _extension
`define _extension
module extension (
  input wire [31:0] immediate,
  input wire [1:0] extension_type,
  output reg [31:0] extended_value
);

  localparam ZERO_EXTENSION = 2'b00;
  localparam SIGN_EXTENSION = 2'b01;

  always @(*) begin
    case (extension_type)
      ZERO_EXTENSION: extended_value = {16'b0, immediate[15:0]}; // Zero extension
      SIGN_EXTENSION: extended_value = {{16{immediate[15]}}, immediate[15:0]}; // Sign extension
      default: extended_value = {16'b0, immediate[15:0]}; // Default to zero extension
    endcase
  end

endmodule
`endif
