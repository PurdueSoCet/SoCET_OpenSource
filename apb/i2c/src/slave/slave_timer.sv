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

// Description: This is the module for the Timer.

module slave_timer
(
	input wire clk,
	input wire n_rst,
	input wire start, // Start flag
	input wire stop, // Stop flag
	input wire rising_edge,
	input wire falling_edge,
	output reg byte_received,
	output reg ack_prep, // 8th clock cycle falling edge found flag
	output reg ack_check, // 9th clock cycle rising edge found flag
	output reg ack_done // 9th clock cycle falling edge found flag
);
	//STATE MACHINE
	//IDLE: Idle State
	//START: Start found, now waiting to read data 1st bit
	//READ_1: Read data 1st bit, now waiting to read data 2nd bit
	//.
	//.
	//READ_8: Read data 8th bit, now waiting to read/write data 9th bit i.e. ACK / NACK
	//PREP: Start preparing for ACK/NACK
	//CHECK: Check if ACK/NACK
	//DONE: Done with 9 pulses of SCL
	typedef enum logic [3:0] {IDLE, START, READ_1, READ_2, READ_3, READ_4, READ_5, READ_6, READ_7, READ_8, PREP, CHECK, DONE} state_type;
	state_type state, next_state;

	reg temp_byte_received; 
	reg temp_ack_prep; 
	reg temp_ack_check; 
	reg temp_ack_done; 

	always @(posedge clk, negedge n_rst)
	begin
		if(n_rst == 1'b0)
		begin
			state <= IDLE;
			byte_received <= 1'b0;
			ack_prep <= 1'b0;
			ack_check <= 1'b0;
			ack_done <= 1'b0;
			end
		else
		begin
			state <= next_state;
			byte_received <= temp_byte_received;
			ack_prep <= temp_ack_prep;
			ack_check <= temp_ack_check;
			ack_done <= temp_ack_done;
		end
	end

	always @(state, start, stop, rising_edge, falling_edge)
	begin
		next_state = state;
		case (state)
			IDLE:
			begin
					if(start == 1'b1) 
					begin
						next_state = START;
					end
			end

			START:
			begin
					if(rising_edge == 1'b1) 
					begin
						next_state = READ_1;
					end
			end

			READ_1:
			begin
					if(start == 1'b1) 
					begin
						next_state = START;
					end
					else if(rising_edge == 1'b1) 
					begin
						next_state = READ_2;
					end
			end

			READ_2:
			begin
					if(rising_edge == 1'b1) 
					begin
						next_state = READ_3;
					end
			end

			READ_3:
			begin
					if(rising_edge == 1'b1) 
					begin
						next_state = READ_4;
					end
			end

			READ_4:
			begin
					if(rising_edge == 1'b1) 
					begin
						next_state = READ_5;
					end
			end

			READ_5:
			begin
					if(rising_edge == 1'b1) 
					begin
						next_state = READ_6;
					end
			end

			READ_6:
			begin
					if(rising_edge == 1'b1) 
					begin
						next_state = READ_7;
					end
			end

			READ_7:
			begin
					if(rising_edge == 1'b1) 
					begin
						next_state = READ_8;
					end
			end

			READ_8:
			begin
					if(falling_edge == 1'b1) 
					begin
						next_state = PREP;
					end
			end

			PREP:
			begin
					if(rising_edge == 1'b1) 
					begin
						next_state = CHECK;
					end
			end

			CHECK:
			begin
					if(falling_edge == 1'b1) 
					begin
						next_state = DONE;
					end
			end

			DONE:
			begin
					if(stop == 1'b1) 
					begin
						next_state = IDLE;
					end
					else if(start == 1'b1) 
					begin
						next_state = START;
					end
					else if(rising_edge == 1'b1) 
					begin
						next_state = READ_1;
					end
			end
		endcase
	end

	always @(state) //Output Logic Block
	begin
		temp_byte_received = 1'b0;
		temp_ack_prep = 1'b0;
		temp_ack_check = 1'b0;
		temp_ack_done = 1'b0;
		case (state)
			PREP:
			begin 
				temp_byte_received = 1'b1;
				temp_ack_prep = 1'b1;
			end

			CHECK:
			begin 
				temp_byte_received = 1'b1;
				temp_ack_check = 1'b1;
			end

			DONE:
			begin 
				temp_ack_done = 1'b1;
			end
			default :
			begin 
				temp_byte_received = 1'b0;
				temp_ack_prep = 1'b0;
				temp_ack_check = 1'b0;
				temp_ack_done = 1'b0;
			end
		endcase
	end
endmodule 
