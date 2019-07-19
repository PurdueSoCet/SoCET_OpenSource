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

//Bus emulator
//=====================================================================
logic slave_SDA;
logic slave_SCL;
logic master_SDA;
logic master_SCL;
logic DUT_SDA;
logic DUT_SCL;
logic SDA;
logic SCL;

//register output from DUT to prevent extra edges.  This will be done in
//a high design module.
logic DUT_SDA_reg;
logic DUT_SCL_reg;
always @(posedge clk, negedge n_rst) begin
	if(!n_rst) begin
		DUT_SDA_reg =1;
		DUT_SCL_reg =1;
	end else
		DUT_SDA_reg=DUT_SDA;
		DUT_SCL_reg=DUT_SCL;
end

assign SDA = slave_SDA & master_SDA & DUT_SDA_reg;
assign SCL = slave_SCL & master_SCL & DUT_SCL_reg;

//Slave emulator
//=====================================================================
logic slave_address_mode; //0 for 7, 1 for 10
logic slave_rx_mode;
integer slave_rx_pointer;
integer slave_bit;
integer slave_stretch;
logic [7:0] slave_rx_fifo [65:0];
logic [7:0] slave_tx_fifo [65:2];
logic [7:0] slave_rx_shift;
logic slave_active=0;
integer nack_byte;

//At start condition, activate slave
always begin
	@(negedge SDA);
	if(SCL)
		slave_rx_mode=1;
		slave_active=1;
end

//At end condition, deactivate slave
always begin
	@(posedge SDA);
	if(SCL) begin
		slave_active=0;
		slave_reset();
	end
end

//At clk rising edge, shift bits
always begin
	@(posedge SCL);
	if (slave_rx_mode &&slave_active) begin
		if(slave_bit<8) begin
			slave_rx_shift = slave_rx_shift<<1;
			slave_rx_shift[0] = SDA;
		end
		slave_bit++;
	end
	else if(!slave_rx_mode && slave_active) begin
		if(slave_bit==8 && SDA) //Nack bit
			slave_reset();
	end
end

//use clk falling edge to shift if in tx or send ack if necessary
always begin
	integer i;
	@(negedge SCL);
	#(5ns);
	if(slave_rx_mode) begin
		if(slave_active && slave_bit==8 && slave_rx_pointer != nack_byte) begin
			slave_SDA=0;
			//Do clock stretching
			slave_SCL=0;
			for(i=0;i<slave_stretch;i++) begin
				@(negedge clk);
			end
			slave_SCL=1;
		end else if (slave_active && slave_bit==9) begin
			slave_SDA=1;
			slave_rx_fifo[slave_rx_pointer++] = slave_rx_shift;
			slave_bit=0;
			if(slave_rx_pointer==1 && !slave_address_mode)
				slave_rx_mode = !slave_rx_fifo[0][0];
			if(slave_rx_pointer==2 && slave_address_mode)
				slave_rx_mode = !slave_rx_fifo[0][0];
			if(!slave_rx_mode) begin
				slave_rx_pointer=2;
				slave_SDA = slave_tx_fifo[slave_rx_pointer][7];
			end
		end
	end else begin
		if(slave_active && slave_bit!=8) begin
			slave_bit++;
			if(slave_bit==8)
				slave_SDA=1;
			else
				slave_SDA = slave_tx_fifo[slave_rx_pointer][7-slave_bit];
		end else if(slave_active && slave_bit==8) begin
			slave_bit=0;
			slave_rx_pointer++;
			slave_SDA = slave_tx_fifo[slave_rx_pointer][7];
		end
	end
end

task slave_reset();
	slave_rx_pointer=0;
	slave_bit=0;
	slave_active=0;
	slave_SCL=1;
	slave_SDA=1;
endtask

//Master emulator
//=====================================================================
logic [7:0] master_tx_fifo [63:0];
integer master_current_bit;
integer master_tx_fifo_pointer;
task master_reset();
	master_SDA=1;
	master_SCL=1;
endtask

task wait_cycles(input integer delay);
	integer i;
	for(i=0;i<delay;i++) begin
		@(negedge clk);
	end
endtask

task master_send_data(
	input integer speed,
	integer size
);
	for(master_tx_fifo_pointer = 0; master_tx_fifo_pointer < size; master_tx_fifo_pointer++) begin
		for(master_current_bit=7; master_current_bit >=0; master_current_bit--) begin
		master_SCL=0;
		master_SDA=master_tx_fifo[master_tx_fifo_pointer][master_current_bit];
		wait_cycles(speed);
		master_SCL=1;
		@(posedge SCL); //sync
		fork
			@(negedge SCL);
			wait_cycles(speed);
		join_any
		disable fork;
		end
	end
	master_SDA=1;
	master_SCL=1;
endtask

//TX FIFO emulator
//=====================================================================
logic [7:0] tx_data;
logic [7:0] tx_fifo [63:0];
integer tx_fifo_pointer;

always @(tx_fifo_pointer) begin
	tx_data = tx_fifo[tx_fifo_pointer];
end

//increment fifo
always @(posedge clk) begin
	if(TX_read_enable_master)
		tx_fifo_pointer++;
	if(transaction_begin_clear)
		transaction_begin=0;
end

//RX FIFO emulator
///====================================================================
logic [7:0] rx_data;
logic [7:0] rx_fifo [63:0];
integer rx_fifo_pointer;

//increment fifo
always @(posedge clk) begin
	if(RX_write_enable_master)
		rx_fifo[rx_fifo_pointer++] = rx_data;
end

task fifo_reset();
	tx_fifo_pointer=0;
	rx_fifo_pointer=0;
endtask

