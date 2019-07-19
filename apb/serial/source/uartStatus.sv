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

// File name:   uartStatus.sv
// Created:     6/16/2014
// Author:      Xin Tze Tee
// Version:     1.0  
// Description: Status register for UART slave.

module uartStatus
(
	input wire clk, n_rst,
	// inputs from APB Slave Interface
	input wire stat_enable,
	input wire write_stat_enable,
	input wire [31:0] pWritedata,               // the last bit pWritedata[0] to clear error_flag

	// inputs from XMitfifo register
	input wire xmitEmpty,
	input wire xmitFull,

	// inputs from RCVfifo Register
	input wire rcvEmpty,
	input wire rcvFull,

	// inputs from UART Receiver
	input wire overrun_error,	
	input wire error_flag,

	// interrupt signals 
	input wire data_ready,
	input wire busy,

	// output to APB Slave Interface
	output reg [31:0] preaddata
);

reg error_flag_reg;
reg next_error_flag;

// error flag register (latches the error_flag until it is cleared)
always_ff @ (posedge clk, negedge n_rst)
begin
	if(n_rst == 0) begin
		error_flag_reg = 0;
	end else begin
		error_flag_reg = next_error_flag;
	end
end

always_comb
begin
	if (n_rst == 0) begin
		next_error_flag = 0;
	end else begin
		if (write_stat_enable == 1 && pWritedata[0] == 1)
			next_error_flag = 0;
		else if (error_flag == 1)
			next_error_flag = 1;
		else next_error_flag = error_flag_reg;
		
	end
end

// status register
always_ff @ (posedge clk, negedge n_rst)
begin
	if(n_rst == 0) begin
		preaddata <= '0;
	end else begin
		if (stat_enable == 1) begin
			preaddata[7:0] <= {busy, data_ready, rcvEmpty, rcvFull, xmitEmpty, xmitFull, overrun_error, error_flag_reg};
		//else preaddata <= '0;
		end
	end
end



endmodule
 
