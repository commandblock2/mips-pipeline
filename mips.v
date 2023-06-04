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

            wire [31:0] instruction;

            // IF Stage
            wire branch_eq, branch_ne;
            wire [31:0] extended_immediate;
            wire zero_output;
            wire jump;
            wire [31:0] program_counter;

            reg stall_stage_ifid;

            instruction_fetch_unit IFU(
                                       .system_clock(system_clock),
                                       .reset(reset),
                                       .stall_stage_ifid(stall_stage_ifid),
                                       .branch(should_branch),
                                       .branch_address(branch_address_stage_memory),
                                       .jump(jump_stage_memory),
                                       .jump_address(jump_address_stage_memory),
                                       .program_counter(program_counter),
                                       .instruction(instruction)
                                   );


            reg should_branch;
            reg flush;
            always @(posedge system_clock)
            begin
                flush <= 1'b0;
                if (should_branch | jump_stage_memory)
                    flush <= 1'b1;
            end



            // IF -> ID
            wire [31:0] program_counter_plus4;
            assign program_counter_plus4 = program_counter + 4;

            wire [31:0] program_counter_plus4_stage_decode, instruction_stage_decode;
            hold_register #(.N(64)) if_id_latch(
                              .system_clock(system_clock),
                              .hold(stall_stage_ifid),
                              .reset(flush),
                              .input_signal({program_counter_plus4, instruction}),
                              .output_signal({program_counter_plus4_stage_decode, instruction_stage_decode})
                          );

            // ID Stage

            wire [5:0] opcode = instruction_stage_decode[31:26];
            wire [5:0] function_code = instruction_stage_decode[5:0];
            wire [4:0] source_register = instruction_stage_decode[25:21];
            wire [4:0] temporary_register = instruction_stage_decode[20:16];
            wire [4:0] destination_register = instruction_stage_decode[15:11];
            wire [15:0] immediate = instruction_stage_decode[15:0];

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


            wire [31:0] gpr_data_out_1, gpr_data_out_2;
            wire [31:0] gpr_write_data_from_stage_writeback = gpr_write_data;
            general_purpose_register GPR(
                                         .system_clock(system_clock),
                                         .write_enable(register_write_stage_writeback),


                                         .write_address(gpr_write_address_stage_writeback),
                                         .write_data(gpr_write_data_from_stage_writeback),


                                         .read_address_1(source_register),
                                         .read_data_1(gpr_data_out_1),


                                         .read_address_2(temporary_register),
                                         .read_data_2(gpr_data_out_2)
                                     );

            // Select write_address based on register_destination
            wire [4:0] gpr_write_address = register_destination ? destination_register : temporary_register;

            wire [31:0] branch_address = program_counter_plus4_stage_decode + (extended_immediate << 2);
            wire [31:0] jump_address = {program_counter_plus4_stage_decode[31:28], instruction_stage_decode[25:0], {2{1'b0}}};


            // ID -> Ex
            wire register_write_stage_execution,
                 memory_to_register_stage_execution,
                 memory_write_stage_execution,
                 alu_source_stage_execution,
                 register_destination_stage_execution,
                 jump_stage_execution,
                 branch_eq_stage_execution,
                 memory_read_stage_execution;

            wire [1:0] alu_opcode_stage_execution;

            wire [4:0] source_register_stage_execution,
                 temporary_register_stage_execution,
                 destination_register_stage_execution;
            wire [4:0] gpr_write_address_stage_execution;

            wire [5:0] function_code_stage_execution;

            wire [31:0] gpr_data_out_1_stage_execution,
                 gpr_data_out_2_stage_execution,
                 jump_address_stage_execution,
                 branch_address_stage_execution,
                 extended_immediate_stage_execution;



            hold_register #(.N(67)) jump_branch_latch(
                              .system_clock(system_clock),
                              .reset(flush),
                              .hold(1'b0),
                              .input_signal({
                                                jump,
                                                jump_address,
                                                branch_eq && data_out_1 == data_out_2,
                                                branch_address,
                                                memory_read
                                            }),
                              .output_signal({
                                                 jump_stage_execution,
                                                 jump_address_stage_execution,
                                                 branch_eq_stage_execution,
                                                 branch_address_stage_execution,
                                                 memory_read_stage_execution
                                             })
                          );

            hold_register #(.N(5)) rs_latch(
                              .system_clock(system_clock),
                              .reset(1'b0),
                              .hold(stall_stage_ifid),
                              .input_signal(source_register),
                              .output_signal(source_register_stage_execution)
                          );

            hold_register #(.N(124)) id_ex_latch(
                              .system_clock(system_clock),
                              .reset(flush),
                              .hold(stall_stage_ifid),
                              .input_signal({
                                                register_write,
                                                memory_to_register,
                                                memory_write,
                                                alu_source,
                                                register_destination,
                                                alu_opcode,
                                                function_code,
                                                gpr_data_out_1,
                                                gpr_data_out_2,
                                                temporary_register,
                                                destination_register,
                                                gpr_write_address,
                                                extended_immediate
                                            }),
                              .output_signal({
                                                 register_write_stage_execution,
                                                 memory_to_register_stage_execution,
                                                 memory_write_stage_execution,
                                                 alu_source_stage_execution,
                                                 register_destination_stage_execution,
                                                 alu_opcode_stage_execution,
                                                 function_code_stage_execution,
                                                 gpr_data_out_1_stage_execution,
                                                 gpr_data_out_2_stage_execution,
                                                 temporary_register_stage_execution,
                                                 destination_register_stage_execution,
                                                 gpr_write_address_stage_execution,
                                                 extended_immediate_stage_execution
                                             })
                          );



            // EX Stage

            wire [3:0] alu_control_signal;
            wire [31:0] alu_result;

            arithmetic_logic_unit_control ALUC(
                                              .function_code(function_code_stage_execution),
                                              .alu_operation(alu_opcode_stage_execution),
                                              .alu_control_signal(alu_control_signal)
                                          );


            reg [31:0] forward_data1_stage_execution;
            always @(*)
            case (forward_a_stage_execution)
                2'd1:
                    forward_data1_stage_execution = alu_result_stage_memory;
                2'd2:
                    forward_data1_stage_execution = gpr_write_data;
                default:
                    forward_data1_stage_execution = gpr_data_out_1_stage_execution;
            endcase

            reg [31:0] forward_data2_stage_execution;
            always @(*)
            case (forward_b_stage_execution)
                2'd1:
                    forward_data2_stage_execution = alu_result_stage_memory;
                2'd2:
                    forward_data2_stage_execution = gpr_write_data;
                default:
                    forward_data2_stage_execution = gpr_data_out_2_stage_execution;
            endcase

            // Select operand_b based on alu_source
            arithmetic_logic_unit ALU(
                                      .control_input(alu_control_signal),
                                      .operand_a(forward_data1_stage_execution),
                                      .operand_b(alu_source_stage_execution ?
                                                 extended_immediate_stage_execution :
                                                 forward_data2_stage_execution),
                                      .result_output(alu_result),
                                      .zero_output(zero_output)
                                  );

            // Ex -> Mem
            wire register_write_stage_memory,
                 memory_to_register_stage_memory,
                 memory_write_stage_memory,
                 jump_stage_memory,
                 branch_eq_stage_memory,
                 zero_output_stage_memory;

            wire [31:0] alu_result_stage_memory,
                 gpr_data_out_2_stage_memory,
                 jump_address_stage_memory,
                 branch_address_stage_memory;

            wire [4:0] gpr_write_address_stage_memory;

            hold_register #(.N(1)) zero_latch(
                              .system_clock(system_clock),
                              .hold(1'b0),
                              .reset(1'b0),
                              .input_signal(zero_output),
                              .output_signal(zero_output_stage_memory)
                          );

            hold_register #(.N(135)) ex_mem_latch(
                              .system_clock(system_clock),
                              .hold(1'b0),
                              .reset(flush),
                              .input_signal({
                                                alu_result,
                                                forward_data2_stage_execution,
                                                gpr_write_address_stage_execution,
                                                jump_stage_execution,
                                                jump_address_stage_execution,
                                                branch_eq_stage_execution,
                                                branch_address_stage_execution
                                            }),
                              .output_signal({
                                                 alu_result_stage_memory,
                                                 gpr_data_out_2_stage_memory,
                                                 gpr_write_address_stage_memory,
                                                 jump_stage_memory,
                                                 jump_address_stage_memory,
                                                 branch_eq_stage_memory,
                                                 branch_address_stage_memory
                                             })
                          );


            hold_register #(.N(3)) decoded_ex_mem_latch(
                              .system_clock(system_clock),
                              .hold(1'b0),
                              .reset(flush),
                              .input_signal({
                                                register_write_stage_execution,
                                                memory_to_register_stage_execution,
                                                memory_write_stage_execution
                                            }),
                              .output_signal({
                                                 register_write_stage_memory,
                                                 memory_to_register_stage_memory,
                                                 memory_write_stage_memory
                                             })
                          );

            // MEM Stage
            wire [31:0] data_memory_out;

            data_memory memory(
                            .system_clock(system_clock),
                            .write_enable(memory_write_stage_memory),
                            .address(alu_result_stage_memory),
                            .write_data(gpr_data_out_2_stage_memory),
                            .read_data(data_memory_out)
                        );

            // Mem -> WB

            wire register_write_stage_writeback,
                 memory_to_register_stage_writeback;

            wire [31:0] data_memory_out_stage_writeback, alu_result_stage_writeback;
            wire [4:0] gpr_write_address_stage_writeback;

            hold_register #(.N(71)) mem_wb_latch(
                              .system_clock(system_clock),
                              .hold(1'b0),
                              .reset(1'b0),
                              .input_signal({
                                                register_write_stage_memory,
                                                memory_to_register_stage_memory,
                                                data_memory_out,
                                                alu_result_stage_memory,
                                                gpr_write_address_stage_memory
                                            }),
                              .output_signal({
                                                 register_write_stage_writeback,
                                                 memory_to_register_stage_writeback,
                                                 data_memory_out_stage_writeback,
                                                 alu_result_stage_writeback,
                                                 gpr_write_address_stage_writeback
                                             })
                          );


            // WB Stage
            wire [4:0] write_address;
            wire [31:0] gpr_write_data = memory_to_register_stage_writeback ? data_memory_out_stage_writeback : alu_result_stage_writeback;

            always @(*)
            begin
                case (1'b1)
                    branch_eq_stage_memory:
                        should_branch <= zero_output_stage_memory;
                    default:
                        should_branch <= 1'b0;
                endcase
            end



            reg forward_a_stage_decode;
            reg forward_b_stage_decode;

            always @(*)
            begin
                if (source_register &&
                        source_register == gpr_write_address_stage_memory &&
                        register_write_stage_memory)
                    forward_a_stage_decode <= 1'b1;
                else
                    forward_a_stage_decode <= 1'b0;

                if(temporary_register &&
                        temporary_register == gpr_write_address_stage_memory &&
                        register_write_stage_memory)
                    forward_b_stage_decode <= 1'b1;
                else
                    forward_b_stage_decode <= 1'b0;
            end

            reg [1:0] forward_a_stage_execution;
            reg [1:0] forward_b_stage_execution;
            always @(*)
            begin

                if ((register_write_stage_memory == 1'b1) && (gpr_write_address_stage_memory == source_register_stage_execution))
                    forward_a_stage_execution <= 2'd1;
                else if ((register_write_stage_writeback == 1'b1) && (gpr_write_address_stage_writeback == source_register_stage_execution))
                    forward_a_stage_execution <= 2'd2;
                else
                    forward_a_stage_execution <= 2'd0;

                if ((register_write_stage_memory == 1'b1) & (gpr_write_address_stage_memory == temporary_register_stage_execution))
                    forward_b_stage_execution <= 2'd1;
                else if ((register_write_stage_writeback == 1'b1) && (gpr_write_address_stage_writeback == temporary_register_stage_execution))
                    forward_b_stage_execution <= 2'd2;
                else
                    forward_b_stage_execution <= 2'd0;
            end


            always @(*)
            begin
                if (memory_read_stage_execution == 1'b1 &&
                        ((temporary_register == temporary_register_stage_execution) || (source_register == source_register_stage_execution)) )
                    stall_stage_ifid <= 1'b1;
                else
                    stall_stage_ifid <= 1'b0;
            end

            initial
            begin
                $dumpvars(0, mips);
            end

        endmodule
`endif
