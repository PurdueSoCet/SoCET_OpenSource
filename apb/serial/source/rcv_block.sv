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

// File name:   rcv_block.sv
// Updated:     03/01/2016
// Author:      Xin Tze Tee and Travis Garza
// Version:     1.0  Initial Design Entry
// Description: UART Receiver Block (top-level)

module rcv_block
  (
   input wire clk,
   input wire n_rst,
   input wire serial_in,
   input wire data_read,
   input reg [31:0] baudData,
   output reg [7:0] rx_data,
   output reg data_ready,
   output reg overrun_error,
   output reg error_flag
   );


   wire [7:0] packet_data;
   wire       stop_bit;
   wire       start_bit_detected;
   wire       packet_done;
   wire       sbc_clear;
   wire       sbc_enable;
   wire       load_buffer;
   wire       enable_timer;
   wire       shift_strobe;
      
      
	  
   rx_data_buff BUFF
     (
      .clk(clk),
      .n_rst(n_rst),
      .load_buffer(load_buffer),
      .packet_data(packet_data),
      .data_read(data_read),
      .rx_data(rx_data),
      .data_ready(data_ready),
      .overrun_error(overrun_error)
      );

   rcv_ctrl CON
     (
      .clk(clk),
      .n_rst(n_rst),
      .start_bit_detected(start_bit_detected),
      .packet_done(packet_done),
      .error_flag(error_flag),
      .sbc_clear(sbc_clear),
      .sbc_enable(sbc_enable),
      .load_buffer(load_buffer),
      .enable_timer(enable_timer)
      );

   serial_rcv_timer TIM
     (
      .clk(clk),
      .n_rst(n_rst),
      .enable_timer(enable_timer),
      .baudData(baudData),
      .shift_strobe(shift_strobe),
      .packet_done(packet_done)
      );

   sr_9bit SHIT
     (
      .clk(clk),
      .n_rst(n_rst),
      .shift_strobe(shift_strobe),
      .serial_in(serial_in),
      .packet_data(packet_data),
      .stop_bit(stop_bit)
      );

   
   stopbit_check STOP
     (
      .clk(clk),
      .n_rst(n_rst),
      .sbc_clear(sbc_clear),
      .sbc_enable(sbc_enable),
      .stop_bit(stop_bit),
      .error_flag(error_flag)
      );

   startbit_detect START
     (
      .clk(clk),
      .n_rst(n_rst),
      .serial_in(serial_in),
      .start_bit_detected(start_bit_detected)
      );
   


endmodule // rcv_block


   
   
   
   

   
   
   
