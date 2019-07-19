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
// File name:   apbSlave.sv
// Created:     4/21/2016
// Author:      Sam Sowell
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: APB Slave
module apbSlave(
	input wire pclk, 
	input wire n_rst, 
	input wire [31:0] pdata,
	input wire [31:0] paddr,
	input wire penable,
	input wire psel,
	input wire pwrite, 
	input wire [7:0] rx_data, 
	input wire rx_w_ena, 
	input wire [5:0] i2c_status,
	input wire scl, 
	input wire tx_r_ena,
    output reg [31:0] prdata, 
    output reg i2c_interrupt, 
    output reg [7:0] tx_data,
    output reg rx_almost_full, 
    output reg rx_full,
    output reg [10:0] control, 
    output reg [9:0] address,
    output reg [31:0] clk_out,
    output reg tx_empty
	);

// Internal Signal Declarations
reg tx_w_ena;
reg cr_w_ena;
reg cr_r_ena;
reg addr_ena;
reg [9:0] addr_data;
reg [1:0] rx_r_ena;
reg [12:0] next_status;
reg clk_div_ena;
reg [7:0] i2c_data;
reg tx_full;
reg tx_almst_full;
reg rx_empty;
reg transaction_begin;
reg transaction;
reg mid_tx_empty;
reg mid_rx_full;
reg [12:0] status;
wire status_clear;

address_decoder IX10 (
	.pclk(pclk),
	.n_rst(n_rst),
	.paddr(paddr),
	.penable(penable),
	.psel(psel),
	.pwrite(pwrite),
	.tx_w_ena(tx_w_ena),
	.cr_w_ena(cr_w_ena),
	.cr_r_ena(cr_r_ena),
	.addr_ena(addr_ena),
	.rx_r_ena(rx_r_ena),
	.clk_div_ena(clk_div_ena),
	//.transaction_begin(transaction_begin)
	.status_clear(status_clear)
	);

// TX FIFO
apbfifo IX1 (
	.w_data(pdata[7:0]),
	.w_enable(tx_w_ena),
	.r_enable(tx_r_ena),
	.r_clk(scl),
	.w_clk(pclk),
	.n_rst(n_rst),
	.r_data(tx_data),
	.full(tx_full),
	.empty(tx_empty),
    .almost_full(tx_almost_full)
);

// Control Register
flexPTP #(10) IX2 (
	//.data_in({2'b00, pdata[7], transaction_begin, pdata[6:0]}),
	.data_in({pdata[10:0]}),
	.clk(pclk),
	.shift_enable(cr_w_ena),
	.n_rst(n_rst),
	.clear(i2c_status[5]),
	.data_out(control)
);

// I2C Address Logic
/*always_comb
begin
	if(control[0]) begin
		addr_data = pdata[9:0];
	end else begin
		addr_data = {3'b000, pdata[6:0]};
	end
end*/

// I2C Address Register
flexPTP #(9) IX8 (
	.data_in(pdata[9:0]),
	.clk(pclk),
	.shift_enable(addr_ena),
	.n_rst(n_rst),
	.data_out(address)
);

// RX FIFO
apbfifo IX3 (
	.w_data(rx_data),
	.w_enable(rx_w_ena),
	.r_enable(rx_r_ena[0]),
	.r_clk(pclk),
	.w_clk(scl),
	.n_rst(n_rst),
	.r_data(i2c_data),
	.full(rx_full),
	.empty(rx_empty),
    .almost_full(rx_almost_full)
);

// Status Register Logic
statusLogic IX4 (
	.i2c_status(i2c_status[4:0]),
	.tx_full(tx_full),
	.tx_empty(tx_empty),
	.rx_full(rx_full),
	.rx_empty(rx_empty),
	.rx_w_ena(rx_w_ena),
	.tx_r_ena(tx_r_ena),
	.mid_tx_empty(mid_tx_empty),
	.mid_rx_full(mid_rx_full),
	.next_status(next_status)
);

// Status Register
statusReg IX5 (
	.data_in(next_status),
	.clk(pclk), 
	.n_rst(n_rst), 
	.clear(status_clear),
	.data_out(status)
);

// Actual Clock Divider
flexPTP #(31) IX9 (
	.data_in(pdata),
	.clk(pclk),
	.shift_enable(clk_div_ena),
	.n_rst(n_rst),
	.data_out(clk_out)
	);

// Output MUX
always_comb
begin
	if(rx_r_ena[1]) begin
		prdata = {24'd0, i2c_data};
  end else if (cr_r_ena) begin
    prdata = {21'd0, control};
	end else begin
		prdata = {19'd0, status};
	end
end

// Interrupt Logic
interruptLogic IX7 (
	.clk(pclk),
	.n_rst(n_rst),
	.status(status),
	.interrupt(i2c_interrupt)
);

/*always_comb
begin
	if(transaction_begin) begin
		transaction = 1'b1;
	end else if(transaction & i2c_status[2]) begin
		transaction = 1'b0;
	end else if(transaction == 1'b0) begin
		transaction = 1'b0;
	end else begin
		transaction = 1'b0;
	end
end*/

always_comb
begin
	if(status_clear) begin
		mid_tx_empty = 1'b0;
	end else if(status[4] & ((status[6]) | (!status[10] & next_status[10]))) begin
		mid_tx_empty = 1'b1;
	end else begin
		mid_tx_empty = 1'b0;
	end
end

always_comb
begin
	if(status_clear) begin
		mid_rx_full = 1'b0;
	end else if(status[4] & ((status[5]) | (!status[8] & next_status[8]))) begin
		mid_rx_full = 1'b1;
	end else begin
		mid_rx_full = 1'b0;
	end
end

/*always_comb
begin
	if(status[10]) begin
		if(tx_empty) begin
			mid_tx_empty = 1'b1;
		end else begin
			mid_tx_empty = 1'b0;
		end
		if (rx_full) begin
			mid_rx_full = 1'b1;
		end else begin
			mid_rx_full = 1'b0;
		end
	end else begin
		mid_tx_empty = 1'b0;
		mid_rx_full = 1'b0;
	end
end*/

endmodule
