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

// File name:   SerialSlave.sv
// Updated:     03/01/2016
// Author:      Xin Tze Tee and Travis Garza
// Version:     2.0 
// Description: Serial Port APB Slave Unit (wrapper)


module SerialSlave
(
	input wire clk, n_rst,
	input wire [31:0] PADDR,				// input from APB Bridge
	input wire [31:0] PWDATA,
	input wire PWRITE,
	input wire PENABLE,
	input wire PSEL,	
	input wire serial_in,					// input from outside source
	output reg data_out,					// output to outside source 		
	output wire [31:0] PRDATA,				// output to APB Bridge
	output wire pslverr
);

// APB_SlaveInterface outputs
wire [1:8][31:0] read_data;
wire [7:0] Enable;

// XMITfifo outputs
wire busy;
reg [7:0] data_in;
reg tx_enable;
wire xmitEmpty;
wire xmitFull;

// RCVfifo outputs
reg data_read;
wire rcvEmpty;
wire rcvFull;
reg [31:0] pDataRead;

// uartStatus outputs
reg [31:0] preaddata;

// rcv_block outputs
reg [7:0] rx_data;
reg data_ready;
reg overrun_error;
reg error_flag;

// baudRate outputs
reg [31:0] baudData;

assign read_data[1] = {24'b0, data_in};
assign read_data[2] = pDataRead;
assign read_data[3] = preaddata;


APB_SlaveInterface APB_SlaveInterface
(
	.clk(clk), .n_rst(n_rst),
	.PADDR(PADDR),
	.PENABLE(PENABLE),
	.PWRITE(PWRITE),
	.PSEL(PSEL),
	.read_data(read_data),
	.Enable(Enable),
	.PRDATA(PRDATA),
	.pslverr(pslverr)
);

XMITfifo XMITfifo
(
	.clk(clk), .n_rst(n_rst),
	.busy(busy),						// input from UART Transmitter	
	.write_enable(Enable[0]),		// inputs from APB Slave Interface
	.pDataWrite(PWDATA),
	.data_in(data_in),					// output to UART Transmitter
	.tx_enable(tx_enable),
	.xmitEmpty(xmitEmpty),				// output to Status register
	.xmitFull(xmitFull)
);

RCVfifo RCVfifo
(
	.clk(clk), .n_rst(n_rst),
	.rx_data(rx_data),					// inputs from UART Receiver
	.data_ready(data_ready),
	.read_enable(Enable[1]),			// inputs from APB Slave Interface
	.data_read(data_read),				// output to UART Receiver
	.pDataRead(pDataRead),				// output to APB Slave Interface
	.rcvEmpty(rcvEmpty),				// output to Status Register
	.rcvFull(rcvFull)
);

uartStatus uartStatus
(
	.clk(clk), .n_rst(n_rst),
	.stat_enable(Enable[2]),			// inputs from APB Slave Interface
	.write_stat_enable(Enable[2] && PWRITE),
	.pWritedata(PWDATA), 
	.xmitEmpty(xmitEmpty),				// inputs from XMitfifo register
	.xmitFull(xmitFull),
	.rcvEmpty(rcvEmpty),				// inputs from RCVfifo Register
	.rcvFull(rcvFull),	
	.overrun_error(overrun_error),		// inputs from UART Receiver	
	.error_flag(error_flag),	
	.data_ready(data_ready),				// interrupt signal
	.busy(busy),
	.preaddata(preaddata)				// output to APB Slave Interface
);

rcv_block rcv_block
(
   .clk, .n_rst(n_rst),
   .serial_in(serial_in),
   .data_read(data_read),
   .baudData(baudData),
   .rx_data(rx_data),
   .data_ready(data_ready),
   .overrun_error(overrun_error),
   .error_flag(error_flag)
);

transmitter transmitter
(	
	.clk(clk), .n_rst(n_rst), 
	.baudData(baudData),
	.data_in(data_in), 					// data packet to be transmitted
	.tx_enable(tx_enable),				// enable signal
	.data_out(data_out), 				// data bit that is shifted out
	.busy(busy)
);

baudRate baudRate
(
	.clk(clk), .n_rst(n_rst),
	.baud_enable(Enable[3]),			//Enable signal from the APB interface
	.pWritedata(PWDATA), 
	.baudData_reg(baudData)
);

endmodule
