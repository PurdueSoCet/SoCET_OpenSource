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

// $Id: $
// File name:   sync_low.sv
// Created:     1/27/2016
// Author:      Sam Sowell
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Logic Low Synchronizer
module sync_low
(
  input wire clk,
  input wire n_rst,
  input wire async_in,
  output reg sync_out
);

reg sync;

always_ff @ (posedge clk, negedge n_rst)
begin
  if (1'b0 == n_rst)
  begin
    sync_out <= 1'b0;
    sync <= 1'b0;
  end
  else
  begin
    sync <= async_in;
    sync_out <= sync;
  end
end

endmodule
