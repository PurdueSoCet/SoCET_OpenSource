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

// File name:   Fifo_wrapper.sv
// Created:     7/24/2014
// Author:      Xin Tze Tee
// Version:     1.0 
// Description: Wrapper for Fifo.

module Fifo_wrapper
#(
	parameter regWidth = 8,
	parameter addrSize = 3
)
(
	input wire clk, n_rst,
	input wire wEnable,
	input wire rEnable,
	input wire [regWidth - 1:0] wData,
	output wire [regWidth - 1:0] rData,
	output wire fifoEmpty,
	output wire fifoFull
);

wire [addrSize - 1:0] wptr, rptr;

FifoWriteCtr FifoWriteCtr
(
	.clk(clk), .n_rst(n_rst),
	.wEnable(wEnable),
	.wptr(wptr)
);

FifoRegFile FifoRegFile
(
	.clk(clk), .n_rst(n_rst),
	.wEnable(wEnable),
	.wData(wData),
	.wptr(wptr),
	.rptr(rptr),
	.rData(rData),
	.fifoEmpty(fifoEmpty),
	.fifoFull(fifoFull)
);

FifoReadCtr FifoReadCtr
(
	.clk(clk), .n_rst(n_rst),
	.rEnable(rEnable),
	.wEnable(wEnable),
	.fifoEmpty(fifoEmpty),
	.fifoFull(fifoFull),
	.rptr(rptr)
);

endmodule

