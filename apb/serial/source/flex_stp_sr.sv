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

// File name:   flex_stp_sr.sv
// Created:     2/9/2014
// Author:      Xin Tze Tee
// Version:     1.0  Initial Design Entry
// Description: Serial to Parallel Shift Register

module flex_stp_sr
  #(
  parameter NUM_BITS = 4,
  parameter SHIFT_MSB = 1
  )
  (
  input wire n_rst, // active low reset
  input wire clk,
  input wire shift_enable,
  input wire serial_in,
  output reg [NUM_BITS - 1:0] parallel_out
  );
  
  
  generate
    if(SHIFT_MSB)
      
      always @ (posedge clk, negedge n_rst)
      begin
        
        if (1'b0 == n_rst)
          begin
            parallel_out <= 2 ** NUM_BITS - 1;
          end
        else if (1'b1 == shift_enable)
          begin
            parallel_out <= {parallel_out[NUM_BITS - 2:0], serial_in}; 
          end
        else 
          begin
            parallel_out <= parallel_out;
          end
          
        end
        
    else 
        
          always @ (posedge clk, negedge n_rst)
      begin
       
        if (1'b0 == n_rst)
          begin
            parallel_out <= 2 ** NUM_BITS - 1;
          end
        else if (1'b1 == shift_enable)
          begin
            parallel_out <= {serial_in, parallel_out[NUM_BITS - 1:1]}; 
          end
        else 
          begin
            parallel_out <= parallel_out;
          end
          
        end
        
  endgenerate
        
endmodule
