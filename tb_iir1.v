`timescale 1ns/1ps

module tb_iir1;

    reg clk;
    reg rst_n;
    reg  signed [3:0] x_in;
    reg  signed [3:0] b0, b1, a1;
    wire signed [7:0] y_out;

    iir1 dut (
        .clk   (clk),
        .rst_n (rst_n),
        .x_in  (x_in),
        .b0    (b0),
        .b1    (b1),
        .a1    (a1),
        .y_out (y_out)
    );

    initial begin
        clk = 0;
        forever #50 clk = ~clk;
    end

    integer i;
    reg signed [3:0]  x_prev_ref;
    reg signed [7:0]  y_prev_ref;
    reg signed [11:0] mult2_full;
    reg signed [7:0]  mult2_trunc;
    reg signed [7:0]  mult0_ref, mult1_ref;
    reg signed [7:0]  sum_ref;
    reg test_pass;

    task run_case(
        input [255:0] case_name,
        input signed [3:0] tb_b0,
        input signed [3:0] tb_b1,
        input signed [3:0] tb_a1,
        input integer n_cycles,
        input integer stimulus_start_cycle,
        input [1023:0] stimulus_type
    );
    begin
        $display("\n=== Running %s ===", case_name);
        b0 = tb_b0;
        b1 = tb_b1;
        a1 = tb_a1;

        rst_n = 0;
        x_in  = 0;
        #150;
        rst_n = 1;
        #100;

        x_prev_ref = 0;
        y_prev_ref = 0;
        test_pass  = 1;

        for (i = 0; i < n_cycles; i = i + 1) begin
	    
            if (stimulus_type == "step") begin
                if (i >= stimulus_start_cycle) x_in = 4'sd5;
                else x_in = 4'sd0;

            end else if (stimulus_type == "step_overflow") begin
                if (i >= stimulus_start_cycle) x_in = 4'sd7;
                else x_in = 4'sd0;

            end else if (stimulus_type == "impulse") begin
                if (i == stimulus_start_cycle) x_in = 4'sd5;
                else x_in = 4'sd0;

            end else if (stimulus_type == "toggle") begin
                if (i % 2 == 0) x_in = 4'sd2;
                else x_in = 4'sd6;

            end else begin
                x_in = 4'sd0;
            end
 
            @(posedge clk);
            mult0_ref = b0 * x_in;
            mult1_ref = b1 * x_prev_ref;
            mult2_full  = a1 * y_prev_ref;
            mult2_trunc = mult2_full >>> 4;

            sum_ref = mult0_ref + mult1_ref + mult2_trunc;
            sum_ref = $signed($unsigned(sum_ref) & 8'hFF);

            #1;
            if (y_out !== sum_ref) begin
                $display(
                  "Mismatch at cycle %0d: DUT y=%0d (0x%0h) REF y=%0d (0x%0h)",
                  i, y_out, y_out, sum_ref, sum_ref
                );
                test_pass = 0;
            end

            x_prev_ref = x_in;
            y_prev_ref = sum_ref;
        end

        if (test_pass)
            $display(">>> %s: PASS", case_name);
        else
            $display(">>> %s: FAIL", case_name);

    end
    endtask

    initial begin
        #200;

        run_case("Case 1 - LowPass",   4'sd3,  4'sd0,  4'sd4, 40, 2, "step");
        run_case("Case 2 - HighPass",  4'sd2, -4'sd2, -4'sd4,40, 2, "step");
        run_case("Case 3 - Impulse",   4'sd3,  4'sd3,  4'sd7,40, 2, "impulse");
        run_case("Case 4 - Toggle",    4'sd1,  4'sd1,  4'sd4,40, 0, "toggle");
        run_case("Case 5 - Overflow",  4'sd7,  4'sd7,  4'sd6,40, 2, "step_overflow");

        $display("\nAll test cases completed.");
        $stop;
    end

endmodule

