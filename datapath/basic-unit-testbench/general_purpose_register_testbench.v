`ifndef _general_purpose_register_testbench
`define _general_purpose_register_testbench

`include "datapath/general_purpose_register.v"

        module general_purpose_register_testbench;

            reg system_clock;
            reg write_enable;
            reg [4:0] read_address_1, read_address_2, write_address;
            reg [31:0] write_data;
            wire [31:0] read_data_1, read_data_2;

            // Instantiate the DUT (Design Under Test)
            general_purpose_register dut (
                                         .system_clock(system_clock),
                                         .write_enable(write_enable),
                                         .read_address_1(read_address_1),
                                         .read_address_2(read_address_2),
                                         .write_address(write_address),
                                         .write_data(write_data),
                                         .read_data_1(read_data_1),
                                         .read_data_2(read_data_2)
                                     );

            // Clock generation
            always #5 system_clock = ~system_clock;

            // Test case
            initial
            begin
                system_clock = 0;
                write_enable = 1;
                write_address = 3;
                write_data = 32'hA5A5A5A5;

                #10;

                write_enable = 0;
                read_address_1 = 3;
                read_address_2 = 2;

                #10;

                $display("Read Data 1: %h", read_data_1);
                $display("Read Data 2: %h", read_data_2);

                #10;
                $finish;
            end

        endmodule

`endif
