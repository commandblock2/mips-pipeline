`ifndef _general_purpose_register
`define _general_purpose_register
module general_purpose_register (
        input system_clock,
        input write_enable,
        input [4:0] read_address_1, read_address_2, write_address,
        input [31:0] write_data,
        output [31:0] read_data_1, read_data_2
    );

    reg [31:0] register_file[31:0];

    // Three-ported register file
    // Read two ports combinationally
    // Write on rising edge of clock

    always @(posedge system_clock)
    begin
        if (write_enable)
        begin
            register_file[write_address] <= write_data;
        end
    end

    assign read_data_1 = (read_address_1 != 0) ? register_file[read_address_1] : 0;
    assign read_data_2 = (read_address_2 != 0) ? register_file[read_address_2] : 0;

endmodule

`endif