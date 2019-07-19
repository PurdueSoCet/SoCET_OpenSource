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
// File name:   tb_apbSlave.sv
// Created:     4/21/2016
// Author:      Sam Sowell
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Test Bench for APB Slave
`timescale 1ns/10ps
module tb_apbSlave();
	// Declare Parameters
	parameter CLK_PERIOD = 2.5;

	// DUT Inputs
	reg tb_pclk; 
	reg tb_n_rst; 
	reg [31:0] tb_pdata;
	reg [31:0] tb_paddr;
	reg tb_penable;
	reg tb_psel;
	reg tb_pwrite;
	reg [7:0] tb_rx_data;
	reg tb_rx_w_ena; 
	reg [5:0] tb_i2c_status;
	reg tb_scl; 
	reg tb_tx_r_ena;

	// DUT Outputs
    reg [31:0] tb_prdata; 
    reg tb_i2c_interrupt; 
    reg [7:0] tb_tx_data;
    reg tb_rx_full; 
    reg tb_rx_almost_full; 
    reg [8:0] tb_control; 
    reg [9:0] tb_address;
    //reg [12:0] tb_status;
    reg [31:0] tb_clk_out;

	// pclk Generation Block
	always
	begin
		tb_pclk = 1'b0;
		#(CLK_PERIOD/2);
		tb_pclk = 1'b1;
		#(CLK_PERIOD/2);
	end

	// scl Generation Block
	always
	begin
		tb_scl = 1'b0;
		#(CLK_PERIOD*30);
		tb_scl = 1'b1;
		#(CLK_PERIOD*30);
	end

	// Testbench Debug Signals
	integer tb_test_case = 1;
	reg [31:0] tb_expected_prdata;

	// DUT Declaration
	apbSlave IX (
		.pclk(tb_pclk), 
		.n_rst(tb_n_rst), 
		.pdata(tb_pdata),
		.paddr(tb_paddr),
		.penable(tb_penable),
		.psel(tb_psel),
		.pwrite(tb_pwrite), 
		.rx_data(tb_rx_data),	 
		.rx_w_ena(tb_rx_w_ena), 
		.i2c_status(tb_i2c_status),
		.scl(tb_scl), 
		.tx_r_ena(tb_tx_r_ena),
    	.prdata(tb_prdata), 
    	.i2c_interrupt(tb_i2c_interrupt),  
    	.tx_data(tb_tx_data),
    	.rx_full(tb_rx_full), 
    	.rx_almost_full(tb_rx_almost_full), 
    	.control(tb_control), 
    	.address(tb_address),
    	//.status(tb_status),
    	.clk_out(tb_clk_out)
	);

	// Reset DUT Task
	task reset_dut;
	begin
		// Activate the design's reset
		tb_n_rst = 1'b0;

		// Wait for a couple clock cycles
		@(posedge tb_pclk);
		@(posedge tb_pclk);
		@(negedge tb_pclk);
		tb_n_rst = 1;
		@(posedge tb_pclk);
		@(posedge tb_pclk);
	end
	endtask

	// Check Outputs Task
	task check_outputs;
		input tb_expected_prdata;
	begin
		assert(tb_expected_prdata == tb_prdata)
			$info("[PASS] Test Case %0d: Correct prdata", tb_test_case);
		else
			$error("[FAIL] Test Case %0d: Expected %d, Recieved %d", tb_test_case, tb_expected_prdata, tb_prdata);
	end
	endtask

	// Test Bench Process
	initial
	begin
		// Get away from time = 0
		#0.1;

		// Initializations
		tb_n_rst      <= 1'b1; 
		tb_pdata      <= '0;
		tb_paddr      <= '0;
		tb_penable    <= 1'b0;
		tb_psel       <= 1'b0;
		tb_pwrite     <= 1'b0;
		tb_rx_data     <= '0;
		tb_rx_w_ena    <= 1'b0; 
		tb_i2c_status <= '0; 
		tb_tx_r_ena   <= 1'b0;
		tb_expected_prdata <= '0;

//-----------------------------------------------------------------
		// Test Case 1: Power on reset
		tb_n_rst <= 1'b0;
		@(posedge tb_pclk);
		@(posedge tb_pclk);
		tb_test_case++;

//-----------------------------------------------------------------
		// Test Case 2: Held reset
		@(posedge tb_pclk);
		@(posedge tb_pclk);
		@(posedge tb_pclk);
		@(posedge tb_pclk);
		tb_test_case++;

//-----------------------------------------------------------------
		// Test Case 3: Writing to TX FIFO
		tb_n_rst  <= 1'b1;
		tb_pdata  <= 32'd0;
		tb_paddr  <= 32'd1;
		@(posedge tb_pclk);
		tb_psel   <= 1'b1;
		tb_pwrite <= 1'b1;
		@(posedge tb_pclk);
		tb_penable <= 1'b1;
		@(posedge tb_pclk);
		tb_penable <= 1'b0;
		tb_psel    <= 1'b0;
		@(posedge tb_pclk);
		tb_tx_r_ena <= 1'b1;
		@(posedge tb_scl);
		tb_tx_r_ena <= 1'b0;
		@(posedge tb_pclk);
		//check_outputs(tb_expected_prdata);
		tb_test_case++;

//-----------------------------------------------------------------
		// Test Case 4: Writing to Control Register
		tb_pdata <= 32'd4;
		tb_paddr <= 32'd2;
		tb_psel  <= 1'b1;
		tb_pwrite <= 1'b1;
		@(posedge tb_pclk);
		tb_pwrite  <= 1'b0;
		tb_penable <= 1'b1;
		@(posedge tb_pclk);
		tb_penable <= 1'b0;
		tb_psel    <= 1'b0;
		@(posedge tb_pclk);
		//check_outputs(tb_expected_prdata);
		tb_test_case++;

//-----------------------------------------------------------------
		// Test Case 5: Writing to Address Register
		tb_pdata <= 32'd3;
		tb_paddr <= 32'd8;
		tb_psel  <= 1'b1;
		tb_pwrite <= 1'b1;
		@(posedge tb_pclk);
		tb_pwrite <= 1'b0;
		tb_penable <= 1'b1;
		@(posedge tb_pclk);
		tb_penable <= 1'b0;
		tb_psel <= 1'b0;
		@(posedge tb_pclk);
		//check_outputs(tb_expected_prdata);
		tb_test_case++;

//-----------------------------------------------------------------
		// Test Case 6: Writing to Clock Divider
		tb_pdata <= 32'd18;
		tb_paddr <= 32'd20;
		tb_psel <= 1'b1;
		@(posedge tb_pclk);
		tb_penable <= 1'b1;
		@(posedge tb_pclk);
		tb_psel <= 1'b0;
		tb_penable <= 1'b0;
		@(posedge tb_pclk);
		tb_test_case++;

//-----------------------------------------------------------------
		// Test Case 7: Reading from RX FIFO
		tb_rx_data  <= 32'd4;
		tb_expected_prdata = 32'd4;
		tb_rx_w_ena <= 1'b1;
		@(posedge tb_scl);
		tb_rx_w_ena <= 1'b0;
		@(posedge tb_scl);
		@(posedge tb_scl);
		tb_paddr  <= 32'd12;
		tb_psel   <= 1'b1;
		tb_pwrite <= 1'b0;
		//@(posedge tb_scl);
		@(posedge tb_pclk);
		tb_penable <= 1'b1;
		@(posedge tb_pclk);
		tb_penable <= 1'b0;
		tb_psel <= 1'b0;
		@(posedge tb_pclk);
		@(posedge tb_pclk);
		@(negedge tb_pclk);
		//@(posedge tb_pclk);
		//@(posedge tb_pclk);
		//@(posedge tb_pclk);
		check_outputs(tb_expected_prdata);
		@(posedge tb_pclk);
		tb_test_case++;

//-----------------------------------------------------------------
		// Test Case 8: Reading from Status Register
		tb_i2c_status <= 7'd6;
		tb_expected_prdata <= 32'b0010010000110;
		@(posedge tb_scl);
		tb_psel    <= 1'b1;
		tb_paddr   <= 32'd16;
		@(posedge tb_pclk);
		tb_penable	 <= 1'b1;
		@(posedge tb_pclk);
		tb_penable <= 1'b0;
		tb_psel <= 1'b0;
		@(posedge tb_pclk);
		check_outputs(tb_expected_prdata);
		tb_test_case++;

//-----------------------------------------------------------------
		// Test Case 9: Interrupt Check
		tb_i2c_status <= '1;
		tb_expected_prdata <= 32'b0010011111111;
		@(posedge tb_pclk);
		@(posedge tb_pclk);
		check_outputs(tb_expected_prdata);
		tb_test_case++;

	end

endmodule