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

// File name:   tb_transmitter.sv
// Created:     6/9/2014
// Author:      Xin Tze Tee
// Version:     1.0  Initial Design Entry
// Description: Testbench for Uart Transmitter (transmit.sv block).

`timescale 1ns / 10ps

module tb_transmitter();

	// Define parameters
	parameter CLK_PERIOD		= 30;
	parameter NORM_DATA_PERIOD	= (286 * CLK_PERIOD);

	reg tb_clk;
	reg tb_n_rst;

	// input variables
	reg tb_tx_enable;
	reg [7:0] tb_data_in;

	// output variables
	reg tb_busy;
	reg tb_data_out;

	// internal variables
	integer i;
	integer tb_check;
	reg tb_expected_data_out;

	transmit TRANS
	(	
	.clk(tb_clk), .n_rst(tb_n_rst), 
	.data_in(tb_data_in), 	// data packet to be transmitted
	//input wire start_bit,		// sends start bit
	.tx_enable(tb_tx_enable),		// enable signal
	//output wire startbit_sent,	// start bit is sent
	//output wire packet_sent, 	// data packet is succesfully sent
	.data_out(tb_data_out), 		// data bit that is shifted out
	.busy(tb_busy)
	);

	always
	begin : CLK_GEN
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2);
	end

	// Actual test bench process
	initial
	begin : TEST_PROC
		// Initilize all inputs
		tb_n_rst				= 1'b1; // Initially inactive
		tb_tx_enable			= 1'b0;
		tb_data_in				= 8'b11111111;

		// Get away from Time = 0
		#6;

		// Activate reset
		tb_n_rst = 1'b0; 
		// wait for a few clock cycles
		@(posedge tb_clk);
		@(posedge tb_clk);
		// Release on falling edge to prevent hold time violation
		@(negedge tb_clk);
		// Release reset
		tb_n_rst = 1'b1;
		tb_tx_enable = 1'b1;
		tb_data_in = 8'b10110101;

		// disable transmission
		@(posedge tb_clk);
		@(posedge tb_clk);
		tb_tx_enable = 1'b0;

		#(NORM_DATA_PERIOD * 1.5); // wait for the start bit	
		tb_check = 0;
		for(i = 0; i < 8; i++) begin
			tb_expected_data_out = tb_data_in[i];
			if (tb_expected_data_out == tb_data_out)
				tb_check = tb_check + 1;
			#(NORM_DATA_PERIOD); // sample at the next bit
		end

		#(NORM_DATA_PERIOD * 0.5);
		// Check outputs
		assert(tb_check == 8)
			$info("Test case 1: Test data correctly transmitted");
		else
			$error("Test case 1: Test data was not correctly transmitted");


		// Test case 2: Different data packet
		tb_tx_enable		= 1'b1;
		tb_data_in			= 8'b01000011;

		// disable transmission
		@(posedge tb_clk);
		@(posedge tb_clk);
		tb_tx_enable		= 1'b0;

		#(NORM_DATA_PERIOD * 1.5); // wait for the start bit	
		tb_check = 0;
		for(i = 0; i < 8; i++) begin
			tb_expected_data_out = tb_data_in[i];
			if (tb_expected_data_out == tb_data_out)
				tb_check = tb_check + 1;
			#(NORM_DATA_PERIOD); // sample at the next bit
		end

		#(NORM_DATA_PERIOD * 0.5);
		// Check outputs
		assert(tb_check == 8)
			$info("Test case 2: Test data correctly transmitted");
		else
			$error("Test case 2: Test data was not correctly transmitted");


	end

endmodule

