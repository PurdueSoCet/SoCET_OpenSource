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

// Description: This is the module for the Main Slave Controller.

module slave_controller
(
	input wire clk,
	input wire n_rst,
	input wire start,
	input wire stop,
	input wire [1:0] address_match,
	input wire rw_mode,
	input wire SDA_sync,
	input wire address_mode,	// 7 bit or 10 bit mode
	input wire TX_fifo_empty,	// TX FIFO Empty
	input wire RX_fifo_full,	// RX FIFO Full
	input wire en_clock_strech,	// Clock Strech Enabled 
	input wire RX_fifo_almost_full, // RX FIFO Almost Full
	input wire byte_received,	// 1 Byte Data Received
	input wire ack_prep,		// ACK Prep Flag
	input wire ack_check,		// ACK Check Flag
	input wire ack_done,		// ACK Done Flag
	output reg rx_enable,		// Receive enable
	output reg SCL_out_slave,	// SCL Out
	output reg busy_slave,		// Slave Busy Flag
	output reg TX_read_enable_slave, // Increment FIFO Pointer Flag
	output reg RX_write_enable_slave, // Increment FIFO Pointer Flag
	output reg ack_error_set_slave, // ACK Error Flag
	output reg [1:0] sda_mode,	// MUX Enabler
	output reg load_data,		// Data Load Flag
	output reg tx_enable,		// Read Enabler Flag
	output reg rw_store		// Read Write Store Enabler Flag
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
			SCL_out_slave <= 1'b1;
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
	//STATE MACHINE
	//Look at the RTL for better understanding
	always @(state, start, stop, byte_received, ack_done, ack_check, ack_prep, address_match, SDA_sync,en_clock_strech)
	begin
		next_state = state;
		case (state)
			IDLE:
			begin 
				if(start == 1'b1) 
				begin
					next_state = GET_ADDR_1; // Start Found
				end
			end
			
			GET_ADDR_1:
			begin 
				if(ack_prep == 1'b1) // Wait for falling edge of 8th pulse of SCL
				begin
					next_state = CHECK_ADDR_1;
				end
			end

			CHECK_ADDR_1:
			begin 
				if(address_mode == 1'b0 && address_match[1] == 1'b1) // Check 7 Bit mode and Address match 
				begin
					next_state = ACK_SEND_2;
				end
				else if(address_mode == 1'b1 && address_match[1] == 1'b1) // Check 10 Bit mode and Address match
				begin 
					next_state = ACK_SEND_1;
				end
				else if(address_match[1] == 1'b0) // Address not match
				begin 
					next_state = NO_MATCH;
				end
			end

			NO_MATCH:	//NACK send
			begin 
				if(ack_done == 1'b1) // Wait until 9th clock cycle completed (clock = SCL)
				begin
					next_state = IDLE;
				end
			end

			ACK_SEND_1:	//ACK send
			begin 
				if(ack_done == 1'b1) //Hold line low for ack until 9th clock cycle completed (clock = SCL)
				begin
					next_state = GET_ADDR_2;
				end
			end

			GET_ADDR_2: // In 10 Bit mode, get 2nd byte of Address
			begin 
				if(ack_prep == 1'b1) //Wait until address is sent out for matching
				begin
					next_state = CHECK_ADDR_2;
				end
			end

			CHECK_ADDR_2:
			begin 
				if(address_match[0] == 1'b1) //Check address match
				begin 
					next_state = ACK_SEND_2; // ACK send
				end
				else if(address_match[0] == 1'b0)
				begin 
					next_state = NO_MATCH; // NACK send
				end
			end

			ACK_SEND_2:
			begin 
				if(rw_mode == 1'b1 && ack_done == 1'b1) // post 9the pulse of SCL, check whether reading or writing on SDA
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
				if(en_clock_strech == 1'b1 || TX_fifo_empty == 1'b1) // Hold SCL low for clock streching
				begin
					next_state = FIFO_CHK_TX;
				end
				else if (en_clock_strech == 1'b0 && TX_fifo_empty == 1'b0) // Begin Loading data
				begin
					next_state = LOAD;
				end
			end

			LOAD:
			begin 
				next_state = DATA_START; // Wait State 
			end

			DATA_START:
			begin 
				if(ack_prep == 1'b1) // Wait until data is ready
				begin
					next_state = DATA_STOP;
				end
			end

			DATA_STOP:
			begin 
				if(ack_check == 1'b1) // Wait to check for ACK
				begin
					next_state = ACK_CHECK;
				end
				else if(stop == 1'b1) // Terminate I2C
				begin
					next_state = IDLE;
				end
			end

			ACK_CHECK:
			begin 
				if(SDA_sync == 1'b0) // ACK received
				begin
					next_state = READ_ENABLE; // Read data from FIFO
				end
				else if(stop == 1'b1) // Terminate I2C
				begin
					next_state = IDLE;
				end
				else if(SDA_sync == 1'b1) // NACK received
				begin
					next_state = RE_NACK; 
				end
			end

			READ_ENABLE: //Get data as it comes based on receiving ACKs until stop found
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

			RE_ACK: // ACK successful data transmission, head over for next byte of data
			begin
				if(ack_done == 1'b1) begin
					next_state = FIFO_CHK_TX;
				end
				else if(stop == 1'b1) 
				begin
					next_state = IDLE;
				end
			end

			RE_NACK: // NACK unsuccessful data transmission, head over for getting new address or termiate I2C if stop sent by Master
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
				if(en_clock_strech == 1'b1) // Hold SCL line low
				begin
					next_state = FIFO_CHK_RX;
				end
				else
				begin	
					next_state = SEND_1;
				end
			end

			SEND_1:	// Send NACK, ACK or terminate I2C
			begin
				if(stop == 1'b1) 
				begin
					next_state = IDLE;
				end 
				else if(RX_fifo_almost_full == 1'b1 && ack_prep == 1'b1) 
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
				if(ack_done == 1'b1) begin // Wait until 9th SCL pulse is over
					next_state = SEND_2;
				end
			end

			SEND_NACK:
			begin 
				if(ack_done == 1'b1) begin   // Wait until 9th SCL pulse is over
					next_state = SEND_2;
				end
			end

			SEND_2:
			begin
				if(stop == 1'b1)  // Wait for STOP
				begin
					next_state = IDLE;
				end
				else   // Get new data and send ACK/NACK as necessary
				begin 
					next_state = FIFO_CHK_RX;
				end
			end
		endcase
	end

	always @(state) //Output Logic Block
	begin
		temp_rx_enable = 1'b0;
		temp_SCL_out_slave = 1'b1;
		temp_busy_slave = 1'b0;
		temp_TX_read_enable_slave = 1'b0;
		temp_RX_write_enable_slave = 1'b0;
		temp_ack_error_set_slave = 1'b0;
		temp_sda_mode = 2'b00;
		temp_load_data = 1'b0;
		temp_tx_enable = 1'b0;
		rw_store = 1'b0;

		case (state)
			IDLE:
			begin 
				temp_rx_enable = 1'b1;
				temp_SCL_out_slave = 1'b1;
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
				temp_SCL_out_slave = 1'b1;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
				rw_store = 1'b1;
			end

			CHECK_ADDR_1:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b1;
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
				temp_SCL_out_slave = 1'b1;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b10; //NACK
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			ACK_SEND_1:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b1;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b01; //ACK
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			GET_ADDR_2:
			begin 
				temp_rx_enable = 1'b1;
				temp_SCL_out_slave = 1'b1;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00; //IDLE
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			CHECK_ADDR_2:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b1;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00; //IDLE
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			ACK_SEND_2:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b1;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b01; //ACK
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
				temp_sda_mode = 2'b00; //IDLE
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			LOAD:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b1;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b01; //ACK
				temp_load_data = 1'b1;
				temp_tx_enable = 1'b0;
			end
			DATA_START:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b1;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b11; //DATA_OUT
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b1;
			end
			DATA_STOP:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b1;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b0;
				temp_sda_mode = 2'b00; //IDLE
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			ACK_CHECK:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b1;
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
				temp_SCL_out_slave = 1'b1;
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
				temp_SCL_out_slave = 1'b1;
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
				temp_SCL_out_slave = 1'b1;
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
				temp_SCL_out_slave = 1'b1;
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
				temp_SCL_out_slave = 1'b1;
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
				temp_SCL_out_slave = 1'b1;
				temp_busy_slave = 1'b1;
				temp_TX_read_enable_slave = 1'b0;
				temp_RX_write_enable_slave = 1'b0;
				temp_ack_error_set_slave = 1'b1;
				temp_sda_mode = 2'b10;
				temp_load_data = 1'b0;
				temp_tx_enable = 1'b0;
			end
			SEND_2:
			begin 
				temp_rx_enable = 1'b0;
				temp_SCL_out_slave = 1'b1;
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
				temp_SCL_out_slave = 1'b1;
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
