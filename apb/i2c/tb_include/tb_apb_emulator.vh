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

// Declare bus signals

logic PWRITE, PENABLE, PSEL;
logic [31:0] PWDATA, PADDR, PRDATA;

task APB_reset();
	PADDR=0;
	PSEL=0;
	PWRITE=0;
	PENABLE=0;
	PWDATA=0;
endtask

task APB_write(input logic[31:0] data, address);
	@(negedge tb_clk);
	PWDATA=data;
	PADDR = address;
	PSEL = 1'b1;
	PWRITE = 1'b1;
	@(negedge tb_clk);
	PENABLE = 1'b1;
	@(negedge tb_clk);
	PENABLE = 1'b0;
	PSEL = 1'b0;
	@(negedge tb_clk);
endtask

task APB_read(output logic[31:0] data, input logic [31:0] address);
	@(negedge tb_clk);
	PADDR = address;
	PSEL = 1'b1;
	PWRITE = 1'b0;
	@(negedge tb_clk);
	PENABLE = 1'b1;
	@(posedge tb_clk);
	data = PRDATA;
	@(negedge tb_clk);
	PENABLE = 1'b0;
	PSEL = 1'b0;
	@(negedge tb_clk);
endtask

task APB_write_control(
	input logic en_clock_strech,
	logic transaction_begin,
	logic data_direction,
	logic[5:0] packet_size,
	logic ms_select,
	logic address_mode
);
	APB_write({21'd0, en_clock_strech,transaction_begin,data_direction,packet_size,ms_select,address_mode}, 32'd4);
endtask

task APB_write_addr(input logic[31:0] data);
	APB_write(data,32'd8);
endtask

task APB_write_tx(input logic[31:0] data);
	APB_write(data,32'd0);
endtask

task APB_write_div(input logic[31:0] data);
	APB_write(data,32'd20);
endtask

task APB_read_status(output logic [31:0] data);
	APB_read(data,32'd16);
endtask

task APB_read_rx(output logic [31:0] data);
	APB_read(data,32'd12);
endtask



/*
task write_control(input logic[31:0] data);
	@(negedge tb_clk);
	PWDATA=data;
	PADDR = 32'd4;
	PSEL = 1'b1;
	PWRITE = 1'b1;
	@(negedge tb_clk);
	PENABLE = 1'b1;
	@(negedge tb_clk);
	PENABLE = 1'b0;
	PSEL = 1'b0;
	@(negedge tb_clk);
endtask

task write_control_wrapper(
	input logic en_clock_strech,
	logic transaction_begin,
	logic data_direction,
	logic[5:0] packet_size,
	logic ms_select,
	logic address_mode
);
	write_control({21'd0, en_clock_strech,transaction_begin,data_direction,packet_size,ms_select,address_mode});
endtask

task write_addr(input logic [31:0] data);
	PWDATA=data;
	PADDR = 32'd8;
	PSEL = 1'b1;
	PWRITE = 1'b1;
	@(posedge tb_clk);
	PENABLE = 1'b1;
	@(posedge tb_clk);
	PENABLE = 1'b0;
	PSEL = 1'b0;
	@(posedge tb_clk);
endtask

task write_tx(input logic[31:0] data);
	PWDATA=data;
	PADDR = 32'd0;
	PSEL = 1'b1;
	PWRITE = 1'b1;
	@(posedge tb_clk);
	PENABLE = 1'b1;
	@(posedge tb_clk);
	PENABLE = 1'b0;
	PSEL = 1'b0;
	@(posedge tb_clk);
endtask

task write_div(input logic [31:0] data);
	PWDATA=data;
	PADDR = 32'd20;
	PSEL = 1'b1;
	PWRITE = 1'b1;
	@(posedge tb_clk);
	PENABLE = 1'b1;
	@(posedge tb_clk);
	PENABLE = 1'b0;
	PSEL = 1'b0;
	@(posedge tb_clk);
endtask

task read_rx(output logic[7:0] data);
	PADDR = 32'd12;
	PSEL = 1'b1;
	PWRITE = 1'b0;
	@(posedge tb_clk);
	PENABLE = 1'b1;
	#(CLOCK_PERIOD/10.0*9.0);
	data = PRDATA[7:0];
	@(posedge tb_clk);
	PSEL = 1'b0;
	PENABLE = 1'b0;
	@(posedge tb_clk);
endtask

task read_status(output logic[7:0] data);
	PADDR = 32'd16;
	PSEL = 1'b1;
	PWRITE = 1'b0;
	@(posedge tb_clk);
	PENABLE = 1'b1;
	#(CLOCK_PERIOD/10.0*9.0);
	data = PRDATA;
	@(posedge tb_clk);
	PENABLE = 1'b0;
	PSEL = 1'b0;
	@(posedge tb_clk);
endtask
*/

task check_apb_read();
	assert(tb_expected_PRDATA == PRDATA)
	else $error("Emulated APB recieved %d, expected %d", PRDATA, tb_expected_PRDATA);
endtask
