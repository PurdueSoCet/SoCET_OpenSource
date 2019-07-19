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

// File name:   sr_9bit.sv
// Created:     2/23/2014
// Author:      Xin Tze Tee
// Version:     1.0  Initial Design Entry
// Description: 9-Bit Shift Register

module sr_9bit
  (
   input wire clk,
   input wire n_rst,
   input wire shift_strobe,
   input wire serial_in,
   output wire [7:0] packet_data,
   output wire stop_bit
   );

   reg [8:0] packet;
   
   defparam SR.NUM_BITS = 9;
   defparam SR.SHIFT_MSB = 0;

   
   assign packet_data = packet[7:0];
   assign stop_bit = packet[8];
   

   flex_stp_sr SR(n_rst,clk,shift_strobe,serial_in,packet);
   
endmodule // sr_9bit
