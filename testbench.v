`include "mips.v"

module testbench;
    reg clock = 0, reset = 1;

    mips dut
         (
             .system_clock(clock),
             .reset(reset),
             .write_enable(1'b1)
         );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clock=~clock;
endmodule
