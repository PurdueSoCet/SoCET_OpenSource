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

`include "apb_if.vh"
`include "i2c_if.vh"
module i2c_wrapper(
	input clk, n_rst,
	input SDA, SCL,
	input PWRITE, PENABLE, PSEL,
	input [31:0] PWDATA, PADDR,
	output [31:0] PRDATA,
	output SDA_out, SCL_out, interrupt
);

i2c_if i2c();
apb_if apb_s();

// Assign i2c signals
assign i2c.SDA       = SDA;
assign i2c.SCL       = SCL;
assign SDA_out   = i2c.SDA_out;
assign SCL_out   = i2c.SCL_out;
assign interrupt = i2c.interrupt;

// Assign apb signals
assign apb_s.PENABLE = PENABLE;
assign apb_s.PSEL    = PSEL;
assign apb_s.PWRITE  = PWRITE;
assign PRDATA  = apb_s.PRDATA;
assign apb_s.PWDATA  = PWDATA;
assign apb_s.PADDR = PADDR;

i2c IX (
	.clk(clk),
	.n_rst(n_rst),
	.apb_bus(apb_s.apb_s),
	.i2c(i2c.i2c)
);

endmodule
