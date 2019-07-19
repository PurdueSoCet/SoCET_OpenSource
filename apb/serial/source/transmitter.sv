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

// File name:   transmitter.sv
// Updated:     03/01/2016
// Created:	Xin Tze Tee and Travis Garza
// Version:     2.0 
// Description: Transmit data out via shift register and counter

/*
Specs: 	-Baud rate @ 115200 bits per second
		-System clock @ 33MHz
		-Offset of 286 cycles for each bit
*/

/*
add input for Baud Rate in portmap and update rollover1
what i mean by update rollover1 is that it has a hard coded value at the moment but know i sent the baud rate to the baudReg. or can this file access the reg directly? i doubt so....
see serial_rcv_timer.sv
*/

module transmitter
(	
	input wire clk, n_rst, 
	input wire [7:0] data_in, 	// data packet to be transmitted
	input wire tx_enable,		// enable signal
	input reg [31:0] baudData,
	output reg data_out, 		// data bit that is shifted out
	output reg busy
);
					

reg [8:0] data_reg, next_data_reg;		//register to to store data packet (8 bit)
reg next_data_out;
reg next_busy;
wire [31:0]  count_out1;
wire [3:0]  count_out2;
wire [31:0]  rollover1;
wire [3:0]  rollover2;
wire rollover_flag;
wire packet_done;
wire shift;			//shift enable for shift register to shift data bit out

assign shift = rollover_flag;

assign rollover1 = baudData;	// number of cycles for 1 bit (baud-rate) used to be a fixed rate of 286
assign rollover2 = 10;	// number of bits (including start bit and stop bit)

defparam FLX1.NUM_CNT_BITS = 32;	
defparam FLX2.NUM_CNT_BITS = 4;

// Count the number of cycles for each bit
flex_counter FLX1(clk,n_rst,rollover_flag,busy,rollover1,count_out1,rollover_flag);
// Count the number of bits (8 bits)
flex_counter FLX2(clk,n_rst,packet_done,(busy & shift),rollover2,count_out2,packet_done);

//REGISTERS
always @ (posedge clk, negedge n_rst) begin
	if (n_rst == 1'b0) begin 
		data_reg	<= 9'b111111111;
		data_out	<= 1'b1;
		busy		<= 1'b0;
	end else begin
		data_reg 	<= next_data_reg;
		data_out	<= next_data_out;
		busy		<= next_busy;
	end 
end 

// OUTPUT LOGIC (shift register)
always_comb
begin 
  if(tx_enable == 1'b1) begin					// assert busy signal when transmittion enable is set
	next_busy <= 1'b1;
	next_data_reg <= {1'b1, data_in};
	next_data_out <= 1'b0;
  end else if (packet_done == 1'b1) begin				// clear busy signal when transmittion is done
	next_data_reg <= data_reg;
	next_data_out <= 1'b1;
	next_busy <= 1'b0;
  end else if (count_out2 >= 1 && count_out2 <= 9) begin		// shift bits
	next_busy     <= busy;
	next_data_out <= data_reg[0];
	if(shift == 1'b1) begin 
		next_data_reg <= {1'b1, data_reg[8:1]};	
	end else begin 
		next_data_reg <= data_reg;
	end
  end else begin 
	next_data_reg <= data_reg;
	next_data_out <= data_out;
	next_busy     <= busy;
  end
end
   
endmodule
