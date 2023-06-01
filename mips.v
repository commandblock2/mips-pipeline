`ifndef _mips
`define _mips

`include "control/control.v"
`include "datapath/hold_register.v"
`include "datapath/instruction_fetch_unit.v"
`include "datapath/arithmetic_logic_unit_control.v"
`include "datapath/arithmetic_logic_unit.v"
`include "datapath/general_purpose_register.v"
`include "datapath/extension.v"
`include "datapath/data_memory.v"

        module mips (
                input wire system_clock,
                input wire reset,
                input wire write_enable
            );

            // aliases
            wire [31:0] instruction;
            wire [5:0] opcode = instruction[31:26];
            wire [5:0] function_code = instruction[5:0];
            wire [25:21] source_register = instruction[25:21];
            wire [20:16] temporary_register = instruction[20:16];
            wire [15:11] destination_register = instruction[15:11];
            wire [15:0] immediate = instruction[15:0];

            // IF Stage
            wire branch_eq, branch_ne;
            wire [31:0] extended_immediate;
            wire zero_output;
            wire jump;
            wire [31:0] program_counter;

            wire register_write_state5;
            wire [4:0] gpr_write_address_state5;
            wire [31:0]	gpr_write_data_state5;
            reg stall_state12;

            instruction_fetch_unit IFU(
                                       .system_clock(system_clock),
                                       .reset(reset),
                                       .branch_eq(branch_eq),
                                       .zero(zero_output),
                                       .extended_immediate(extended_immediate),
                                       .jump(jump),
                                       .program_counter(program_counter),
                                       .instruction(instruction)
                                   );



            wire jump_state_memory;
            reg should_branch;
            reg flush_state_fetch, flush_state_decode, flush_state_execution;
            always @(posedge system_clock) begin
                flush_state_fetch <= 1'b0;
                flush_state_decode <= 1'b0;
                flush_state_execution <= 1'b0;
                if (should_branch | jump_state_memory) begin
                    flush_state_fetch <= 1'b1;
                    flush_state_decode <= 1'b1;
                    flush_state_execution <= 1'b1;
                end
            end



            // IF -> ID
            wire [31:0] program_counter_plus4;
            assign program_counter_plus4 = program_counter + 4;

            wire [31:0] program_counter_plus4_state_decode, instruction_state_decode;
            hold_register #(.N(64)) pc4s2(
                .system_clock(system_clock),
                .hold(stall_state12),
                .reset(flush_state_fetch),
                .input_signal({program_counter_plus4, instruction}),
                .output_signal({program_counter_plus4_state_decode, instruction_state_decode})
            );

            // ID Stage
            wire [1:0] alu_opcode;
            wire memory_read, memory_write, memory_to_register;
            wire register_destination, register_write, alu_source;
            wire shift_upper;

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
                        .shift_upper(shift_upper),
                        .jump(jump)
                    );



            extension sign_extension(
                          .immediate(immediate),
                          .extension_type(~shift_upper),
                          .extended_value(extended_immediate)
                      );

            wire [4:0] gpr_write_address;
            wire [31:0] gpr_write_data;
            wire [31:0] gpr_data_out_1, gpr_data_out_2;

            general_purpose_register GPR(
                                         .system_clock(system_clock),
                                         .write_enable(register_write),


                                         .read_address_1(source_register),
                                         .read_address_2(temporary_register),
                                         .read_data_1(gpr_data_out_1),
                                         .read_data_2(gpr_data_out_2),

                                         .write_address(gpr_write_address),
                                         .write_data(gpr_write_data)
                                     );

            // Select write_address based on register_destination
            assign gpr_write_address = register_destination ? destination_register : temporary_register;

            // EX Stage

            wire [3:0] alu_control_signal;
            wire [31:0] alu_result;

            arithmetic_logic_unit_control ALUC(
                                              .function_code(function_code),
                                              .alu_operation(alu_opcode),
                                              .alu_control_signal(alu_control_signal)
                                          );


            // Select operand_b based on alu_source
            arithmetic_logic_unit ALU(
                                      .control_input(alu_control_signal),
                                      .operand_a(gpr_data_out_1),
                                      .operand_b(alu_source ? extended_immediate: gpr_data_out_2),
                                      .result_output(alu_result),
                                      .zero_output(zero_output)
                                  );

            // MEM Stage
            // Assuming data memory of size 2^10
            // Omitted as there's no detail for the data memory in your code.
            wire [31:0] data_memory_out;

            data_memory memory(
                            .system_clock(system_clock),
                            .write_enable(memory_write),
                            .address(alu_result),
                            .write_data(gpr_data_out_2),
                            .read_data(data_memory_out)
                        );


            // WB Stage
            reg [31:0] write_data;
            wire [4:0] write_address;
            assign gpr_write_data = memory_to_register ? data_memory_out : alu_result;

            initial
            begin
                $dumpvars(0, mips);
            end

        endmodule
`endif
