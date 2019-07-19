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

`include "i2c.vh"
module master_wrapper(
	input	logic clk,
		logic n_rst,
		logic[7:0] tx_data,
		AddressMode address_mode,
                DataDirection data_direction,
                MasterSlave ms_select,
                logic [9:0] bus_address,
                logic [7:0] packet_size,
                logic en_clock_strech,
                logic TX_fifo_empty,
                logic RX_fifo_full,
		logic RX_fifo_almost_full,
                logic transaction_begin,
		logic SDA_sync,
		logic SCL_sync,
		logic[31:0] clk_divider,
	output 	logic[7:0] rx_data_master,
		logic set_transaction_complete_master,
		logic set_arbitration_lost,
                logic ack_error_set_master,
                logic transaction_begin_clear,
                logic busy_master,
                logic TX_read_enable_master,
                logic RX_write_enable_master,
		logic SDA_out_master,
		logic SCL_out_master,
		logic line_busy
);

i2c_internal_bus bus();
master MASTER(
	clk,
	n_rst,
	bus.Master
);

assign bus.tx_data                 =tx_data                 ;
assign bus.address_mode            =address_mode            ;
assign bus.data_direction          =data_direction          ;
assign bus.ms_select               =ms_select               ;
assign bus.bus_address             =bus_address             ;
assign bus.packet_size             =packet_size             ;
assign bus.en_clock_strech         =en_clock_strech         ;
assign bus.TX_fifo_empty           =TX_fifo_empty           ;
assign bus.RX_fifo_full            =RX_fifo_full            ;
assign bus.RX_fifo_almost_full     =RX_fifo_almost_full     ;
assign bus.transaction_begin       =transaction_begin       ;
assign bus.SDA_sync                =SDA_sync                ;
assign bus.SCL_sync                =SCL_sync                ;
assign bus.clk_divider             =clk_divider             ;

assign rx_data_master=                 bus.rx_data_master;
assign set_transaction_complete_master=bus.set_transaction_complete_master;
assign set_arbitration_lost=           bus.set_arbitration_lost;
assign ack_error_set_master=           bus.ack_error_set_master;
assign transaction_begin_clear=        bus.transaction_begin_clear;
assign busy_master=                    bus.busy_master;
assign TX_read_enable_master=          bus.TX_read_enable_master;
assign RX_write_enable_master=         bus.RX_write_enable_master;
assign SDA_out_master=                 bus.SDA_out_master;
assign SCL_out_master=                 bus.SCL_out_master;
assign line_busy=                      bus.line_busy;              

endmodule 
