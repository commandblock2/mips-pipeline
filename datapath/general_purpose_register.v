/*
 * General purpose registers with 2 output port (read) and 1 input port
*/
`ifndef _general_purpose_register
`define _general_purpose_register
        module general_purpose_register #(
                parameter REGISTER_SIZE = 32,
                // Default value for REGISTER_SIZE is 31 (actually 32 but you know anyway, just a verilog hassle)
                parameter ADDRESS_SIZE = $clog2(REGISTER_SIZE)      // Default address size for 31 registers, will be overridden if REGISTER_SIZE is different
            )(
                input system_clock,
                input write_enable,

                input [ADDRESS_SIZE-1:0] write_address,
                input [REGISTER_SIZE - 1:0] write_data,

                input [ADDRESS_SIZE-1:0] read_address_1, read_address_2,
                output [REGISTER_SIZE - 1:0] read_data_1, read_data_2
            );

            reg [31:0] registers[0:REGISTER_SIZE - 1];

            // Three-ported register file
            // Read two ports combinationally
            // Write on rising edge of clock

            always @(posedge system_clock)
            begin
                if (write_enable)
                begin
                    registers[write_address] <= write_data;
                end
            end

            assign read_data_1 = (read_address_1 != 0) ? registers[read_address_1] : 0;
            assign read_data_2 = (read_address_2 != 0) ? registers[read_address_2] : 0;


            integer i;

            initial
            begin
                for (i = 0; i < REGISTER_SIZE; i = i + 1)
                begin
                    registers[i] = 32'b0;
                end
            end

            generate
                genvar idx;
                for(idx = 0; idx < REGISTER_SIZE; idx = idx+1)
                begin: register
                    wire [31:0] registers_;
                    assign registers_ = registers[idx];
                end
            endgenerate

        endmodule

`endif
