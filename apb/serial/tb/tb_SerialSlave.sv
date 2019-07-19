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

// File name:   tb_serialport.sv
// Created:     6/11/2014
// Author:      Xin Tze Tee
// Version:     1.0  
// Description: Test for APB Slave interfacing with a AHB to APB Bridge
//				using the file reading bus master as the AHB master 


`timescale 1ns / 10ps

module tb_SerialSlave();

// Define parameters
parameter CLK_PERIOD = 20;
parameter NORM_DATA_PERIOD	= (286 * CLK_PERIOD);

//Interfacing Variables
reg 	clk;
reg 	n_rst;
//reg     frbm_n_rst;

//Output Variables

//--AHB Bus Signals--//
reg 	[31:0] 	HADDR;
reg 	[ 2:0] 	HBURST;
reg		[ 3:0]  HPROT;
reg 	[ 2:0] 	HSIZE;
reg 	[ 1:0] 	HTRANS;
reg 	[31:0] 	HWDATA;
reg 	HWRITE;
reg 	[31:0] HRDATA;
reg 	HREADY;
reg  	HRESP;
reg		HBUSREQ;
reg 	HLOCK;

//--APB Bus Signals--//
reg 	[31:0] 	PRDATA;
reg 	[31:0] 	PWDATA;
reg 	[31:0] 	PADDR;
reg 	PWRITE;
reg 	PENABLE;
reg 	[7:0]	PSEL_slave;
wire [31:0] PRDataGPIO;
wire [31:0] PRDataSPIM;
wire [31:0] PRDataSPIS;
wire [31:0] PRDataGraph;
wire [31:0] PRDataUART;

//-- APB Slave Signals--//
reg serial_in;					// input from outside source
reg data_out;					// output to outside source	
reg pslverr;


//-------------------------------------------------PORT MAP-----------------------------------------------------------//
ahb_frbm
#(
	.TIC_CMD_FILE("./../apb/serial/scripts/serialportcmds2.tic")
) ahb_frbm (

	.HCLK(clk),
	.HRESETn(n_rst),
	.HADDR(HADDR),
	.HBURST(HBURST),
	.HPROT(HPROT),
	.HSIZE(HSIZE),
	.HTRANS(HTRANS),
	.HWDATA(HWDATA),
	.HWRITE(HWRITE),
	.HRDATA(HRDATA),
	.HREADY(HREADY),
	.HRESP({1'b0, HRESP}),
	.HBUSREQ(HBUSREQ),
	.HLOCK(HLOCK),
	.HGRANT(1'b1)
);

// AHB to APB Bridge
ahb2apb ahb2apb
(
	.clk(clk), .n_rst(n_rst),
	.HADDR(HADDR),
	.HWDATA(HWDATA),
	.HTRANS(HTRANS),
	.HWRITE(HWRITE),
	.PRDataGPIO(PRDataGPIO),
	.PRDataSPIM(PRDataSPIM),
	.PRDataSPIS(PRDataSPIS),
	.PRDataGraph(PRDataGraph),
	.PRDataUART(PRDataUART),
	.HRDATA(HRDATA),
	.HREADY(HREADY),  
	.HRESP(HRESP),
	.PWDATA(PWDATA),
	.PADDR(PADDR),
	.PWRITE(PWRITE),
	.PENABLE(PENABLE),
	.PSEL_slave(PSEL_slave)
);

// APB Slave Interface
SerialSlave SerialSlave
(
	.clk(clk), .n_rst(n_rst),
	.PADDR(PADDR),				
	.PWDATA(PWDATA),
	.PWRITE(PWRITE),
	.PENABLE(PENABLE),
	.PSEL(PSEL_slave[4]),	
	.serial_in(serial_in),					
	.data_out(data_out),							
	.PRDATA(PRDataUART),				
	.pslverr(pslverr)
);

//-------------------------------------------------------------------------------------------------------------------//

// Clock Generation
always
begin : CLK_GEN
	clk = 1'b0;
	#(CLK_PERIOD / 2);
	clk = 1'b1;
	#(CLK_PERIOD / 2);
end

task send_packet;
	input  [7:0] data;
	input  stop_bit;
	input  time data_period;
		
	integer i;
	
  begin
	// Send start bit
	serial_in = 1'b0;
	#data_period;
		
	// Send data bits
	for(i = 0; i < 8; i = i + 1)
	begin
		serial_in = data[i];
		#data_period;
	end
		
	// Send stop bit
	serial_in = stop_bit;
	#data_period;
  end
endtask
/*
integer i;
reg [8:0] data;
task send_bits;
	
	for (i = 0 ; i <= 9 ; i++) begin
		if (i > 8)begin 
			serial_in <= 1'b1;
			#NORM_DATA_PERIOD;
		//Start bit -> '0'
		end else if (i == 0) begin
			serial_in <= 1'b0;
			#NORM_DATA_PERIOD;
		end else begin
			serial_in = data[i];
			#NORM_DATA_PERIOD;
		end
	end
endtask
*/

initial
  begin
	// Initialize variables
	//frbm_n_rst = 1'b0;
    n_rst = 1'b0;
	//serial_in = 1'b1;
	#20;
	@(negedge clk);
    n_rst = 1'b1;
	/*frbm_n_rst = 1'b1;
	@(posedge clk);
	#(CLK_PERIOD * 10);
	@(negedge clk);
	frbm_n_rst = 1'b0;*/
	send_packet(8'b10101001,1'b1,NORM_DATA_PERIOD);
	
	//data = {8'b10101001,1'b1};
	//send_bits();
	@(posedge clk);
	@(posedge clk);
	//serial_in = 1'b1;
	@(posedge clk);
	send_packet(8'b01101010,1'b1,NORM_DATA_PERIOD);
	//frbm_n_rst = 1'b1;
/*
	// Initiate Read Transmission
	HADDR = 32'h00004008;
	HTRANS = 2'b10;
	HWRITE = 1'b0;
*/
end

endmodule
