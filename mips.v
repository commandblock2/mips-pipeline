`ifndef _mips
`define _mips

`include "control/control.v"
`include "datapath/instruction_fetch_unit.v"
`include "datapath/arithmetic_logic_unit_control.v"
`include "datapath/arithmetic_logic_unit.v"
`include "datapath/general_purpose_register.v"
`include "datapath/mux2.v"
`include "datapath/extension.v"
`include "datapath/data_memory.v"

        module mips (
                input wire system_clock,
                input wire reset,
                input wire write_enable
            );


            // IF Stage
            wire [31:0] instruction;
            wire instruction_valid;

            instruction_fetch_unit IFU(
                                       .system_clock(system_clock),
                                       .reset(reset),
                                       .instruction(instruction)
                                   );

            // ID Stage
            wire [5:0] opcode;
            assign opcode = instruction[31:26];

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
            wire [31:0] read_data_1, read_data_2;

            general_purpose_register GPR(
                                         .system_clock(system_clock),
                                         .write_enable(write_enable),


                                         .read_address_1(instruction[25:21]),
                                         .read_address_2(instruction[20:16]),
                                         .read_data_1(read_data_1),
                                         .read_data_2(read_data_2),

                                         .write_address(gpr_write_address),
                                         .write_data(gpr_write_data)
                                     );

            // Select write_address based on register_destination
            mux2 #(5) write_address_mux(
                     .lhs(instruction[20:16]),
                     .rhs(instruction[15:11]),
                     .is_lhs(~register_destination),
                     .data_out(gpr_write_address)
                 );

            // EX Stage
            wire [5:0] function_code = instruction[5:0];
            wire [3:0] alu_control_signal;
            wire [31:0] operand_a, operand_b, alu_result;
            wire zero_output;

            arithmetic_logic_unit_control ALUC(
                                              .function_code(function_code),
                                              .alu_operation(alu_opcode),
                                              .alu_control_signal(alu_control_signal)
                                          );

            assign operand_a = read_data_1;


            wire [31:0] extended_immediate;
            extension sign_extension(
                          .immediate(instruction[15:0]),
                          .extension_type(2'b01),
                          .extended_value(extended_immediate)
                      );

            // Select operand_b based on alu_source
            mux2 #(32) operand_b_mux(
                     .lhs(read_data_2),
                     .rhs(extended_immediate),
                     .is_lhs(~alu_source),
                     .data_out(operand_b)
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
            // Omitted as there's no detail for the data memory in your code.
            wire [31:0] data_read;

            data_memory memory(
                            .system_clock(system_clock),
                            .write_enable(memory_write),
                            .address(alu_result),
                            .write_data(read_data_2),
                            .read_data(data_read)
                        );


            // WB Stage
            reg [31:0] write_data;
            wire [4:0] write_address;

            // Select write_data based on memory_to_register
            mux2 #(32) write_data_mux(
                     .lhs(alu_result),
                     .rhs(data_read),
                     .is_lhs(~memory_to_register),
                     .data_out(gpr_write_data)
                 );

            initial
            begin
                $dumpvars(0, mips);
            end

        endmodule
`endif
