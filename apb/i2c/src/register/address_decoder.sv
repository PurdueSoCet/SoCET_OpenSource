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
// File name:   address_decoder.sv
// Created:     4/25/2016
// Author:      Sam Sowell
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Address Decoder Block
module address_decoder(
	input wire pclk,
	input wire n_rst,
	input wire [31:0] paddr,
	input wire penable,
	input wire psel,
	input wire pwrite,
	output reg tx_w_ena,
	output reg cr_w_ena,
  output reg cr_r_ena,
	output reg addr_ena,
	output reg [1:0] rx_r_ena,
	output reg clk_div_ena,
	//output reg transaction_begin
	output reg status_clear
	);

typedef enum logic [3:0] {IDLE, WAIT, RX_WAIT, RX_IDLE, EIDLE, TX, CONTROL_W, CONTROL_R, ADDR, RX, STATUS, CLK_DIV} state_type;
state_type curr_state;
state_type next_state;

always_ff @(posedge pclk, negedge n_rst)
begin
	if(n_rst == 0) begin
		curr_state <= IDLE;
	end else begin
		curr_state <= next_state;
	end
end

always_comb
begin
	//if(penable) begin
		//if(psel) begin
			case(curr_state)
				IDLE: begin
					tx_w_ena    = 1'b0;
					cr_r_ena      = 1'b0;
					cr_w_ena      = 1'b0;
					addr_ena    = 1'b0;
					rx_r_ena    = 2'b00;
					clk_div_ena = 1'b0;
					//transaction_begin = 1'b0;
					status_clear = 1'b0;
					if(psel) begin
						if(paddr[5:0] == 6'd0) begin
							next_state = TX;
						end else if (paddr[5:0] == 6'd4) begin
              if (pwrite)
							  next_state = CONTROL_W;
              else
                next_state = CONTROL_R;
						end else if (paddr[5:0] == 6'd8) begin
							next_state = ADDR;
						end else if (paddr[5:0] == 6'd12) begin
							next_state = RX;
						end else if (paddr[5:0] == 6'd16) begin
							next_state = STATUS;
						end else if (paddr[5:0] == 6'd20) begin
							next_state = CLK_DIV;
						end else begin
							next_state = EIDLE;
						end
					end else begin
						next_state = curr_state;
					end
				end
				TX: begin
					cr_r_ena      = 1'b0;
          cr_w_ena    = 1'b0;
					addr_ena    = 1'b0;
					rx_r_ena    = 2'b00;
					clk_div_ena = 1'b0;
					tx_w_ena    = 1'b1;
					status_clear = 1'b0;
					//transaction_begin = 1'b1;
					next_state  = IDLE;
				end
				CONTROL_W: begin
					tx_w_ena    = 1'b0;
					addr_ena    = 1'b0;
					rx_r_ena    = 2'b00;
					clk_div_ena = 1'b0;
					cr_w_ena      = 1'b1;
          cr_r_ena    = 1'b0;
					status_clear = 1'b0;
					//transaction_begin = 1'b1;
					next_state  = IDLE;
				end
				CONTROL_R: begin
					tx_w_ena    = 1'b0;
					addr_ena    = 1'b0;
					rx_r_ena    = 2'b00;
					clk_div_ena = 1'b0;
					cr_r_ena      = 1'b1;
          cr_w_ena = 1'b0;
					status_clear = 1'b0;
					//transaction_begin = 1'b1;
					next_state  = IDLE;
				end
				ADDR: begin
				    tx_w_ena    = 1'b0;
					cr_r_ena      = 1'b0;
          cr_w_ena    = 1'b0;
					rx_r_ena    = 2'b00;
					clk_div_ena = 1'b0;
					addr_ena    = 1'b1;
					status_clear = 1'b0;
					//transaction_begin = 1'b1;
					next_state  = IDLE;
				end
				RX: begin
					tx_w_ena    = 1'b0;
					cr_r_ena      = 1'b0;
          cr_w_ena    = 1'b0;
					addr_ena    = 1'b0;
					clk_div_ena = 1'b0;
					rx_r_ena    = 2'b11;
					status_clear = 1'b0;
					//transaction_begin = 1'b1;
					next_state  = RX_IDLE;
				end
				STATUS: begin
					tx_w_ena    = 1'b0;
					cr_r_ena      = 1'b0;
          cr_w_ena    = 1'b0;
					addr_ena    = 1'b0;
					clk_div_ena = 1'b0;
					rx_r_ena    = 2'b00;
					status_clear = 1'b1;
					//transaction_begin = 1'b1;
					next_state  = IDLE;
				end
				CLK_DIV: begin
					tx_w_ena    = 1'b0;
					cr_r_ena      = 1'b0;
          cr_w_ena    = 1'b0;
					addr_ena    = 1'b0;
					rx_r_ena    = 2'b00;
					clk_div_ena = 1'b1;
					status_clear = 1'b0;
					//transaction_begin = 1'b1;
					next_state  = IDLE;
				end
				WAIT: begin
					tx_w_ena    = 1'b0;
					cr_r_ena      = 1'b0;
          cr_w_ena    = 1'b0;
					addr_ena    = 1'b0;
					rx_r_ena    = 2'b00;
					clk_div_ena = 1'b0;
					status_clear = 1'b0;
					//transaction_begin = 1'b0;
					if(penable == 0) begin
						next_state = IDLE;
					end else begin
						next_state = curr_state;
					end
				end
				RX_WAIT: begin
					tx_w_ena    = 1'b0;
					cr_r_ena      = 1'b0;
          cr_w_ena    = 1'b0;
					addr_ena    = 1'b0;
					clk_div_ena = 1'b0;
					//transaction_begin = 1'b1;
					rx_r_ena    = 2'b10;
					status_clear = 1'b0;
					if(penable == 0) begin
						next_state  = RX_IDLE;
					end else begin
						next_state = curr_state;
					end
				end
				RX_IDLE: begin
					tx_w_ena    = 1'b0;
					cr_r_ena      = 1'b0;
          cr_w_ena    = 1'b0;
					addr_ena    = 1'b0;
					rx_r_ena    = 2'b10;
					clk_div_ena = 1'b0;
					status_clear = 1'b0;
					//transaction_begin = 1'b0;
					if(psel) begin
						if(paddr[5:0] == 6'd0) begin
							next_state = TX;
						end else if (paddr[5:0] == 6'd4) begin
              if (pwrite)
							  next_state = CONTROL_W;
              else
                next_state = CONTROL_R;
						end else if (paddr[5:0] == 6'd8) begin
							next_state = ADDR;
						end else if (paddr[5:0] == 6'd12) begin
							next_state = RX;
						end else if (paddr[5:0] == 6'd16) begin
							next_state = STATUS;
						end else if (paddr[5:0] == 6'd20) begin
							next_state = CLK_DIV;
						end else begin
							next_state = EIDLE;
						end
					end else begin
						next_state = curr_state;
					end
				end
				EIDLE: begin
					tx_w_ena    = 1'b0;
					cr_r_ena      = 1'b0;
          cr_w_ena    = 1'b0;
					addr_ena    = 1'b0;
					rx_r_ena    = 2'b00;
					clk_div_ena = 1'b0;
					status_clear = 1'b0;
					//transaction_begin = 1'b0;
					if(penable == 0) begin
						next_state = IDLE;
					end else begin
						next_state = EIDLE;
					end
				end
				default: begin
					tx_w_ena = 1'b0;
					cr_r_ena      = 1'b0;
          cr_w_ena    = 1'b0;
					addr_ena = 1'b0;
					clk_div_ena = 1'b0;
					rx_r_ena = 2'b00;
					status_clear = 1'b0;
					next_state = IDLE;
					//transaction_begin = 1'b0;
				end
			endcase
		/*end else begin
			tx_w_ena    = 1'b0;
			cr_ena      = 1'b0;
			addr_ena    = 1'b0;
			rx_r_ena    = 2'b00;
			clk_div_ena = 1'b0;
			next_state  = curr_state;
		end*/
	/*end else begin
		tx_w_ena    = 1'b0;
		cr_ena      = 1'b0;
		addr_ena    = 1'b0;
		rx_r_ena    = 2'b00;
		clk_div_ena = 1'b0;
		next_state  = curr_state;
	end*/
end
endmodule
