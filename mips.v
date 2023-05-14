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
    wire [31:0] fetched_instruction;
    wire instruction_valid;
    
    // ID Stage
    wire [5:0] opcode;
    wire branch_eq, branch_ne;
    wire [1:0] alu_opcode;
    wire memory_read, memory_write, memory_to_register;
    wire register_destination, register_write, alu_source;
    wire jump;
    
    // EX Stage
    wire [3:0] alu_control_signal;
    wire [31:0] operand_a, operand_b, alu_result;
    wire zero_output;
    
    // MEM Stage
    // Assuming data memory of size 2^10
    reg [31:0] data_memory [1023:0]; 
    reg [31:0] mem_data_out;
    
    // WB Stage
    reg [31:0] write_data;
    wire [4:0] write_address;
    
    // Instantiate modules
    instruction_fetch_unit IFU(
        .system_clock(system_clock),
        .reset(reset),
        .program_counter(program_counter),
        .instruction(fetched_instruction),
        .valid(instruction_valid)
    );
    
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
    
    arithmetic_log_unit_control ALUC(
        .function_code(function_code),
        .alu_operation(alu_operation),
        .alu_control_signal(alu_control_signal)
    );
    
    arithmetic_logic_unit ALU(
        .control_input(alu_control_signal),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .result_output(alu_result),
        .zero_output(zero_output)
    );

        
    general_purpose_register GPR(
        // Define connections to general purpose register
    );
    
    // Connect your memory module here
    // Please note: A proper memory module should handle both read and write operations.
    // Here is a simple implementation:
    always @(posedge system_clock)
    begin
        // if(memory_write) 
        //     data_memory[mem_address] <= mem_data_in;
        // else if(memory_read) 
        //     mem_data_out = data_memory[mem_address];
    end

    
endmodule
`endif