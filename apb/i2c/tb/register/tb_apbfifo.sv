// ------------------------------------------------------------------------
// Copyright 2019 Purdue University SoCET design team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ------------------------------------------------------------------------

// $Id: $
// File name:   tb_fifo.sv
// Created:     4/19/2016
// Author:      Sam Sowell
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Fifo testbench
`timescale 1ns/10ps
module tb_apbfifo();
	// Define Parameters
	parameter CLK_PERIOD = 2.5;
	parameter NORM_DATA_PERIOD = 10*CLK_PERIOD;

	// DUT Inputs
	reg tb_w_clk;
	reg tb_r_clk;
	reg tb_n_rst;
	reg tb_w_enable;
	reg tb_r_enable;
	reg [7:0] tb_w_data;

	// DUT Outputs
	reg [7:0] tb_r_data;
	reg tb_full;
	reg tb_empty;
	reg tb_almost_full;

	// Test Bench Debug Signals
	integer tb_test_case = 1;
	reg [7:0] tb_test_data;
	reg [7:0] tb_expected_r_data;
	reg tb_expected_full;
	reg tb_expected_empty;
	reg tb_expected_almost_full;

	// Write Clock Generation Block
	always
	begin
		tb_w_clk = 1'b0;
		#(CLK_PERIOD);
		tb_w_clk = 1'b1;
		#(CLK_PERIOD);
	end

	// Read Clock Generation Block
	always
	begin
		tb_r_clk = 1'b0;
		#(CLK_PERIOD/2);
		tb_r_clk = 1'b1;
		#(CLK_PERIOD/2);
	end

	// Device Under Test Declaration
	apbfifo DUT (
		.w_clk(tb_w_clk),
		.r_clk(tb_r_clk), 
		.n_rst(tb_n_rst),
		.w_enable(tb_w_enable),
		.r_enable(tb_r_enable), 
		.w_data(tb_w_data),
		.r_data(tb_r_data), 
		.full(tb_full),
		.empty(tb_empty), 
		.almost_full(tb_almost_full)
	);

	// Send Data Task
	task sendpacket;
		@(negedge tb_w_clk);
	begin
		tb_w_data = tb_test_data;
		@(posedge tb_w_clk);
		@(posedge tb_w_clk);
		tb_w_enable <= 1;
		@(posedge tb_w_clk);
		tb_w_enable <= 0;
		@(posedge tb_w_clk);
		@(posedge tb_w_clk);
	end
	endtask

	// Recieve Data Task
	task recieve_packet;
		@(negedge tb_r_clk);
	begin
		@(posedge tb_r_clk);
		tb_r_enable <= 1;
		@(posedge tb_r_clk);
		tb_r_enable <= 0;
		@(posedge tb_r_clk);
	end
	endtask

	// Check Values Task
	task check_outputs;
		input [7:0] expected_r_data;
		input expected_full;
		input expected_empty;
		input expected_almost_full;
	begin
		assert(expected_r_data == tb_r_data)
			$info("[PASS] Test Case %0d: Correct r_data", tb_test_case);
		else
			$error("[FAIL] Test Case %0d: Incorrect r_data", tb_test_case);

		assert(expected_full == tb_full)
			$info("[PASS] Test Case %0d: Correct full flag", tb_test_case);
		else
			$error("[FAIL] Test Case %0d: Incorrect full flag", tb_test_case);
		
		assert(expected_empty == tb_empty)
			$info("[PASS] Test Case %0d: Correct empty flag", tb_test_case);
		else
			$error("[FAIL] Test Case %0d: Incorrect empty flag", tb_test_case);

		assert(expected_almost_full == tb_almost_full)
			$info("[PASS] Test Case %0d: Correct almost_full flag", tb_test_case);
		else
			$error("[FAIL] Test Case %0d: Incorrect almost_full flag", tb_test_case);
	end
	endtask

	// Reset FIFO Task
	task reset_dut;
	begin
		// Activate the design's reset
		tb_n_rst = 1'b0;

		// Wait for a couple clock cycles
		@(posedge tb_w_clk);
		@(posedge tb_w_clk);
		@(negedge tb_w_clk);
	        tb_n_rst = 1'b1;
		@(posedge tb_w_clk);
		@(posedge tb_w_clk);
	        //@(posedge tb_w_clk);
	        //@(posedge tb_w_clk);
	 
	end
	endtask

	// Test Bench Process
	initial
	begin

		// Get away from time = 0
		#0.1;

		// Intializations
		tb_test_data <= '0;
		tb_w_data    <= '0;
		tb_n_rst     <= 1'b1;
		tb_w_enable  <= 1'b0;
		tb_r_enable  <= 1'b0;
		//tb_almost_full <= 1'b0;

//-----------------------------------------------------------------------------------------------------------------------------
		// Test Case 1: Power-on Reset
		// Define expected values
			tb_expected_r_data      <= 8'd0;
			tb_expected_full        <= 1'b0;
			tb_expected_empty       <= 1'b1;
			tb_expected_almost_full <= 1'b0;
		// Define test data
			tb_test_data <= '1;
		// Run test
			reset_dut();
	        @(posedge tb_w_clk);
	        reset_dut();
			check_outputs(tb_expected_r_data, tb_expected_full, tb_expected_empty, tb_expected_almost_full);
			tb_test_case++;

//-----------------------------------------------------------------------------------------------------------------------------
		// Test Case 2: Held Reset
		// Define expected values
			tb_expected_r_data      <= 8'd0;
			tb_expected_full        <= 1'b0;
			tb_expected_empty       <= 1'b1;
			tb_expected_almost_full <= 1'b0;
		// Define test data
			tb_test_data <= '1;
		// Run test
			tb_n_rst <= 1'b0;
			@(posedge tb_w_clk);
			@(posedge tb_w_clk);
			@(posedge tb_w_clk);
			check_outputs(tb_expected_r_data, tb_expected_full, tb_expected_empty, tb_expected_almost_full);
			tb_test_case++;

//------------------------------------------------------------------------------------------------------------------------------
		// Test Case 3: Write Test		
		// Define expected values
			tb_expected_r_data      <= '0;
			tb_expected_full        <= 1'b0;
			tb_expected_empty       <= 1'b0;
			tb_expected_almost_full <= 1'b0;
		// Define test data
			tb_test_data <= '1;
		// Run test
			tb_n_rst <= 1'b1;
			sendpacket();
			check_outputs(tb_expected_r_data, tb_expected_full, tb_expected_empty, tb_expected_almost_full);
			tb_test_case++;

//----------------------------------------------------------------------------------------------------------------------------
		// Test Case 4: Almost Full Test		
		// Define expected values
			tb_expected_r_data      <= 8'd0;
			tb_expected_full        <= 1'b0;
			tb_expected_empty       <= 1'b0;
			tb_expected_almost_full <= 1'b1;
		// Define test data
			tb_test_data <= 8'd1;
		// Run test
			reset_dut();
			sendpacket();
			tb_test_data <= 8'd2;
			sendpacket();
			tb_test_data <= 8'd3;
			sendpacket();
			tb_test_data <= 8'd4;
			sendpacket();
			tb_test_data <= 8'd5;
			sendpacket();
			tb_test_data <= 8'd6;
			sendpacket();
			tb_test_data <= 8'd7;
			sendpacket();
			check_outputs(tb_expected_r_data, tb_expected_full, tb_expected_empty, tb_expected_almost_full);
			tb_test_case++;

//----------------------------------------------------------------------------------------------------------------------------
		// Test Case 5: Full Test		
		// Define expected values
			tb_expected_r_data      <= 8'd8;
			tb_expected_full        <= 1'b1;
			tb_expected_empty       <= 1'b0;
			tb_expected_almost_full <= 1'b0;
		// Define test data
			tb_test_data <= 8'd8;
		// Run test
			sendpacket();
			check_outputs(tb_expected_r_data, tb_expected_full, tb_expected_empty, tb_expected_almost_full);
			tb_test_case++;

//----------------------------------------------------------------------------------------------------------------------------
		// Test Case 6: Overflow Test
		// Define expected values
			tb_expected_r_data      <= 8'd8;
			tb_expected_full        <= 1'b1;
			tb_expected_empty       <= 1'b0;
			tb_expected_almost_full <= 1'b0;
		// Define test data
			tb_test_data <= 8'd9;
		// Run test
			sendpacket();
			check_outputs(tb_expected_r_data, tb_expected_full, tb_expected_empty, tb_expected_almost_full);
			tb_test_case++;

//----------------------------------------------------------------------------------------------------------------------------
		// Test Case 7: Read Test
		// Define expected values
			tb_expected_r_data      <= 8'd1;
			tb_expected_full        <= 1'b0;
			tb_expected_empty       <= 1'b0;
			tb_expected_almost_full <= 1'b1;
		// Define test data
			tb_test_data <= 8'd8;
		// Run test
			recieve_packet();
			check_outputs(tb_expected_r_data, tb_expected_full, tb_expected_empty, tb_expected_almost_full);
			tb_test_case++;

//----------------------------------------------------------------------------------------------------------------------------
		// Test Case 8: Empty Test
		// Define expected values
			tb_expected_r_data      <= 8'd8;
			tb_expected_full        <= 1'b0;
			tb_expected_empty       <= 1'b1;
			tb_expected_almost_full <= 1'b0;
		// Define test data
			tb_test_data <= 8'd8;
		// Run test
			recieve_packet();
			recieve_packet();
			recieve_packet();
			recieve_packet();
			recieve_packet();
			recieve_packet();
			recieve_packet();
			check_outputs(tb_expected_r_data, tb_expected_full, tb_expected_empty, tb_expected_almost_full);
			tb_test_case++;

//----------------------------------------------------------------------------------------------------------------------------
		// Test Case 9: Underflow Test
		// Define expected values
			tb_expected_r_data      <= 8'd8;
			tb_expected_full        <= 1'b0;
			tb_expected_empty       <= 1'b1;
			tb_expected_almost_full <= 1'b0;
		// Define test data
			tb_test_data <= 8'd8;
		// Run test
			recieve_packet();
			check_outputs(tb_expected_r_data, tb_expected_full, tb_expected_empty, tb_expected_almost_full);
			tb_test_case++;
	end	

endmodule
