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

// Description: This is the test bench for the Slave Edge Detector.
`timescale 1ns / 10ps

module tb_edge_detect();

	parameter CLK_PERIOD	= 10;
	parameter SCL_PERIOD    = 300;

  	reg tb_clk;
	reg tb_n_rst;
	reg tb_SCL_sync;
	reg tb_rising_edge;
	reg tb_falling_edge;
	
	edge_detect DUT
	(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.SCL_sync(tb_SCL_sync),
		.rising_edge(tb_rising_edge),
		.falling_edge(tb_falling_edge)
	);
	
	
	always
	begin : CLK_GEN
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2);
	end
	
	
	always
	begin : SCL_GEN
	    tb_SCL_sync = 1'b0;
	    #(SCL_PERIOD / 3);
	    tb_SCL_sync = 1'b1;
	    #(SCL_PERIOD / 3); 
	    tb_SCL_sync = 1'b0;
	    #(SCL_PERIOD / 3);
	end	
	
	
	initial
	begin 
		tb_n_rst				= 1'b0;
		#0.1; 
		tb_n_rst = 1'b1;

	end 

   

endmodule
