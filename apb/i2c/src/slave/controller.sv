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

// Description: This is the module for the Main Controller

module controller
(
	input wire clk,
	input wire n_rst,
	input wire start,
	input wire stop,
	input wire [1:0] address_match,
	input wire rw_mode,
	input wire SDA_sync,
	input wire address_mode,	// 7 bit or 10 bit mode
	input wire TX_fifo_empty,
	input wire RX_fifo_full,
	input wire en_clock_strech,
	input wire RX_fifo_almost_full,
	input wire byte_received,
	input wire ack_prep,
	input wire ack_check,
	input wire ack_done,
	output reg rx_enable,
	output reg SCL_out_slave,
	output reg busy_slave,
	output reg TX_read_enable_slave,
	output reg RX_write_enable_slave,
	output reg ack_error_set_slave,
	output reg [1:0] sda_mode,
	output reg load_data,
	output reg tx_enable
);

	typedef enum logic [4:0] {IDLE, GET_ADDR_1, CHECK_ADDR_1, NO_MATCH, ACK_SEND_1, GET_ADDR_2, CHECK_ADDR_2, ACK_SEND_2, FIFO_CHK_TX, LOAD, DATA_START, DATA_STOP, ACK_CHECK, READ_ENABLE, RE_NACK, RE_ACK, FIFO_CHK_RX, SEND_1, SEND_ACK, SEND_NACK, SEND_2} state_type;
	state_type state, next_state;

	reg temp_rx_enable;
	reg temp_SCL_out_slave;
	reg temp_busy_slave;
	reg temp_TX_read_enable_slave;
	reg temp_RX_write_enable_slave;
	reg temp_ack_error_set_slave;
	reg [1:0] temp_sda_mode;
	reg temp_load_data;
	reg temp_tx_enable;

	always @(posedge clk, negedge n_rst)
	begin
		if (n_rst == 1'b0)
		begin
			state <= IDLE;
			rx_enable <= 1'b0;
			SCL_out_slave <= 1'b0;
			busy_slave <= 1'b0;
			TX_read_enable_slave <= 1'b0;
			RX_write_enable_slave <= 1'b0;
			ack_error_set_slave <= 1'b0;
			sda_mode <= 2'b00;
			load_data <= 1'b0;
			tx_enable <= 1'b0;
		end
		else
		begin
			state <= next_state;
			rx_enable <= temp_rx_enable;
			SCL_out_slave <= temp_SCL_out_slave;
			busy_slave <= temp_busy_slave;
			TX_read_enable_slave <= temp_TX_read_enable_slave;
			RX_write_enable_slave <= temp_RX_write_enable_slave;
			ack_error_set_slave <= temp_ack_error_set_slave;
			sda_mode <= temp_sda_mode;
			load_data <= temp_load_data;
			tx_enable <= temp_tx_enable;
		end
	end

	always @(state, start, stop, byte_received, ack_done, ack_check, ack_prep, address_match, SDA_sync)
	begin
		next_state = state;
		case (state)
			IDLE:
			begin 
				if(start == 1'b1) 
				begin
					next_state = GET_ADDR_1;
				end
			end
			
			GET_ADDR_1:
			begin 
				if(ack_prep == 1'b1) 
				begin
					next_state = CHECK_ADDR_1;
				end
			end

			CHECK_ADDR_1:
			begin 
				if(address_mode == 1'b0 && address_match[1] == 1'b1) 
				begin
					next_state = ACK_SEND_2;
				end
				else if(address_mode == 1'b1 && address_match[1] == 1'b1)
				begin 
					next_state = ACK_SEND_1;
				end
				else if(address_match[1] == 1'b0)
				begin 
					next_state = NO_MATCH;
				end
			end

			NO_MATCH:
			begin 
				if(ack_done == 1'b1) 
				begin
					next_state = IDLE;
				end
			end

			ACK_SEND_1:
			begin 
				if(ack_done == 1'b1) 
				begin
					next_state = GET_ADDR_2;
				end
			end

			GET_ADDR_2:
			begin 
				if(ack_prep == 1'b1) 
				begin
					next_state = CHECK_ADDR_2;
				end
			end

			CHECK_ADDR_2:
			begin 
				if(address_match[0] == 1'b1)
				begin 
					next_state = ACK_SEND_2;
				end
				else if(address_match[0] == 1'b0)
				begin 
					next_state = NO_MATCH;
				end
			end

			ACK_SEND_2:
			begin 
				if(rw_mode == 1'b1 && ack_done == 1'b1) 
				begin
					next_state = FIFO_CHK_TX;
				end
				else if(rw_mode == 1'b0 && ack_done == 1'b1) 
				begin
					next_state = FIFO_CHK_RX;
				end
			end

			FIFO_CHK_TX:
			begin 
				// THIS COULD BE WRONG SWITCHED && AND || IN IF AND ELSE IF CONDITIONS.
				if(en_clock_strech == 1'b1 || TX_fifo_empty == 1'b1) 
				begin
					next_state = FIFO_CHK_TX;
				end
				else if (en_clock_strech == 1'b0 && TX_fifo_empty == 1'b0)
				begin
					next_state = LOAD;
				end
			end

			LOAD:
			begin 
				next_state = DATA_START;
			end

			DATA_START:
			begin 
				if(ack_prep == 1'b1) 
				begin
					next_state = DATA_STOP;
				end
			end

			DATA_STOP:
			begin 
				if(ack_check == 1'b1) 
				begin
					next_state = ACK_CHECK;
				end
				else if(stop == 1'b1) 
				begin
					next_state = IDLE;
				end
			end

			ACK_CHECK:
			begin 
				if(SDA_sync == 1'b0) 
				begin
					next_state = READ_ENABLE;
				end
				else if(stop == 1'b1) 
				begin
					next_state = IDLE;
				end
				else if(SDA_sync == 1'b1) 
				begin
					next_state = RE_NACK;
				end
			end

			READ_ENABLE:
			begin
				if(stop == 1'b1) 
				begin
					next_state = IDLE;
				end
				else
				begin 
					next_state = RE_ACK;
				end 
			end

			RE_ACK:
			begin
				if(ack_done == 1'b1) begin
					next_state = FIFO_CHK_TX;
				end
				else if(stop == 1'b1) 
				begin
					next_state = IDLE;
				end
			end

			RE_NACK:
			begin
				if(stop == 1'b1) begin
					next_state = GET_ADDR_1;
				end
				else if(stop == 1'b0) 
				begin
					next_state = IDLE;
				end
			end

			FIFO_CHK_RX:
			begin 
				// THIS COULD BE WRONG MODIFIED THE IF AND ELSE IF CONDITIONS CHECK WITH ERIC ONCE.
				if(en_clock_strech == 1'b1) 
				begin
					next_state = FIFO_CHK_RX;
				end
				else
				begin
					next_state = SEND_1;
				end
			end

			SEND_1:
			begin 
				if(RX_fifo_almost_full == 1'b1 && ack_prep == 1'b1) 
				begin
					next_state = SEND_NACK;
				end
				else if(RX_fifo_almost_full == 1'b0 && ack_prep == 1'b1) 
				begin
					next_state = SEND_ACK;
				end
			end

			SEND_ACK:
			begin 
				next_state = SEND_2;
			end

			SEND_NACK:
			begin 
				next_state = SEND_2;
			end

			SEND_2:
			begin
				if(ack_done == 1'b1) begin
					next_state = FIFO_CHK_RX;
				end
				else if(stop == 1'b1) 
				begin
					next_state = IDLE;
				end
			end
		endcase
	end

	always @(state)
	begin
		temp_rx_enable = 1'b0;
		temp_SCL_out_slave = 1'b0;
		temp_busy_slave = 1'b0;
		temp_TX_read_enable_slave = 1'b0;
		temp_RX_write_enable_slave = 1'b0;
		temp_ack_error_set_slave = 1'b0;
		temp_sda_mode = 2'b00;
		temp_load_data = 1'b0;
		temp_tx_enable = 1'b0;

		case (state)
			IDLE:
			begin 
				temp_rx_enable = 1'b1;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b0;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end

			GET_ADDR_1:
			begin 
				temp_rx_enable = 1'b1;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end

			CHECK_ADDR_1:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end

			NO_MATCH:
			begin 
				temp_rx_enable = 1'b1;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b10;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			ACK_SEND_1:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b01;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			GET_ADDR_2:
			begin 
				temp_rx_enable = 1'b1;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			CHECK_ADDR_2:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			ACK_SEND_2:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b01;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			FIFO_CHK_TX:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			LOAD:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b01;
				temp_load_data = 1'b1;
				temp_tx_enable = 1'b0;
			end
			DATA_START:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b11;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b1;
			end
			DATA_STOP:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			ACK_CHECK:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			READ_ENABLE:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b1;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			RE_NACK:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b1;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			RE_ACK:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			FIFO_CHK_RX:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			SEND_1:
			begin 
				temp_rx_enable = 1'b1;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			SEND_ACK:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b01;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			SEND_NACK:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b10;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			SEND_2:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b1;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end

			default :
			begin
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b0;
				temp_busy_slave = 1'b0;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
		endcase
	end
endmodule 
