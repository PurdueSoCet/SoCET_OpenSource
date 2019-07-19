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
// File name:   status_reg.sv
// Created:     4/21/2016
// Author:      Sam Sowell
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Status Register
module statusReg
(
	input reg [12:0] data_in,
	input wire clk, n_rst, clear,
	output reg [12:0] data_out
);
typedef enum logic [1:0] {IDLE, WAIT1, WAIT2, EXIT} state_type;
reg [12:0] next_data_out;
state_type next_state;
state_type curr_state;

always_ff @(posedge clk, negedge n_rst)
begin
	if(0 == n_rst) begin
		data_out <= '0;
		curr_state <= IDLE;
	end else begin
		data_out <= next_data_out;
		curr_state <= next_state;
	end
end

always_comb
begin
	next_data_out[1]     = data_in[1];
	next_data_out[4]     = data_in[4];
	next_data_out[8:7]   = data_in[8:7];
	next_data_out[11:10] = data_in[11:10];
	case(curr_state)
		IDLE: begin
			if(data_in[0] == 0) begin
				if(data_out[0]) begin
					next_data_out[0] = data_out[0];
				end else begin
					next_data_out[0] = data_in[0];
				end
			end else begin
				next_data_out[0] = 1'b1;
			end

			if(data_in[2] == 0) begin
				if(data_out[2]) begin
					next_data_out[2] = data_out[2];
				end else begin
					next_data_out[2] = data_in[2];
				end
			end else begin
				next_data_out[2] = 1'b1;
			end

			if(data_in[3] == 0) begin
				if(data_out[3]) begin
					next_data_out[3] = data_out[3];
				end else begin
					next_data_out[3] = data_in[3];
				end
			end else begin
				next_data_out[3] = 1'b1;
			end

			if(data_in[5] == 1'b0) begin
				if(next_data_out[5]) begin
					next_data_out[5] = data_out[5];
				end else begin
					next_data_out[5] = data_in[5];
				end
			end else begin
				next_data_out[5] = 1'b1;
			end

			if(data_in[6] == 1'b0) begin
				if(next_data_out[6]) begin
					next_data_out[6] = data_out[6];
				end else begin
					next_data_out[6] = data_in[6];
				end
			end else begin
				next_data_out[6] = 1'b1;
			end

			if(data_in[9] == 1'b0) begin
				if(next_data_out[9]) begin
					next_data_out[9] = data_out[9];
				end else begin
					next_data_out[9] = data_in[9];
				end
			end else begin
				next_data_out[9] = 1'b1;
			end

			if(data_in[12] == 1'b0) begin
				if(next_data_out[12]) begin
					next_data_out[12] = data_out[12];
				end else begin
					next_data_out[12] = data_in[12];
				end
			end else begin
				next_data_out[12] = 1'b1;
			end

			if(clear) begin
				next_state = WAIT1;
			end else begin
				next_state = curr_state;
			end
		end
		WAIT1: begin
			next_data_out[0]   = data_out[0];
			next_data_out[3:2] = data_out[3:2];
			next_data_out[6:5] = data_out[6:5];
			next_data_out[9]   = data_out[9];
			next_data_out[12]  = data_out[12];
			next_state = WAIT2;
		end
		WAIT2: begin
			next_data_out[0]   = data_out[0];
			next_data_out[3:2] = data_out[3:2];
			next_data_out[6:5] = data_out[6:5];
			next_data_out[9]   = data_out[9];
			next_data_out[12]  = data_out[12];
			next_state = EXIT;
		end
		EXIT: begin
			next_state = IDLE;
			next_data_out[0]   = 1'b0;
			next_data_out[3:2] = 2'b00;
			next_data_out[6:5] = 2'b0;;
			next_data_out[9]   = 1'b0;
			next_data_out[12]  = 1'b0;
			//next_data_out = {data_out[12:4],2'b00,data_out[1],1'b0};
		end
	endcase
end
endmodule
