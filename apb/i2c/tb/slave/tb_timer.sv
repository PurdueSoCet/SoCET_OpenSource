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

// Description: This is the module for the Checker block
`timescale 1ns / 10ps

module tb_timer();
  
  // Define parameters
	parameter CLK_PERIOD	= 10;
	parameter SCL_PERIOD    = 300;
	parameter sclwait       = 300;
  
	reg tb_scl;
  	reg tb_sda_in;

	reg tb_clk;
	reg tb_n_rst;
	reg tb_start;
	reg tb_stop;
	reg tb_rising_edge;
	reg tb_falling_edge;
	reg tb_byte_received;
	reg tb_ack_prep;
	reg tb_ack_check;
	reg tb_ack_done;

	timer DUT
	(
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.start(tb_start),
		.stop(tb_stop),
		.rising_edge(tb_rising_edge),
		.falling_edge(tb_falling_edge),
		.byte_received(tb_byte_received),
		.ack_prep(tb_ack_prep),
		.ack_check(tb_ack_check),
		.ack_done(tb_ack_done)
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
	    tb_scl = 1'b0;
	    #(SCL_PERIOD / 3);
	    tb_scl = 1'b1;
	    #(SCL_PERIOD / 3); 
	    tb_scl = 1'b0;
	    #(SCL_PERIOD / 3);
	end	
	
	initial
	begin 
	  tb_n_rst = 1'b0;
	  tb_start = 0;
	  tb_stop = 0;    
	  tb_rising_edge =0;
	  tb_falling_edge =0;
	  @(posedge tb_clk);
    tb_n_rst = 1'b1;
 
    
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); 
    
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); 
    
    @(posedge tb_scl);
		@(posedge tb_clk);
		tb_rising_edge=1;
		tb_falling_edge =0;
		@(posedge tb_clk);
		tb_start = 1'b1;
			
		@(posedge tb_clk); 
		tb_rising_edge=0;
		tb_falling_edge =0;
		tb_start = 1'b0;
				
		@(negedge tb_scl);
		@(posedge tb_clk);
		tb_rising_edge=0;
		tb_falling_edge =1;
				
		@(posedge tb_clk); 
		tb_rising_edge=0;
		tb_falling_edge =0;
    
    
    
    repeat (27) begin 
      @(posedge tb_scl);
      @(posedge tb_clk);
      tb_rising_edge=1;
      tb_falling_edge =0;
  
      @(posedge tb_clk); 
      tb_rising_edge=0;
      tb_falling_edge =0;
    
      @(negedge tb_scl);
      @(posedge tb_clk);
      tb_rising_edge=0;
      tb_falling_edge =1;
    
      @(posedge tb_clk); 
      tb_rising_edge=0;
      tb_falling_edge =0;
    end
    
    @(posedge tb_scl);
    tb_rising_edge=1;
    tb_falling_edge =0;
    tb_stop =1;		//Sending Stop
    
    @(negedge tb_clk); 
    tb_rising_edge=0;
    tb_falling_edge =0;
    
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    
    tb_stop =0;		//Removing STOP
    
    @(negedge tb_scl);
    tb_rising_edge=0;
    tb_falling_edge =1;
    
    @(negedge tb_clk); 
    tb_rising_edge=0;
    tb_falling_edge =0;
    
    repeat (13) begin 		// Pulsing SCL
      @(posedge tb_scl);
      tb_rising_edge=1;
      tb_falling_edge =0;
    
      @(negedge tb_clk); 
      tb_rising_edge=0;
      tb_falling_edge =0;
    
      @(negedge tb_scl);
      tb_rising_edge=0;
      tb_falling_edge =1;
    
      @(negedge tb_clk); 
      tb_rising_edge=0;
      tb_falling_edge =0;
    end
    
    tb_start = 1'b1;	//Sending START
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); 
    tb_start = 1'b0;
     
    repeat (27) begin 	// Pulsing SCL
      @(posedge tb_scl);
      tb_rising_edge=1;
      tb_falling_edge =0;
    
      @(posedge tb_clk); 
      tb_rising_edge=0;
      tb_falling_edge =0;
    
      @(negedge tb_scl);
      tb_rising_edge=0;
      tb_falling_edge =1;
    
      @(posedge tb_clk); 
      tb_rising_edge=0;
      tb_falling_edge =0;
    end
    
    tb_start = 1'b1;		//Sending START
    @(posedge tb_clk);
    @(posedge tb_clk);
    tb_start = 1'b0;
     
    repeat (27) begin 	// Pulsing SCL
      @(posedge tb_scl);
      tb_rising_edge=1;
      tb_falling_edge =0;
    
      @(posedge tb_clk); 
      tb_rising_edge=0;
      tb_falling_edge =0;
    
      @(negedge tb_scl);
      tb_rising_edge=0;
      tb_falling_edge =1;
    
      @(posedge tb_clk); 
      tb_rising_edge=0;
      tb_falling_edge =0;
    end
    
	end 
endmodule
