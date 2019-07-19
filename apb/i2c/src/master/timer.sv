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

`include "i2c.vh"
module timer(
	input 	logic clk,
		logic n_rst,
		logic timer_active,
		logic[31:0] clock_div,
		DataDirection direction,
		logic should_nack,
		logic SDA_sync,
		logic SCL_sync,
		logic SDA_out,		//value shift register attempts to drive
	output	logic SCL_out,		//Bus clock
		logic shift_strobe,	//Shift shift register
		logic byte_complete,	//Module has finished task
		logic ack_gen,		//If RX, generate ack bit on line
		logic ack,		//If TX, ack bit that was found on line
		logic abort		//Another master is using the bus
);
//Parameters
	localparam STANDARD_MODE_LOW = 	300;
	localparam STANDARD_MODE_HIGH =	300;
	localparam FAST_MODE_LOW =	90;
	localparam FAST_MODE_HIGH =	60;
	localparam FAST_PLUS_LOW =	36;
	localparam FAST_PLUS_HIGH =	24;

//Typedefs
typedef enum bit[4:0]{
	IDLE,		//Not doing anything
	INC_BIT,	//Increment bit counter, (index of bit being received/transmitted)
	CHK_BIT,	//Check the bit counter
	T_SHIFT,	//If transmitting, shift the shift register
	CLK_LOW,	//How SCL low for half cycle
	CLK_SYNC,	//Wait for SCL to go high (account for clock strech and perform clock sync)
	R_SHIFT,	//If receiving, shift the shift register
	ACK_R,		//Check the ack bit
	ACK_HIGH,	//make sure ack bit doesnt cause arbitration loss
	CLK_HIGH,	//Hold SCL high until timer expiers or it is pulled low by external device
	ABORT,		//Bus arbitration has been lost, abort transmission

	ACK_T_LOW,	//Hold SCL low during ACK transmission
	ACK_T_SYNC,	//Wait for SCL to go high during ACK transmission
	ACK_T_HIGH,	//Hold SCL high during ACk transmission

	NACK_T_LOW,	//Same as above, but for NACK transmission
	NACK_T_SYNC,
	NACK_T_HIGH,

	WAIT,
	DONE
} StateType;

//Local variables and signals
StateType next_state, state;
logic[3:0] current_bit;
logic chk_ack, timer_reset, inc_bit, half_cycle;
logic shift_strobe_next;


//Counter to count how many bits have gone by
//=====================================================================
flex_counter #(4) bit_counter(
	.clk(clk),
	.n_rst(n_rst),
	.clear(!timer_active),
	.count_enable(inc_bit),
	.rollover_val(4'd15),
	.count_out(current_bit)
);

//Counter to delay half a bus clock cycle
//====================================================================
flex_counter #(32) cycle_counter(
	.clk(clk),
	.n_rst(n_rst),
	.clear(timer_reset),
	.count_enable(timer_active),
	.rollover_val(clock_div),
	.rollover_flag(half_cycle)
);


//Ack check module
//=====================================================================
always_ff @(posedge clk, negedge n_rst) begin
	if(!n_rst)
		ack<=1;
	else if(chk_ack)
		ack<=SDA_sync;
	else
		ack<=ack;
end

//Timer next state logic
///====================================================================
always_comb begin
	//Default state doesn't change
	next_state = state;
	case(state)
		IDLE: next_state = INC_BIT;
		INC_BIT: next_state = CHK_BIT;
		CHK_BIT: begin
			if(current_bit==10)
				next_state=WAIT;
			else if(current_bit==9 && direction == RX)
				next_state = should_nack ? NACK_T_LOW : ACK_T_LOW;
			else if(current_bit==1 || direction == RX)
				next_state = CLK_LOW;
			else
				next_state = T_SHIFT;
		end
		T_SHIFT: next_state = CLK_LOW;
		CLK_LOW: next_state = half_cycle ? CLK_SYNC : CLK_LOW;
		CLK_SYNC: begin
			if(SCL_sync) begin
				if(direction==RX)
					next_state = R_SHIFT;
				else if(current_bit==9)
					next_state = ACK_R;
				else
					next_state = CLK_HIGH;
			end
		end
		R_SHIFT: next_state = CLK_HIGH;
		ACK_R: next_state = ACK_HIGH;
		CLK_HIGH: begin
			if(direction==TX && SDA_out && !SDA_sync)
				next_state = ABORT;
			else if(half_cycle | !SCL_sync)
				next_state = INC_BIT;
		end
		ACK_HIGH: if(half_cycle | !SCL_sync)
			next_state = INC_BIT;

		ACK_T_LOW: next_state = (half_cycle) ? ACK_T_SYNC : ACK_T_LOW;
		ACK_T_SYNC: next_state = (SCL_sync) ? ACK_T_HIGH : ACK_T_SYNC;
		ACK_T_HIGH: begin
			if(!SCL_sync | half_cycle)
				next_state = WAIT;
		end

		NACK_T_LOW: next_state = (half_cycle) ? NACK_T_SYNC : NACK_T_LOW;
		NACK_T_SYNC: next_state = (SCL_sync) ? NACK_T_HIGH : NACK_T_SYNC;
		NACK_T_HIGH: begin
			if(!SCL_sync | half_cycle)
				next_state = WAIT;
		end

		WAIT: next_state = half_cycle ? DONE : WAIT;
		
	endcase
	//Override, no timer_active will set to idle
	if(!timer_active)
		next_state=IDLE;
end

//Timer next state
//=====================================================================
always_ff @(posedge clk, negedge n_rst) begin
	if(!n_rst) begin
		state <=IDLE;
		shift_strobe <=0;
	end else begin
		state<=next_state;
		shift_strobe <= shift_strobe_next;
	end
end

//Timer output logic
//=====================================================================
always_comb begin
	//Default values
	abort=0;
	shift_strobe_next=0;
	SCL_out=0;
	byte_complete=0;
	chk_ack=0;
	inc_bit=0;
	ack_gen=0;
	timer_reset=1;
	
	case(state)
		IDLE:		;
		INC_BIT:	inc_bit=1;
		CHK_BIT:  	;
		T_SHIFT:  	shift_strobe_next=1;
		CLK_LOW:	timer_reset=0;
		R_SHIFT:	begin shift_strobe_next=1; SCL_out=1; end
		ACK_R:		begin chk_ack=1; SCL_out=1; end
		CLK_SYNC:	SCL_out=1;
		CLK_HIGH:	begin SCL_out=1; timer_reset=0; end
		ACK_HIGH:	begin SCL_out=1; timer_reset=0; end
		ABORT:		begin SCL_out=1; abort=1; end

		ACK_T_LOW:	begin ack_gen=1; timer_reset=0; end
		ACK_T_SYNC:	begin ack_gen=1; SCL_out=1; end
		ACK_T_HIGH:	begin ack_gen=1; SCL_out=1; timer_reset=0; end

		NACK_T_LOW:	begin timer_reset=0; end
		NACK_T_SYNC:	begin SCL_out=1; end
		NACK_T_HIGH:	begin SCL_out=1; timer_reset=0; end

		WAIT:		timer_reset=0;
		DONE:		byte_complete=1;
	endcase
end

endmodule
