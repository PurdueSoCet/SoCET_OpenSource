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
`include "i2c_master_const.vh"
module master_controller(
	input 	clk,
		n_rst,
		address_mode,
		ms_select,
		bus_busy,
		begin_transaction_flag,
		ack_bit,
		data_direction,
		output_wait_expired,
		byte_complete,
		zero_bytes_left,
		abort,
		stretch_enabled,
		rx_fifo_full,
		tx_fifo_empty,
	output	ShiftSelectType shift_input_select,
		DriveSelectType output_select,
		DataDirection shift_direction,
		logic shift_load,
		logic timer_active,
		logic load_buffers,
		logic decrement_byte_counter,
		logic set_ack_error,
		logic set_arbitration_lost,
		logic clear_transaction_begin,
		logic start,
		logic stop,
		logic tx_fifo_enable,
		logic rx_fifo_enable,
		logic busy,
		logic set_transaction_complete
);

//Define States
//=====================================================================
typedef enum bit [4:0]{
	IDLE,			//Default do nothing state
	FLAG_CLEAR,		//Clear transaction begin flag
	LOAD_BUFFER,		//Load control signal buffer and byte counter
	SEND_START,		//Send start condition
	LOAD_7ADDR,		//load 7 bit address into shift register
	SEND_7ADDR,		//send 7 bit address
	LOAD_10ADDR1,		//Load 1st byte of 10 bit address
	SEND_10ADDR1,		//send 1st byte of 10 bit address
	LOAD_10ADDR2,		//load 2nd byte of 10 bit address
	SEND_10ADDR2,		//Send 2nd byte of 10 bit address
	CHK_ADD_ACK1,		//Check ack bit of 1st byte of address
	CHK_ADD_ACK2,		//Check ack bit of 2nd byte of address
	CHK_BYTE_COUNT,		//Check to see if byte counter is zero
	DEC_BYTE_COUNT,		//Decrement the byte counter
	STRETCH,		//Stretch clock if necessary and enabled
	LOAD_BYTE,		//Load a byte from the tx fifo
	TRANSMIT,		//transmit byte
	RECEIVE,		//receive byte
	CHK_T_ACK,		//check ack bit received
	SAVE_BYTE,		//save byte received to rx fifo
	SET_ERROR,		//set ack error flag and transaction_complete
	SET_ABORT,		//set arbitration lost error flag and transaction_complete
	SET_COMPLETE,		//set transaction_complete after stop condition
	SR_SET_COMPLETE,	//set transaction_complete before repeated start
	SEND_STOP		//send stop condition
	
}	StateType;

//Local variables
//===========================================================================
StateType state, next_state;

//Next state logic
//============================================================================
always_comb begin
	next_state = state;	//Default action, do not change state
	case (state)
		IDLE: if(begin_transaction_flag && !bus_busy) next_state = FLAG_CLEAR;
		FLAG_CLEAR: next_state = LOAD_BUFFER;
		LOAD_BUFFER: next_state = SEND_START;
		SEND_START: if (output_wait_expired) begin
			if(address_mode == ADDR_7_BIT)
				next_state = LOAD_7ADDR;
			else
				next_state = LOAD_10ADDR1;
		end

		LOAD_7ADDR: next_state = SEND_7ADDR;
		LOAD_10ADDR1: next_state = SEND_10ADDR1;
		LOAD_10ADDR2: next_state = SEND_10ADDR2;

		SEND_7ADDR: begin
			if(abort)
				next_state = SET_ABORT;
			if(byte_complete)
				next_state = CHK_ADD_ACK2;
		end

		SEND_10ADDR1: begin
			if(abort)
				next_state = SET_ABORT;
			if(byte_complete)
				next_state = CHK_ADD_ACK1;
		end

		SEND_10ADDR2: begin
			if(abort)
				next_state = SET_ABORT;
			if(byte_complete)
				next_state = CHK_ADD_ACK2;
		end

		CHK_ADD_ACK1: next_state = !ack_bit ? LOAD_10ADDR2 : SET_ERROR;
		CHK_ADD_ACK2: next_state = !ack_bit ? CHK_BYTE_COUNT : SET_ERROR;
		CHK_BYTE_COUNT: begin
			if(zero_bytes_left)
				next_state = begin_transaction_flag ? SR_SET_COMPLETE : SEND_STOP;
			else
				next_state = DEC_BYTE_COUNT;
		end
		SET_COMPLETE: next_state = IDLE;
		SR_SET_COMPLETE: next_state = FLAG_CLEAR;
		DEC_BYTE_COUNT: next_state = STRETCH;
		STRETCH: begin
			if (data_direction==RX) begin
				if(rx_fifo_full && stretch_enabled)
					next_state = STRETCH;
				else if(rx_fifo_full)
					next_state = SEND_STOP;
				else
					next_state = RECEIVE;
			end else begin
				if(tx_fifo_empty && stretch_enabled)
					next_state = STRETCH;
				else if(tx_fifo_empty)
					next_state = SEND_STOP;
				else
					next_state = LOAD_BYTE;
			end
		end
		
		//receive byte logic
		RECEIVE: next_state = byte_complete ? SAVE_BYTE : RECEIVE;
		SAVE_BYTE: next_state = CHK_BYTE_COUNT;

		//transmit byte logic
		LOAD_BYTE: next_state = TRANSMIT;
		TRANSMIT: begin
			if(abort)
				next_state = SET_ABORT;
			else
				next_state = byte_complete ? CHK_T_ACK : TRANSMIT;
		end
		CHK_T_ACK: next_state = (ack_bit == 0) ? CHK_BYTE_COUNT : SET_ERROR;
		SET_ERROR: begin
			if(begin_transaction_flag)
				next_state = SR_SET_COMPLETE;
			else
				next_state = SEND_STOP;
		end
		SET_ABORT: next_state = SET_COMPLETE;
		SEND_STOP: next_state = output_wait_expired ? SET_COMPLETE : SEND_STOP;
		
	endcase
end

//State register
//=====================================================================
always_ff @(posedge clk, negedge n_rst) begin
	if(!n_rst)
		state <= IDLE;
	else
		state <= next_state;
end

//Output logic
//=====================================================================
always_comb begin
	//default output values
	shift_input_select =		SS_TX_FIFO;
	output_select =			DS_RECEIVE;
	shift_direction =		RX;
	shift_load = 			0;
	timer_active =			0;
	load_buffers =			0;
	decrement_byte_counter =	0;
	set_ack_error =			0;
	set_arbitration_lost =		0;
	clear_transaction_begin =	0;
	stop =				0;
	start =				0;
	busy =				1;
	set_transaction_complete=	0;
	tx_fifo_enable=			0;
	rx_fifo_enable=			0;
	
	//State specific non-default values
	case(state)
		IDLE:		begin busy=0; output_select=DS_IDLE; end
		FLAG_CLEAR:	begin clear_transaction_begin=1; output_select=DS_IDLE; end
		LOAD_BUFFER:	begin load_buffers=1; output_select=DS_IDLE; end
		SEND_START:	begin output_select=DS_START_STOP; start=1; end
		SEND_STOP:	begin output_select=DS_START_STOP; stop=1; end

		LOAD_7ADDR:	begin shift_input_select=SS_7_BIT_ADDRESS; shift_load=1; end
		LOAD_10ADDR1:	begin shift_input_select=SS_10_BIT_ADDRESS_BYTE_1; shift_load=1; end
		LOAD_10ADDR2:	begin shift_input_select=SS_10_BIT_ADDRESS_BYTE_2; shift_load=1; end
		LOAD_BYTE:	begin shift_input_select=SS_TX_FIFO; shift_load=1; tx_fifo_enable=1; end

		SEND_7ADDR:	begin timer_active=1; shift_direction=TX; output_select = DS_TRANSMIT; end
		SEND_10ADDR1:	begin timer_active=1; shift_direction=TX; output_select = DS_TRANSMIT; end
		SEND_10ADDR2:	begin timer_active=1; shift_direction=TX; output_select = DS_TRANSMIT; end
		TRANSMIT:	begin timer_active=1; shift_direction=TX; output_select = DS_TRANSMIT; end

		//CHK_ADD_ACK1:
		//CHK_ADD_ACK2:
		//CHK_T_ACK:
		//CHK_BYTE_COUNT:
		//STRETCH:

		DEC_BYTE_COUNT:	begin decrement_byte_counter=1; end

		RECEIVE:	begin timer_active=1; shift_direction=RX; end
		SAVE_BYTE:	begin rx_fifo_enable=1; end

		SET_ERROR:	begin set_ack_error=1; end
		SET_ABORT:	begin set_arbitration_lost=1; end
		SET_COMPLETE: 	begin set_transaction_complete=1; output_select=DS_IDLE;end
		SR_SET_COMPLETE:begin set_transaction_complete=1; end
	endcase
end

endmodule
