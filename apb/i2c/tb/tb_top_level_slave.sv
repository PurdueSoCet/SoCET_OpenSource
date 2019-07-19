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

`timescale 1ns/100ps
//`include "i2c.vh"

module tb_top_level_slave();
logic tb_interrupt;
logic [31:0]tb_expected_PRDATA;

`include "tb_bus_emulator.vh"	
`include "tb_slave_emulator.vh"
`include "tb_master_emulator.vh"
`include "tb_apb_emulator.vh"


i2c_wrapper DUT(
	tb_clk,
	tb_n_rst,
	SDA,
	SCL,
	PWRITE,
	PENABLE,
	PSEL,
	PWDATA,
	PADDR,
	PRDATA,
	dut_SDA,
	dut_SCL,
	tb_interrupt
);


logic [31:0] tb_flags;
logic [31:0] tb_data;

integer testcase;

task ten_bit_correct();
	integer i;
	testcase += 1;
	//------------INITIALIZATION------------
	APB_write_addr(10'b1101011001);
	APB_write_control(0,1,0,2,1,1);		//(clock_stretch,transac_begin,data_dir,packet_size,ms_select,address_mode)
	tb_master_buffer[3:0] = {8'd140,8'd176,8'd36,8'd59};
	$info("-------------------------ADDRESS BYTES = 11110110 + 01011001-------------------------");

	//------------START------------
	master_send(4, 50, 10'b1101011001, ADDR_10_BIT);
	for(i=0;i<4;i++) begin
		APB_read_rx(tb_data);
		assert(tb_master_buffer[i]==tb_data) else
			$error("Emulated master on byte %d received %d, expected %d",i,tb_master_buffer[i],tb_data);
	end
endtask

task seven_bit_correct();
	integer i;
	testcase += 1;
	//------------INITIALIZATION------------
	APB_write_addr(10'b1101011001);
	APB_write_control(0,1,0,2,1,0);		//(clock_stretch,transac_begin,data_dir,packet_size,ms_select,address_mode)
	tb_expected_data[3:0] = {8'd7,8'd77,8'd47,8'd170};
	$info("-------------------------ADDRESS BYTES = 10110011-------------------------");

	//------------START------------
	for(i=0;i<4;i++) begin
		APB_write_tx(tb_expected_data[i]);
	end
	master_receive(4, 50, 10'b1101011001, ADDR_7_BIT);
	master_check_received(4);

endtask

task seven_bit_wrong();
	integer i;
	testcase += 1;
	//------------INITIALIZATION------------
	APB_write_addr(10'b1101011001);
	APB_write_control(0,1,0,2,1,0);		//(clock_stretch,transac_begin,data_dir,packet_size,ms_select,address_mode)
	tb_expected_data[3:0] = {8'd95,8'd90,8'd9,8'd97};
	$info("-------------------------ADDRESS BYTES = 10110011-------------------------");

	//------------START------------
	for(i=0;i<4;i++) begin
		APB_write_tx(tb_expected_data[i]);
	end
	master_receive(4, 50, 10'b1101011011, ADDR_7_BIT);// INCORRECT ADDRESS SENT HERE
	master_check_received(4);

endtask

task do_stretch(integer delay1, integer delay2);
			#(425ns);
			APB_write_control(1,1,0,2,1,0);		//(clock_stretch,transac_begin,data_dir,packet_size,ms_select,address_mode)
			#(20500ns);
			APB_write_control(0,1,0,2,1,0);		//(clock_stretch,transac_begin,data_dir,packet_size,ms_select,address_mode)
endtask

task seven_bit_stretch();
	integer i;
	testcase += 1;
	//------------INITIALIZATION------------
	APB_write_addr(10'b1101011001);
	APB_write_control(0,1,0,2,1,0);		//(clock_stretch,transac_begin,data_dir,packet_size,ms_select,address_mode)
	tb_expected_data[3:0] = {8'd105,8'd202,8'd199,8'd43};
	$info("-------------------------ADDRESS BYTES = 10110011-------------------------");

	//------------START------------
	for(i=0;i<4;i++) begin
		APB_write_tx(tb_expected_data[i]);
	end
	fork
			master_receive(4, 50, 10'b1101011001, ADDR_7_BIT);		
			do_stretch(425,20000);
	join
	master_check_received(4);
endtask

task tx_fifo_empty();
	integer i;
	testcase += 1;
	//------------INITIALIZATION------------
	APB_write_addr(10'b1101011001);
	APB_write_control(0,1,0,2,1,0);		//(clock_stretch,transac_begin,data_dir,packet_size,ms_select,address_mode)

	//------------START------------
	//master_receive(4, 50, 10'b1101011001, ADDR_7_BIT);
endtask

task rx_fifo_almost_full();
	integer i;
	testcase += 1;
	//------------INITIALIZATION------------
	APB_write_addr(10'b1101011001);
	APB_write_control(0,1,0,2,1,1);		//(clock_stretch,transac_begin,data_dir,packet_size,ms_select,address_mode)
	tb_master_buffer[8:0] = {8'd1,8'd2,8'd3,8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9};
	$info("-------------------------ADDRESS BYTES = 11110110 + 01011001-------------------------");

	//------------START------------
	master_send(9, 50, 10'b1101011001, ADDR_10_BIT);
	for(i=0;i<9;i++) begin
		APB_read_rx(tb_data);
		assert(tb_master_buffer[i]==tb_data) else
			$error("Emulated master on byte %d received %d, expected %d",i,tb_master_buffer[i],tb_data);
	end
endtask

task send_16_byte();
	logic [31:0] tb_data;
	integer i;
	testcase += 1;
	//------------INITIALIZATION------------
	APB_write_addr(10'b1101011001);
	APB_write_control(0,1,0,2,1,0);		//(clock_stretch,transac_begin,data_dir,packet_size,ms_select,address_mode)
	tb_expected_data[15:0] = {8'd10,8'd20,8'd30,8'd40,8'd50,8'd60,8'd70,8'd80,8'd90,8'd100,8'd110,8'd120,8'd130,8'd140,8'd150,8'd160};
	$info("-------------------------ADDRESS BYTES = 10110011-------------------------");

	//------------START------------
	for(i=0;i<8;i++) begin
		APB_write_tx(tb_expected_data[i]);
	end

	fork
		master_receive(16, 50, 10'b1101011001, ADDR_7_BIT);
		begin
			@(posedge tb_interrupt);
			APB_read_status(tb_data);
			$info("tb_data = %d",tb_data);
			for(i=8;i<16;i++) begin
				APB_write_tx(tb_expected_data[i]);
			end
			@(posedge tb_interrupt);
		end
	join
	$info("-------------------------16_BIT_TRANSACTION_COMPLETE-------------------------");
endtask

initial begin
	testcase = 0;
	$info("-------------------------STARTING-------------------------");
	slave_reset();
	$info("-------------------------SLAVE RESET-------------------------");
	APB_reset();
	master_reset();
	tb_n_rst=0;
	delay(2);
	tb_n_rst=1;

	APB_write_div(10);
	
	//--------------------------------------------STARTING TEST BENCH BUILDING HERE--------------------------------------------
	//---------------------Work for 10 bit correct address addressing mode
	$info("---------------------------------------10_BIT_CORRECT_CASE---------------------------------------");
	#(400);
	ten_bit_correct();


	//---------------------Work for  7 bit correct address addressing mode
	$info("---------------------------------------7_BIT_CORRECT_CASE---------------------------------------");	
	#(400);
	seven_bit_correct();

	//---------------------Work for  7 bit wrong   address addressing mode
	$info("---------------------------------------7_BIT_WRONG_CASE---------------------------------------");	
	#(400);
	seven_bit_wrong();

	tb_n_rst=0;
	delay(2);
	tb_n_rst=1;

	//---------------------Work for clock stretching enabled
	$info("---------------------------------------EN_CLK_STRETCH_CASE---------------------------------------");
	#(400);
	seven_bit_stretch();


	tb_n_rst=0;
	delay(2);
	tb_n_rst=1;	

	//---------------------Work for TX_fifo_empty
	$info("---------------------------------------TX_FIFO_EMPTY_CASE---------------------------------------");
	#(400);
	tx_fifo_empty();

	tb_n_rst=0;
	delay(2);
	tb_n_rst=1;

	//---------------------Work for Rx_fifo_almost_full send a NACK
	$info("---------------------------------------RX_FIFO_ALMOST_FULL_CASE---------------------------------------");
	#(400);
	rx_fifo_almost_full();
	
	tb_n_rst=0;
	delay(2);
	tb_n_rst=1;

	//---------------------Sending 16 Bytes of Data
	$info("---------------------------------------SEND_16_BYTE_CASE---------------------------------------");
	#(400);
	send_16_byte();
	
	$info("--------------------------------------------TESTBENCH COMPLETE--------------------------------------------");
end
endmodule
