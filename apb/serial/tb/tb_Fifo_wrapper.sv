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

// File name:   tb_Fifo_wrapper.sv
// Created:     7/24/2014
// Author:      Xin Tze Tee
// Version:     1.0  
// Description: Testbench for Fifo Wrapper.

`timescale 1ns / 10ps

module tb_Fifo_wrapper ();

localparam	CLK_PERIOD	= 10;
localparam	CHECK_DELAY = 4; // Check 4ns after the rising edge to allow for propagation delay

// Declare DUT portmap signals
reg tb_clk;
reg tb_n_rst;
reg tb_read_enable;
reg tb_write_enable;
reg [7:0] tb_write_data;

// output test bench variables
reg [7:0] tb_read_data;
reg tb_fifo_empty;
reg tb_fifo_full;
reg [7:0] tb_expected_read_data;
reg tb_expected_fifo_empty;
reg tb_expected_fifo_full;

Fifo_wrapper Fifo_wrapper
(
	.clk(tb_clk), .n_rst(tb_n_rst),
	.wEnable(tb_write_enable),
	.rEnable(tb_read_enable),
	.wData(tb_write_data),
	.rData(tb_read_data),
	.fifoEmpty(tb_fifo_empty),
	.fifoFull(tb_fifo_full)
);

// Clock generation block
always
begin
	tb_clk = 1'b0;
	#(CLK_PERIOD/2.0);
	tb_clk = 1'b1;
	#(CLK_PERIOD/2.0);
end

// Test bench main process
initial
begin

//--------------------------------------------------------------------------------------
// Initialize all of the test inputs
	tb_n_rst = 1'b0;
	tb_read_enable = 0;
	tb_write_enable = 0;
	tb_write_data = 8'b00000000;
	tb_expected_read_data = 8'b00000000;
	tb_expected_fifo_empty = 1;
	tb_expected_fifo_full = 0;

	@(negedge tb_clk);
	tb_n_rst = 1'b1;
	@(posedge tb_clk);
	#(CLK_PERIOD);

	
	// write 1st data into FIFO
	tb_write_enable = 1;
	tb_write_data = 8'b11110000;
	#(CLK_PERIOD);
	tb_write_enable = 0;
	tb_expected_read_data = 8'b11110000;
	#(CLK_PERIOD);

	// write 2nd data into FIFO
	tb_write_enable = 1;
	tb_write_data = 8'b00001111;
	#(CLK_PERIOD);
	tb_write_enable = 0;
	#(CLK_PERIOD);

	// write 3rd data into FIFO
	tb_write_enable = 1;
	tb_write_data = 8'b10101010;
	#(CLK_PERIOD);
	tb_write_enable = 0;
	#(CLK_PERIOD);

	// write 4th data into FIFO
	tb_write_enable = 1;
	tb_write_data = 8'b01010101;
	#(CLK_PERIOD);
	tb_write_enable = 0;
	#(CLK_PERIOD);

	// read data from FIFO
	tb_read_enable = 1;
	tb_expected_fifo_empty = 0;
	#(CLK_PERIOD);
	tb_read_enable = 0;
	tb_expected_fifo_empty = 1;
	tb_expected_read_data = 8'b00001111;
	#(CLK_PERIOD);

	// write 5th data into FIFO
	tb_write_enable = 1;
	tb_write_data = 8'b11000011;
	#(CLK_PERIOD);
	tb_write_enable = 0;
	#(CLK_PERIOD);

	// write 6th data into FIFO
	tb_write_enable = 1;
	tb_write_data = 8'b00111100;
	#(CLK_PERIOD);
	tb_write_enable = 0;
	#(CLK_PERIOD);

	// read data from FIFO
	tb_read_enable = 1;
	tb_expected_fifo_empty = 0;
	#(CLK_PERIOD);
	tb_read_enable = 0;
	#(CLK_PERIOD);

	// write 7th data into FIFO
	tb_write_enable = 1;
	tb_write_data = 8'b11101110;
	#(CLK_PERIOD);
	tb_write_enable = 0;
	#(CLK_PERIOD);

	// write 8th data into FIFO
	tb_write_enable = 1;
	tb_write_data = 8'b01111110;
	#(CLK_PERIOD);
	tb_write_enable = 0;
	#(CLK_PERIOD);

	// write 9th data into FIFO  (overwrite)
	tb_write_enable = 1;
	tb_write_data = 8'b01100101;
	#(CLK_PERIOD);
	tb_write_enable = 0;
	#(CLK_PERIOD);
end

endmodule
