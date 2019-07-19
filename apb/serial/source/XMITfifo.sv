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

// File name:   XMITfifo.sv
// Created:     6/16/2014
// Author:      Xin Tze Tee
// Version:     1.0  
// Description: FIFO for UART Transmitter.

module XMITfifo
(
	input wire clk, n_rst,
	// input from UART Transmitter
	input wire busy,

	// inputs from APB Slave Interface
	input wire write_enable,
	input wire [31:0] pDataWrite,

	// output to UART Transmitter
	output reg [7:0] data_in,
	output reg tx_enable,

	// output to Status register
	output wire xmitEmpty,
	output wire xmitFull
);


reg read_enable;
reg [7:0] read_data;


Fifo_wrapper FIFO
(
	.clk(clk), 
	.n_rst(n_rst),
	.wEnable(write_enable),
	.rEnable(read_enable),
	.wData(pDataWrite[7:0]),
	.rData(read_data),
	.fifoEmpty(xmitEmpty),
	.fifoFull(xmitFull)
);

//Encoding for State Machine
parameter [1:0] IDLE = 2'b00,
                ENABLE = 2'b01,
                LOAD = 2'b10;
reg [1:0] state, nextstate;

// State Machine Register
always_ff @(posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		state <= IDLE;
	end else begin
		state <= nextstate;
	end
end

// Next State Logic
always_comb
begin
  case (state)
	IDLE: begin
		if (busy == 0 && xmitEmpty == 0) nextstate = ENABLE;
		else nextstate = IDLE;
	end
	ENABLE: begin
		nextstate = LOAD;
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
  if(n_rst == 0) begin
	read_enable = 1'b0;
	tx_enable = 1'b0;		
	data_in = '1;
  end else begin
	case (state)
		IDLE: begin
			read_enable = 1'b0;
			tx_enable = 1'b0;		
			data_in = '1;	
		end
		ENABLE: begin
			read_enable = 1'b1;
			tx_enable = 1'b0;		
			data_in = '1;	
		end
		LOAD: begin
			read_enable = 1'b0;
			tx_enable = 1'b1;		
			data_in = read_data;	
		end
		default: begin
			read_enable = 1'b0;
			tx_enable = 1'b0;		
			data_in = '1;	
		end
	endcase
  end //else block
end

endmodule
