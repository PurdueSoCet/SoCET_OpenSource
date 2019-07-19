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

//REQUIRES BUS EMULATION
//
`include "i2c.vh"

logic [7:0] tb_master_buffer [63:0];
task master_reset();
	master_SDA=1;
	master_SCL=1;
endtask

task master_check_received(input integer size);
	integer i;
	for(i=0;i<size;i++) begin
		assert(tb_master_buffer[i]==tb_expected_data[i]) else
			$error("Emulated master on byte %d received %d, expected %d",i,tb_master_buffer[i],tb_expected_data[i]);
	end
endtask

task master_drive_clock(input integer clk, logic data, output logic read_value);

	#(15ns); //Might raise some errors in tb_slave_top_level
	master_SCL=0;
	master_SDA=data;
	delay(clk);
	master_SCL=1;
	if(!SCL)
		@(posedge SCL);
	read_value=SDA;

	fork
		delay(clk);
		@(negedge SCL);
	join_any
	disable fork;
	master_SCL=0;
endtask

task master_send_byte(input integer clk, input logic[7:0] data, output logic abort, logic stop);
	integer i;
	logic read_value;
	stop=0;
	abort=0;
	for(i=7;i>=0;i--) begin
		master_drive_clock(clk,data[i],read_value);
		if(read_value != data[i]) begin
			abort=1;
			return;
		end
	end
	master_drive_clock(clk,1,read_value);
	stop = read_value;
endtask

task master_get_byte(input integer clk, output logic[7:0] data, input logic should_ack);
	integer i;
	logic read_value;
	for(i=7;i>=0;i--) begin
		master_drive_clock(clk,1,read_value);
		data[i]=read_value;
	end
	master_drive_clock(clk,!should_ack,read_value);
endtask

task master_send_address(input integer clk, logic[9:0] address, AddressMode mode, DataDirection dir, output logic abort, logic stop);
	logic [7:0] addr7;
	logic [7:0] addr101;
	logic [7:0] addr102;
	logic dirBit;
	dirBit = dir==RX;
	addr7={address[6:0],dirBit};
	addr101={5'b11110,address[9:8],dirBit};
	addr102=address[7:0];
	stop=0;
	abort=0;

	if(mode == ADDR_7_BIT) begin
		master_send_byte(clk,addr7,abort,stop);
	end
	else begin
		master_send_byte(clk, addr101,abort,stop);
		if(abort|stop) return;
		master_send_byte(clk, addr102,abort,stop);
	end
endtask

task master_send_start(input integer clk);
	master_SDA=1;
	master_SCL=1;
	delay(clk);
	master_SDA=0;
	master_SCL=1;
	delay(clk);
	master_SDA=0;
	master_SCL=0;
	delay(clk);
endtask

task master_send_stop(input integer clk);
	master_SDA=0;
	master_SCL=0;
	delay(clk);
	master_SDA=0;
	master_SCL=1;
	delay(clk);
	master_SDA=1;
	master_SCL=1;
	delay(clk);
endtask


task master_send(input integer size, integer clk, logic[9:0] address, AddressMode mode);
	integer i;
	logic abort;
	logic stop;
	master_send_start(clk);
	master_send_address(clk,address,mode,TX,abort,stop);
	if(abort) begin
		$info("Emulated master aborted!");
		master_reset();
		return;
	end
	if(stop) begin master_send_stop(clk); return; end
	for(i=0;i<size;i++) begin
		master_send_byte(clk, tb_master_buffer[i], abort, stop);
		if(abort) begin
			master_reset();
			return;
		end
		if(stop) begin master_send_stop(clk); return; end
	end
	master_send_stop(clk);
endtask

task master_receive(integer size, integer clk, logic[9:0] address, AddressMode mode);
	integer i;
	logic abort;
	logic stop;
	master_send_start(clk);
	master_send_address(clk,address,mode,RX,abort,stop);
	if(abort) return;
	if(stop) begin master_send_stop(clk); return; end
	for(i=0;i<size;i++) begin
		master_get_byte(clk, tb_master_buffer[i], i!=size-1);
	end
	master_send_stop(clk);
endtask
