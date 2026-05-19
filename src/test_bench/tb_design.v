`timescale 1ns/1ps

module tb_alu_design;

    parameter N=4;

    reg [N-1:0] OPA, OPB;
    reg CLK, RST, CE, MODE, CIN;
    reg [1:0] INP_VALID;
    reg [3:0] CMD;

    wire [2*N-1:0] RES_dut;
    wire COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut;

    wire [2*N-1:0] RES_ref;
    wire COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref;

    integer pass_count = 0;
    integer fail_count = 0;
    integer test_count = 0;

    alu #(.N(N)) dut (
        .OPA(OPA),
        .OPB(OPB),
        .CIN(CIN),
        .CLK(CLK),
        .RST(RST),
        .CMD(CMD),
        .CE(CE),
        .MODE(MODE),
        .INP_VALID(INP_VALID),
        .COUT(COUT_dut),
        .OFLOW(OFLOW_dut),
        .RES(RES_dut),
        .G(G_dut),
        .E(E_dut),
        .L(L_dut),
        .ERR(ERR_dut)
    );

    alu_ref_model #(.N(N)) ref (
        .OPA(OPA),
        .OPB(OPB),
        .CIN(CIN),
        .MODE(MODE),
        .CMD(CMD),
        .INP_VALID(INP_VALID),
        .CE(CE),
        .RES(RES_ref),
        .COUT(COUT_ref),
        .OFLOW(OFLOW_ref),
        .G(G_ref),
        .E(E_ref),
        .L(L_ref),
        .ERR(ERR_ref)
    );

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    initial begin

        RST = 1;
        CE = 1;
        CIN = 0;
        OPA = 0;
        OPB = 0;
        MODE = 0;
        CMD = 0;

        @(posedge CLK);
        RST = 0;
        @(posedge CLK);

        $display("\n=== Testing Arithmetic Operations (MODE=1) ===");
        MODE = 1;
        test_arithmetic();

        $display("\n=== Testing Logical Operations (MODE=0) ===");
        MODE = 0;
        test_logical();

        $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** SOME TESTS FAILED ***\n");

        #100;
        $finish;
    end

    task test_arithmetic();
        begin

 
            apply_test(4'd9,  4'd4,  4'b0000, 2'b11, "ADD_Normal_case",     2);
            apply_test(4'd0,  4'd0,  4'b0000, 2'b11, "ADD_both_min",        2);
            apply_test(4'd15, 4'd15, 4'b0000, 2'b11, "ADD_both_max_cout",   2);
            apply_test(4'd15, 4'd15, 4'b1111, 2'b11, "ADD_invalid_cmd",     2);
            apply_test(4'd15, 4'd15, 4'b0000, 2'b01, "ADD_invalid_input",   2);
            apply_test(4'd15, 4'd1,  4'b0000, 2'b11, "ADD_max_plus1_cout",  2);


            apply_test(4'd12, 4'd5,  4'b0001, 2'b11, "SUB_Normal_case",     2);
            apply_test(4'd15, 4'd15, 4'b0001, 2'b11, "SUB_max_max",         2);
            apply_test(4'd0,  4'd0,  4'b0001, 2'b11, "SUB_min_min",         2);
            apply_test(4'd7,  4'd15, 4'b0001, 2'b11, "SUB_overflow",        2);
            apply_test(4'd15, 4'd15, 4'b0001, 2'b01, "SUB_invalid_input",   2);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "SUB_invalid_command", 2);


            CIN = 1;
            apply_test(4'd8,  4'd6,  4'b0010, 2'b11, "ADD_CIN_Normal_case",    2);
            apply_test(4'd15, 4'd15, 4'b0010, 2'b11, "ADD_CIN_cout",           2);
            apply_test(4'd0,  4'd0,  4'b0010, 2'b11, "ADD_CIN_min_min",        2);
            apply_test(4'd15, 4'd15, 4'b0010, 2'b01, "ADD_CIN_invalid_input",  2);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "ADD_CIN_invalid_command",2);

            CIN = 0;
            apply_test(4'd9,  4'd4,  4'b0010, 2'b11, "ADD_CIN0_normal",        2);


            CIN = 1;
            apply_test(4'd11, 4'd3,  4'b0011, 2'b11, "SUB_CIN_Normal_case",    2);
            apply_test(4'd15, 4'd15, 4'b0011, 2'b11, "SUB_CIN_equal_values",   2);
            apply_test(4'd0,  4'd0,  4'b0011, 2'b11, "SUB_CIN_zero_case",      2);
            apply_test(4'd5,  4'd12, 4'b0011, 2'b11, "SUB_CIN_overflow_case",  2);
            apply_test(4'd10, 4'd5,  4'b0011, 2'b00, "SUB_CIN_invalid_input",  2);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "SUB_CIN_invalid_command",2);

            CIN = 0;
            apply_test(4'd10, 4'd3,  4'b0011, 2'b11, "SUB_CIN0_normal",        2);

      
            apply_test(4'd13, 4'd0,  4'b0100, 2'b01, "INC_A_Normal_case",    2);
            apply_test(4'd15, 4'd0,  4'b0100, 2'b11, "INC_A_both_valid",     2);
            apply_test(4'd0,  4'd0,  4'b0100, 2'b01, "INC_A_min",            2);
            apply_test(4'd15, 4'd0,  4'b0100, 2'b01, "INC_A_max_cout",   2);
            apply_test(4'd10, 4'd0,  4'b0100, 2'b00, "INC_A_invalid_input",  2);
            apply_test(4'd10, 4'd0,  4'b1111, 2'b01, "INC_A_invalid_command",2);

            apply_test(4'd9,  4'd0,  4'b0101, 2'b01, "DEC_A_Normal_case",    2);
            apply_test(4'd15, 4'd0,  4'b0101, 2'b11, "DEC_A_both_valid",     2);
            apply_test(4'd0,  4'd0,  4'b0101, 2'b01, "DEC_A_zero",      2);
            apply_test(4'd10, 4'd0,  4'b0101, 2'b00, "DEC_A_invalid_input",  2);
            apply_test(4'd10, 4'd0,  4'b1111, 2'b01, "DEC_A_invalid_command",2);


            apply_test(4'd0,  4'd13, 4'b0110, 2'b10, "INC_B_Normal_case",    2);
            apply_test(4'd0,  4'd15, 4'b0110, 2'b11, "INC_B_both_valid",     2);
            apply_test(4'd0,  4'd0,  4'b0110, 2'b10, "INC_B_min",            2);
            apply_test(4'd0,  4'd15, 4'b0110, 2'b10, "INC_B_max_overflow",   2);
            apply_test(4'd0,  4'd10, 4'b0110, 2'b00, "INC_B_invalid_input",  2);
            apply_test(4'd0,  4'd10, 4'b1111, 2'b10, "INC_B_invalid_command",2);

            apply_test(4'd0,  4'd9,  4'b0111, 2'b10, "DEC_B_Normal_case",    2);
            apply_test(4'd0,  4'd15, 4'b0111, 2'b11, "DEC_B_both_valid",     2);
            apply_test(4'd0,  4'd0,  4'b0111, 2'b10, "DEC_B_zero_wrap",      2);
            apply_test(4'd0,  4'd10, 4'b0111, 2'b00, "DEC_B_invalid_input",  2);
            apply_test(4'd0,  4'd10, 4'b1111, 2'b10, "DEC_B_invalid_command",2);


            apply_test(4'd10, 4'd10, 4'b1000, 2'b11, "CMP_equal",          2);
            apply_test(4'd15, 4'd10, 4'b1000, 2'b11, "CMP_greater",        2);
            apply_test(4'd5,  4'd10, 4'b1000, 2'b11, "CMP_less",           2);
            apply_test(4'd0,  4'd15, 4'b1000, 2'b11, "CMP_min_vs_max",     2);
            apply_test(4'd15, 4'd0,  4'b1000, 2'b11, "CMP_max_vs_min",     2);
            apply_test(4'd1,  4'd0,  4'b1000, 2'b11, "CMP_one_vs_zero",    2);
            apply_test(4'd10, 4'd5,  4'b1000, 2'b00, "CMP_invalid_input",  2);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "CMP_invalid_command",2);


            apply_test(4'd2,  4'd3,  4'b1001, 2'b11, "CMD9_Normal_case",    3);
            apply_test(4'd15, 4'd15, 4'b1001, 2'b11, "CMD9_max",            3);
            apply_test(4'd0,  4'd0,  4'b1001, 2'b11, "CMD9_both_min",       3);
            apply_test(4'd1,  4'd0,  4'b1001, 2'b11, "CMD9_opb_zero",       3);
            apply_test(4'd1,  4'd1,  4'b1001, 2'b11, "CMD9_both_one",       3);
            apply_test(4'd10, 4'd5,  4'b1001, 2'b00, "CMD9_invalid_input",  3);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "CMD9_invalid_command",3);


            apply_test(4'd2,  4'd3,  4'b1010, 2'b11, "CMD10_Normal_case",    3);
            apply_test(4'd15, 4'd15, 4'b1010, 2'b11, "CMD10_max",            3);
            apply_test(4'd0,  4'd0,  4'b1010, 2'b11, "CMD10_both_min",       3);
            apply_test(4'd1,  4'd2,  4'b1010, 2'b11, "CMD10_basic",          3);
            apply_test(4'd1,  4'd1,  4'b1010, 2'b11, "CMD10_both_one",       3);
            apply_test(4'd10, 4'd5,  4'b1010, 2'b00, "CMD10_invalid_input",  3);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "CMD10_invalid_command",3);


            apply_test(4'd6,  4'd2,  4'b1011, 2'b11, "CMD11_Normal_case",    2);
            apply_test(4'd5,  4'd5,  4'b1011, 2'b11, "CMD11_equal",          2);
            apply_test(4'd2,  4'd6,  4'b1011, 2'b11, "CMD11_less",           2);
            apply_test(4'd7,  4'd1,  4'b1011, 2'b11, "CMD11_pos_overflow",   2);
            apply_test(4'd8,  4'd15, 4'b1011, 2'b11, "CMD11_neg_overflow",   2);
            apply_test(4'd8,  4'd8,  4'b1011, 2'b11, "CMD11_neg_neg_equal",  2);
            apply_test(4'd8,  4'd7,  4'b1011, 2'b11, "CMD11_neg_pos",     2);
            apply_test(4'd7,  4'd8,  4'b1011, 2'b11, "CMD11_pos_vs_neg",     2);
            apply_test(4'd0,  4'd1,  4'b1011, 2'b11, "CMD11_zero_vs_one",    2);
            apply_test(4'd10, 4'd5,  4'b1011, 2'b00, "CMD11_invalid_input",  2);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "CMD11_invalid_command",2);

          
            apply_test(4'd6,  4'd2,  4'b1100, 2'b11, "CMD12_Normal_case",    2);
            apply_test(4'd5,  4'd5,  4'b1100, 2'b11, "CMD12_equal",          2);
            apply_test(4'd2,  4'd6,  4'b1100, 2'b11, "CMD12_less",           2);
            apply_test(4'd7,  4'd15, 4'b1100, 2'b11, "CMD12_pos_overflow",   2);
            apply_test(4'd8,  4'd1,  4'b1100, 2'b11, "CMD12_neg_overflow",   2);
            apply_test(4'd8,  4'd8,  4'b1100, 2'b11, "CMD12_neg_equal",      2);
            apply_test(4'd7,  4'd8,  4'b1100, 2'b11, "CMD12_pos_minus_neg",  2);
            apply_test(4'd8,  4'd7,  4'b1100, 2'b11, "CMD12_neg_minus_pos",  2);
            apply_test(4'd0,  4'd1,  4'b1100, 2'b11, "CMD12_zero_vs_one",    2);
            apply_test(4'd10, 4'd5,  4'b1100, 2'b00, "CMD12_invalid_input",  2);
            apply_test(4'd10, 4'd5,  4'b1111, 2'b11, "CMD12_invalid_command",2);


            CE = 0;
            apply_test(4'd5,  4'd3,  4'b0000, 2'b11, "ADD_CE_disabled",   2);
            apply_test(4'd5,  4'd3,  4'b0001, 2'b11, "SUB_CE_disabled",   2);
            apply_test(4'd5,  4'd3,  4'b1000, 2'b11, "CMP_CE_disabled",   2);
            apply_test(4'd5,  4'd3,  4'b1011, 2'b11, "CMD11_CE_disabled", 2);
            apply_test(4'd5,  4'd3,  4'b1100, 2'b11, "CMD12_CE_disabled", 2);
            CE = 1;

        end
    endtask

    task test_logical();
        begin

            apply_test(4'b1100, 4'b1010, 4'b0000, 2'b11, "AND_Normal_case",    2);
            apply_test(4'b1111, 4'b1111, 4'b0000, 2'b11, "AND_all_ones",       2);
            apply_test(4'b0000, 4'b0000, 4'b0000, 2'b11, "AND_all_zeros",      2);
            apply_test(4'b1010, 4'b1100, 4'b0000, 2'b01, "AND_only_A_valid",   2);
            apply_test(4'b1010, 4'b1100, 4'b0000, 2'b10, "AND_only_B_valid",   2);
            apply_test(4'b1010, 4'b1100, 4'b0000, 2'b00, "AND_invalid_input",  2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "AND_invalid_command",2);

         
            apply_test(4'b1100, 4'b1010, 4'b0001, 2'b11, "NAND_Normal_case",    2);
            apply_test(4'b1111, 4'b1111, 4'b0001, 2'b11, "NAND_all_ones",       2);
            apply_test(4'b0000, 4'b0000, 4'b0001, 2'b11, "NAND_all_zeros",      2);
            apply_test(4'b1010, 4'b1100, 4'b0001, 2'b01, "NAND_only_A_valid",   2);
            apply_test(4'b1010, 4'b1100, 4'b0001, 2'b10, "NAND_only_B_valid",   2);
            apply_test(4'b1010, 4'b1100, 4'b0001, 2'b00, "NAND_invalid_input",  2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "NAND_invalid_command",2);

      
            apply_test(4'b0110, 4'b1010, 4'b0010, 2'b11, "OR_Normal_case",     2);
            apply_test(4'b1111, 4'b1111, 4'b0010, 2'b11, "OR_all_ones",        2);
            apply_test(4'b0000, 4'b0000, 4'b0010, 2'b11, "OR_all_zeros",       2);
            apply_test(4'b1010, 4'b1100, 4'b0010, 2'b01, "OR_only_A_valid",    2);
            apply_test(4'b1010, 4'b1100, 4'b0010, 2'b10, "OR_only_B_valid",    2);
            apply_test(4'b1010, 4'b1100, 4'b0010, 2'b00, "OR_invalid_input",   2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "OR_invalid_command", 2);


            apply_test(4'b1100, 4'b1010, 4'b0011, 2'b11, "NOR_Normal_case",    2);
            apply_test(4'b1111, 4'b1111, 4'b0011, 2'b11, "NOR_all_ones",       2);
            apply_test(4'b0000, 4'b0000, 4'b0011, 2'b11, "NOR_all_zeros",      2);
            apply_test(4'b1010, 4'b1100, 4'b0011, 2'b01, "NOR_only_A_valid",   2);
            apply_test(4'b1010, 4'b1100, 4'b0011, 2'b10, "NOR_only_B_valid",   2);
            apply_test(4'b1010, 4'b1100, 4'b0011, 2'b00, "NOR_invalid_input",  2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "NOR_invalid_command",2);


            apply_test(4'b1100, 4'b1010, 4'b0100, 2'b11, "XOR_Normal_case",    2);
            apply_test(4'b1111, 4'b1111, 4'b0100, 2'b11, "XOR_all_ones",       2);
            apply_test(4'b0000, 4'b0000, 4'b0100, 2'b11, "XOR_all_zeros",      2);
            apply_test(4'b1010, 4'b1100, 4'b0100, 2'b01, "XOR_only_A_valid",   2);
            apply_test(4'b1010, 4'b1100, 4'b0100, 2'b10, "XOR_only_B_valid",   2);
            apply_test(4'b1010, 4'b1100, 4'b0100, 2'b00, "XOR_invalid_input",  2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "XOR_invalid_command",2);


            apply_test(4'b1100, 4'b1010, 4'b0101, 2'b11, "XNOR_Normal_case",    2);
            apply_test(4'b1111, 4'b1111, 4'b0101, 2'b11, "XNOR_all_ones",       2);
            apply_test(4'b0000, 4'b0000, 4'b0101, 2'b11, "XNOR_all_zeros",      2);
            apply_test(4'b1010, 4'b1100, 4'b0101, 2'b01, "XNOR_only_A_valid",   2);
            apply_test(4'b1010, 4'b1100, 4'b0101, 2'b10, "XNOR_only_B_valid",   2);
            apply_test(4'b1010, 4'b1100, 4'b0101, 2'b00, "XNOR_invalid_input",  2);
            apply_test(4'b1010, 4'b1100, 4'b1111, 2'b11, "XNOR_invalid_command",2);


            apply_test(4'b1100, 4'b0000, 4'b0110, 2'b01, "NOT_A_Normal_case",    2);
            apply_test(4'b1111, 4'b0000, 4'b0110, 2'b01, "NOT_A_all_ones",       2);
            apply_test(4'b0000, 4'b0000, 4'b0110, 2'b01, "NOT_A_all_zeros",      2);
            apply_test(4'b1010, 4'b0000, 4'b0110, 2'b11, "NOT_A_both_valid",     2);
            apply_test(4'b1010, 4'b0000, 4'b0110, 2'b00, "NOT_A_invalid_input",  2);
            apply_test(4'b1010, 4'b0000, 4'b1111, 2'b01, "NOT_A_invalid_command",2);

            apply_test(4'b0000, 4'b1100, 4'b0111, 2'b10, "NOT_B_Normal_case",    2);
            apply_test(4'b0000, 4'b1111, 4'b0111, 2'b10, "NOT_B_all_ones",       2);
            apply_test(4'b0000, 4'b0000, 4'b0111, 2'b10, "NOT_B_all_zeros",      2);
            apply_test(4'b0000, 4'b1010, 4'b0111, 2'b11, "NOT_B_both_valid",     2);
            apply_test(4'b0000, 4'b1010, 4'b0111, 2'b00, "NOT_B_invalid_input",  2);
            apply_test(4'b0000, 4'b1010, 4'b1111, 2'b10, "NOT_B_invalid_command",2);

            apply_test(4'b1100, 4'b0000, 4'b1000, 2'b01, "SHR1_A_Normal_case",   2);
            apply_test(4'b1111, 4'b0000, 4'b1000, 2'b01, "SHR1_A_all_ones",      2);
            apply_test(4'b0000, 4'b0000, 4'b1000, 2'b01, "SHR1_A_all_zeros",     2);
            apply_test(4'b1010, 4'b0000, 4'b1000, 2'b11, "SHR1_A_both_valid",    2);
            apply_test(4'b1100, 4'b0000, 4'b1000, 2'b00, "SHR1_A_invalid_input", 2);
            apply_test(4'b1100, 4'b0000, 4'b1000, 2'b10, "SHR1_A_only_B_valid",  2);

            apply_test(4'b0110, 4'b0000, 4'b1001, 2'b01, "SHL1_A_Normal_case",   2);
            apply_test(4'b1111, 4'b0000, 4'b1001, 2'b01, "SHL1_A_all_ones",      2);
            apply_test(4'b0000, 4'b0000, 4'b1001, 2'b01, "SHL1_A_all_zeros",     2);
            apply_test(4'b1010, 4'b0000, 4'b1001, 2'b11, "SHL1_A_both_valid",    2);
            apply_test(4'b0110, 4'b0000, 4'b1001, 2'b00, "SHL1_A_invalid_input", 2);
            apply_test(4'b0110, 4'b0000, 4'b1001, 2'b10, "SHL1_A_only_B_valid",  2);

            apply_test(4'b0000, 4'b1100, 4'b1010, 2'b10, "SHR1_B_Normal_case",   2);
            apply_test(4'b0000, 4'b1111, 4'b1010, 2'b10, "SHR1_B_all_ones",      2);
            apply_test(4'b0000, 4'b0000, 4'b1010, 2'b10, "SHR1_B_all_zeros",     2);
            apply_test(4'b0000, 4'b1010, 4'b1010, 2'b11, "SHR1_B_both_valid",    2);
            apply_test(4'b0000, 4'b1100, 4'b1010, 2'b00, "SHR1_B_invalid_input", 2);
            apply_test(4'b0000, 4'b1100, 4'b1010, 2'b01, "SHR1_B_only_A_valid",  2);

            apply_test(4'b0000, 4'b0110, 4'b1011, 2'b10, "SHL1_B_Normal_case",   2);
            apply_test(4'b0000, 4'b1111, 4'b1011, 2'b10, "SHL1_B_all_ones",      2);
            apply_test(4'b0000, 4'b0000, 4'b1011, 2'b10, "SHL1_B_all_zeros",     2);
            apply_test(4'b0000, 4'b1010, 4'b1011, 2'b11, "SHL1_B_both_valid",    2);
            apply_test(4'b0000, 4'b0110, 4'b1011, 2'b00, "SHL1_B_invalid_input", 2);
            apply_test(4'b0000, 4'b0110, 4'b1011, 2'b01, "SHL1_B_only_A_valid",  2);

            apply_test(4'b1010, 4'b0000, 4'b1100, 2'b11, "ROL_rot0",             2);
            apply_test(4'b1100, 4'b0001, 4'b1100, 2'b11, "ROL_A_B_rotate1",      2);
            apply_test(4'b1010, 4'b0010, 4'b1100, 2'b11, "ROL_A_B_rotate2",      2);
            apply_test(4'b1001, 4'b0011, 4'b1100, 2'b11, "ROL_A_B_rotate3",      2);
            apply_test(4'b1010, 4'b1000, 4'b1100, 2'b11, "ROL_ERR_upper_bit",    2);
            apply_test(4'b1010, 4'b1111, 4'b1100, 2'b11, "ROL_ERR_all_ones",     2);
            apply_test(4'b1010, 4'b0001, 4'b1100, 2'b01, "ROL_only_A_valid",     2);
            apply_test(4'b1010, 4'b0001, 4'b1100, 2'b10, "ROL_only_B_valid",     2);
            apply_test(4'b1010, 4'b0001, 4'b1100, 2'b00, "ROL_invalid_input",    2);
            apply_test(4'b1010, 4'b0001, 4'b1111, 2'b11, "ROL_A_B_invalid_command",2);

            apply_test(4'b1010, 4'b0000, 4'b1101, 2'b11, "ROR_rot0",             2);
            apply_test(4'b1100, 4'b0001, 4'b1101, 2'b11, "ROR_A_B_rotate1",      2);
            apply_test(4'b1010, 4'b0010, 4'b1101, 2'b11, "ROR_A_B_rotate2",      2);
            apply_test(4'b1001, 4'b0011, 4'b1101, 2'b11, "ROR_A_B_rotate3",      2);
            apply_test(4'b1010, 4'b1000, 4'b1101, 2'b11, "ROR_ERR_upper_bit",    2);
            apply_test(4'b1010, 4'b1111, 4'b1101, 2'b11, "ROR_ERR_all_ones",     2);
            apply_test(4'b1010, 4'b0001, 4'b1101, 2'b01, "ROR_only_A_valid",     2);
            apply_test(4'b1010, 4'b0001, 4'b1101, 2'b10, "ROR_only_B_valid",     2);
            apply_test(4'b1010, 4'b0001, 4'b1101, 2'b00, "ROR_invalid_input",    2);
            apply_test(4'b1010, 4'b0001, 4'b1111, 2'b11, "ROR_A_B_invalid_command",2);

            CE = 0;
            apply_test(4'b1010, 4'b1100, 4'b0000, 2'b11, "AND_CE_disabled",  2);
            apply_test(4'b1010, 4'b1100, 4'b0010, 2'b11, "OR_CE_disabled",   2);
            apply_test(4'b1010, 4'b1100, 4'b0100, 2'b11, "XOR_CE_disabled",  2);
            apply_test(4'b1010, 4'b0000, 4'b0110, 2'b01, "NOTA_CE_disabled", 2);
            apply_test(4'b0000, 4'b1010, 4'b0111, 2'b10, "NOTB_CE_disabled", 2);
            CE = 1;

        end
    endtask

    task apply_test(
        input [N-1:0] a,
        input [N-1:0] b,
        input [3:0] cmd,
        input [1:0] inp_valid,
        input [80*8:1] test_name,
        input integer wait_cycles
    );

    integer i;

    begin

        @(negedge CLK);

        OPA = a;
        OPB = b;
        CMD = cmd;
        INP_VALID = inp_valid;

        for(i = 0; i < wait_cycles; i = i + 1)
            @(posedge CLK);

        test_count = test_count + 1;

        if(compare_outputs(1'b0)) begin
            $display("[PASS] %s", test_name);
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] %s", test_name);
            display_mismatch();
            fail_count = fail_count + 1;
        end

    end
    endtask

    function [0:0] compare_outputs;
        input dummy;

        begin
            compare_outputs =
                (RES_dut    === RES_ref)   &&
                (COUT_dut   === COUT_ref)  &&
                (OFLOW_dut  === OFLOW_ref) &&
                (G_dut      === G_ref)     &&
                (E_dut      === E_ref)     &&
                (L_dut      === L_ref)     &&
                (ERR_dut    === ERR_ref);
        end
    endfunction

    task display_mismatch();
        begin
            $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_dut, COUT_dut, OFLOW_dut, G_dut, E_dut, L_dut, ERR_dut);
            $display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
                     RES_ref, COUT_ref, OFLOW_ref, G_ref, E_ref, L_ref, ERR_ref);
        end
    endtask

    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, tb_alu_design);
    end

endmodule
