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

// File name:   gpio.sv
// Created:     10/23/2014
// Author:      John Skubic
// Version:     1.0 
// Description: GPIO pin accessed through an APB bus
//	

`include "apb_if.vh"
`include "gpio_if.vh"

module Gpio
#(
  parameter NUM_PINS           = 8     //MAX 32
)
(
  input wire clk, n_rst, 

  //APB_Slave Interface
  apb_if.apb_s apbif,

  //Gpio Interface
  gpio_if.gpio gpioif

);
  //GPIO Register indicies
  localparam DATA_IND           = 0;    //32'hXXXXX004
  localparam EN_IND             = 1;    //32'hXXXXX008
  localparam INTR_EN_IND        = 2;    //32'hXXXXX00C
  localparam INTR_POSEDGE_IND   = 3;    //32'hXXXXX010
  localparam INTR_NEGEDGE_IND   = 4;    //32'hXXXXX014
  localparam INTR_CLR_IND       = 5;    //32'hXXXXX018
  localparam INTR_STAT_IND      = 6;    //32'hXXXXX01C
  localparam NUM_REGISTERS      = 7;

  genvar i;

  //each register's write enable and regs
  reg [NUM_REGISTERS - 1 : 0][NUM_PINS - 1 : 0] registers;

  //apb information
  wire [31:0] apb_data;
  wire [NUM_REGISTERS - 1 : 0][31:0] apb_read;
  wire [NUM_REGISTERS - 1:0] wen;

  //synchronizer
  reg [NUM_PINS - 1 : 0] read_r;
  reg [NUM_PINS - 1 : 0] sync_in;
  reg [NUM_PINS - 1 : 0] sync_out;

  //edge detection vars
  wire [NUM_PINS - 1 : 0] pos_edge;
  wire [NUM_PINS - 1 : 0] neg_edge;

  wire [NUM_PINS - 1 : 0] gen_intr;

  //assign output
  assign gpioif.en_data = registers[EN_IND];
  assign gpioif.w_data = registers[DATA_IND];
  assign gpioif.interrupt = |registers[INTR_STAT_IND];
  
  GPIO_SlaveInterface #(
    .NUM_REGS(NUM_REGISTERS), 
    .ADDR_OFFSET(4)
  ) apbs (
	.clk(clk),
	.n_rst(n_rst),
	// inputs from APB Bridge
	.PADDR(apbif.PADDR),
	.PWDATA(apbif.PWDATA),
	.PENABLE(apbif.PENABLE),
	.PWRITE(apbif.PWRITE),
	.PSEL(apbif.PSEL),
	// output to APB Bridge
	.PRDATA(apbif.PRDATA),
 
 	// input data from slave registers
	.read_data(apb_read),
	// output to slave registers
	.w_enable(wen),
	.w_data(apb_data)
  );

  //edge detector for interrupt generation
  edge_detector #(.WIDTH(NUM_PINS)) edgd (
      .clk(clk),
      .n_rst(n_rst), 
      .signal(sync_out), 
      .pos_edge(pos_edge), 
      .neg_edge(neg_edge)
    );


  //synchronizer
  always_ff @ (posedge clk, negedge n_rst) begin
    if (~n_rst) begin
      sync_in <= '0;
      sync_out <= '0;
    end
    else begin
      sync_in <= gpioif.r_data;
      sync_out <= sync_in;
    end
  end 
  
  //read reg 
  always_ff @ (posedge clk, negedge n_rst) begin
    if (~n_rst)
      read_r <= '0;
    else 
      read_r <= sync_out;
  end

  //---------------------------------------//
  //APB Writing to slave registers
  //---------------------------------------//

  generate
    for(i = 0; i < NUM_REGISTERS; i++) begin : APB_write_slave_regs
      if((i != INTR_STAT_IND) && (i != INTR_CLR_IND)) begin //status and clear have special functionality
        always_ff @ (posedge clk, negedge n_rst) begin 
          if(~n_rst)
            registers[i] <= '0;
          else if (wen[i])
            registers[i] <= apb_data[NUM_PINS - 1 : 0];
        end 
      end 
    end 
  endgenerate

  //---------------------------------------//
  // Formation of read data for APB slave
  //---------------------------------------//

  generate
    for(i = 0; i < NUM_REGISTERS; i++) begin : generate_r_data_APB_slave
      //set unused bits to 0
      if(NUM_PINS < 32)
      	assign apb_read[i][31 : NUM_PINS] = '0;

      //if trying to access data reg, return the read register data
      if(i == DATA_IND)
        assign apb_read[i][NUM_PINS - 1 : 0] = read_r;
      else
        assign apb_read[i][NUM_PINS - 1 : 0] = registers[i];
    end 
  endgenerate

  //--------------------------------------//
  //Interrupt functionality
  //--------------------------------------//

  assign gen_intr = ((registers[INTR_POSEDGE_IND] & pos_edge) | (registers[INTR_NEGEDGE_IND] & neg_edge)) & registers[INTR_EN_IND];

  always_ff @ (posedge clk, negedge n_rst) begin
    if(~n_rst)
      registers[INTR_STAT_IND] <= '0;
    else 
      registers[INTR_STAT_IND] <= (registers[INTR_STAT_IND] & ~registers[INTR_CLR_IND]) | gen_intr;
  end 

  //immediately clear the clear register unless the slave is being written to
  always_ff @ (posedge clk, negedge n_rst) begin
    if (~n_rst)
      registers[INTR_CLR_IND] <= '0;
    else if (wen[INTR_CLR_IND])
      registers[INTR_CLR_IND] <= '1;
    else
      registers[INTR_CLR_IND] <= '0;
  end 


endmodule
