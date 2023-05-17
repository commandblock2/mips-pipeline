`ifndef _mips
`define _mips

`include "control/control.v"
`include "datapath/instruction_fetch_unit.v"
`include "datapath/arithmetic_log_unit_control.v"
`include "datapath/arithmetic_logic_unit.v"
`include "datapath/general_purpose_register.v"


module mips (
    input wire system_clock,
    input wire reset,
    input wire write_enable
);

    // Program counter
    reg [31:0] program_counter;
    
    // IF Stage
    wire [31:0] instruction;
    wire instruction_valid;

    instruction_fetch_unit IFU(
        .system_clock(system_clock),
        .reset(reset),
        .program_counter(program_counter),
        .instruction(instruction),
        .valid(instruction_valid)
    );
    
    // ID Stage
    wire [5:0] opcode;
    assign opcode = instruction[5:0];

    wire branch_eq, branch_ne;
    wire [1:0] alu_opcode;
    wire memory_read, memory_write, memory_to_register;
    wire register_destination, register_write, alu_source;
    wire jump;

    control IDU(
        .opcode(opcode),
        .branch_eq(branch_eq),
        .branch_ne(branch_ne),
        .alu_opcode(alu_opcode),
        .memory_read(memory_read),
        .memory_write(memory_write),
        .memory_to_register(memory_to_register),
        .register_destination(register_destination),
        .register_write(register_write),
        .alu_source(alu_source),
        .jump(jump)
    );

    wire [4:0] gpr_write_address;
    wire [31:0] gpr_write_data;

    general_purpose_register GPR(
        .system_clock(system_clock),
        .write_enable(write_enable),


        .read_address_1(instruction[25:21]),
        .read_address_2(instruction[20:16]),
        
        .write_address(gpr_write_address),
        .write_data(gpr_write_data)
    );
    
    // EX Stage
    wire [3:0] alu_control_signal;
    wire [31:0] operand_a, operand_b, alu_result;
    wire zero_output;

    arithmetic_log_unit_control ALUC(
        .function_code(function_code),
        .alu_operation(alu_opcode),
        .alu_control_signal(alu_control_signal)
    );
    
    arithmetic_logic_unit ALU(
        .control_input(alu_control_signal),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .result_output(alu_result),
        .zero_output(zero_output)
    );
    
    // MEM Stage
    // Assuming data memory of size 2^10
    
    // WB Stage
    reg [31:0] write_data;
    wire [4:0] write_address;


    always @(posedge system_clock)
    begin
        program_counter <= program_counter + 4;

    end

    
endmodule
`endif