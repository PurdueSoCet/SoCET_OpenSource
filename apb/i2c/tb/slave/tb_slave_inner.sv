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

// Description: This is the test bench for the Slave Inner block
`timescale 1ns / 10ps

module tb_slave_inner();
  	parameter CLK_PERIOD	= 10;
	parameter SCL_PERIOD    = 300;
	parameter sclwait       = 300;
  
	reg tb_clk;
  reg tb_n_rst;
  reg [7:0] tb_tx_data;   // Data coming in from the TX FIFO
  reg tb_address_mode;
  reg tb_ms_select;
  reg [9:0] tb_bus_address;
  reg tb_en_clock_strech;
  reg tb_TX_fifo_empty;
  reg tb_RX_fifo_full;
  reg tb_RX_fifo_almost_full;
  reg tb_SDA_sync;
  reg tb_SCL_sync;
  reg [7:0] tb_rx_data_slave;
  reg tb_set_transaction_complete_slave;
  reg tb_ack_error_set_slave;
  reg tb_busy_slave;
  reg tb_TX_read_enable_slave;
  reg tb_RX_write_enable_slave;
  reg tb_SDA_out_slave;
  reg tb_SCL_sync_out_slave;

	slave_inner SLAVE_INNER
	(
		.clk(tb_clk),
    .n_rst(tb_n_rst),
    .tx_data(tb_tx_data),
    .address_mode(tb_address_mode),
    .ms_select(tb_ms_select),
    .bus_address(tb_bus_address),
    .en_clock_strech(tb_en_clock_strech),
    .TX_fifo_empty(tb_TX_fifo_empty),
    .RX_fifo_full(tb_RX_fifo_full),
    .RX_fifo_almost_full(tb_RX_fifo_almost_full),
    .SDA_sync(tb_SDA_sync),
    .SCL_sync(tb_SCL_sync),
    .rx_data_slave(tb_rx_data_slave),
    .set_transaction_complete_slave(tb_set_transaction_complete_slave),
    .ack_error_set_slave(tb_ack_error_set_slave),
    .busy_slave(tb_busy_slave),
    .TX_read_enable_slave(tb_TX_read_enable_slave),
    .RX_write_enable_slave(tb_RX_write_enable_slave),
    .SDA_out_slave(tb_SDA_out_slave),
    .SCL_out_slave(tb_SCL_sync_out_slave)
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
  
  integer i;
  integer k;
	initial
	begin 
	  tb_n_rst = 1'b0;
    tb_tx_data = 8'b10110011;
    tb_address_mode = 1'b0;   // 7 Bit Mode 
    tb_ms_select = 1'b0;      // Slave selected
    tb_bus_address = 10'b0000000111;
    tb_en_clock_strech = 1'b0;
    tb_TX_fifo_empty = 1'b0;
    tb_RX_fifo_full = 1'b0;
    tb_RX_fifo_almost_full = 1'b0;
    tb_SDA_sync = 1'b0;
	  @(posedge tb_clk);
    tb_n_rst = 1'b1;
 
    
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk); 
    
    // Generate a Start Condition by varying SDA line.
    tb_SDA_sync = 1'b1;

    @(posedge tb_SCL_sync);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);

    tb_SDA_sync = 1'b0;

    i=0;
    k=0;
    repeat (40) 
    begin
      @(negedge tb_SCL_sync);
      i = i+1;
      tb_SDA_sync = 1'b0;
      if(i == 10)
      begin 
        tb_bus_address = 10'b0111011101;
        // A9-A8 = 01 , A7-A0 = 11011101
        @(posedge tb_SCL_sync);
        tb_SDA_sync = 1'b1;
        tb_address_mode = 1'b1;
        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);
        tb_SDA_sync = 1'b0;
        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);
        tb_SDA_sync = 1'b1;
        // START generated

        // MAKING RX_DATA = 11110010
        repeat (3)
        begin
          @(negedge tb_SCL_sync);
          tb_SDA_sync = 1'b1;
        end
        // RX_DATA = 00001111
        repeat (2)
        begin
          @(negedge tb_SCL_sync);
          tb_SDA_sync = 1'b0;
        end
        // TX_DATA = 00111100
        @(negedge tb_SCL_sync);
        tb_SDA_sync = 1'b1;
        // TX_DATA = 01111001
        @(negedge tb_SCL_sync);
        tb_SDA_sync = 1'b0;
        // TX_DATA = 11110010
        @(negedge tb_SCL_sync);
        @(negedge tb_SCL_sync);
        k = k+1;
        tb_SDA_sync = 1'b1;
        @(negedge tb_SCL_sync);
        k = k+1;
        tb_SDA_sync = 1'b1;
        @(negedge tb_SCL_sync);
        k = k+1;
        tb_SDA_sync = 1'b0;
        @(negedge tb_SCL_sync);
        k = k+1;
        tb_SDA_sync = 1'b1;
        @(negedge tb_SCL_sync);
        k = k+1;
        tb_SDA_sync = 1'b1;
        @(negedge tb_SCL_sync);
        k = k+1;
        tb_SDA_sync = 1'b1;
        @(negedge tb_SCL_sync);
        k = k+1;
        tb_SDA_sync = 1'b0;
        @(negedge tb_SCL_sync);
        k = k+1;
        tb_SDA_sync = 1'b1;
        // TX_DATA = 11011101
      end
      if(i == 40) 
      begin
         @(posedge tb_SCL_sync);
         @(posedge tb_clk);
         @(posedge tb_clk);
         tb_SDA_sync = 1'b1;
       end 
    end

    // Set bus_address = 0001100110.
    // Send address 7 bit '1100110'+'1' denoting read from SDA line.
    // Check if Ack sent by slave on 9th pulse of SCL line.
    
    
	end 
endmodule
