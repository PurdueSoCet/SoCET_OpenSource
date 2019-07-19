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

// File name:   RCVfifo.sv
// Created:     6/16/2014
// Author:      Xin Tze Tee
// Version:     1.0  Initial Design Entry
// Description: FIFO for UART Receiver.

module RCVfifo
(
	input wire clk, n_rst,
	// inputs from UART Receiver
	input wire [7:0] rx_data,
	input wire data_ready,

	// inputs from APB Slave Interface
	input wire read_enable,

	// output to UART Receiver
	output reg data_read,

	// output to APB Slave Interface
	output reg [31:0] pDataRead,

	// output to Status Register
	output wire rcvEmpty,
	output wire rcvFull
);

reg [7:0] read_data;
reg next_data_read;

Fifo_wrapper FIFO
(
	.clk(clk), 
	.n_rst(n_rst),
	.wEnable(data_ready),
	.rEnable(read_enable),
	.wData(rx_data),
	.rData(read_data),
	.fifoEmpty(rcvEmpty),
	.fifoFull(rcvFull)
);

//Encoding for State Machine
parameter IDLE = 1'b0,
          LOAD = 1'b1;
reg state, nextstate;

// State Machine Register
always_ff @ (posedge clk, negedge n_rst) begin
	if(n_rst == 0) begin
		data_read <= 1'b0;
		state <= IDLE;
	end else begin
		data_read <= next_data_read;
		state <= nextstate;
	end
end

// Next State Logic
always_comb
begin
  case (state)
	IDLE: begin
		if (read_enable == 1) nextstate = LOAD;
		else nextstate = IDLE;
	end
	LOAD: begin
		nextstate = IDLE;
	end
	default: begin
		nextstate = IDLE;
	end
  endcase
end

// Output Logic
always_comb
begin
  pDataRead <= '0;
  if(n_rst == 0) begin
		pDataRead <= '0;
  end else begin
	case (state)
		IDLE: begin
			pDataRead <= '0;	
		end
		LOAD: begin
			pDataRead[7:0] <= read_data;	
		end
		default: begin
			pDataRead <= '0;		
		end
	endcase
  end //else block
end

always_comb
begin
	if (data_ready == 1)
		next_data_read = 1'b1;
	else next_data_read = data_read;
end
/*
fifo RX_FIFO (
	// input
	.r_clk(clk),
	.w_clk(clk),
	.n_rst(n_rst),
	.r_enable(read_enable),
	.w_enable(data_ready),
	.w_data(rx_data),
	// output
	.r_data(read_data),
	.empty(rcvEmpty),
	.full(rcvFull)
);

always_ff @ (posedge clk, negedge n_rst)
begin
	if(n_rst == 0) begin
		data_read <= 1'b0;
		pDataRead <= '0;
	end else begin
		data_read <= next_data_read;
		if (read_enable == 1)
			pDataRead[7:0] <= read_data;
		else pDataRead <= '0;
	end
end

always_comb
begin
	if (data_ready == 1)
		next_data_read = 1'b1;
	else next_data_read = data_read;
end
*/


endmodule
