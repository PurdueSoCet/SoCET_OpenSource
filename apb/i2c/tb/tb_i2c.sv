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
//`include "i2c.vh"
`include "i2c_if.vh"

`timescale 1ns / 100ps

module tb_i2c();

reg tb_clk;
reg tb_n_rst;
apb_if apb_bus();
i2c_if i2c();


i2c DUT(tb_clk, tb_n_rst, apb_bus.apb_s, i2c.i2c);
initial begin
	$info("Test bench complete!");
end

endmodule
