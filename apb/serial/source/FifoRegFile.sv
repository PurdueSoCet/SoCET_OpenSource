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

// File name:   FifoRegFile.sv
// Created:     7/24/2014
// Author:      Xin Tze Tee
// Version:     1.0  
// Description: Fifo Register File (supports overwrite)

module FifoRegFile
#(
	parameter regLength = 8,
	parameter regWidth = 8,
	parameter addrSize = 3
)
(
	input wire clk, n_rst,
	input wire wEnable,
	input wire [regWidth - 1:0] wData,
	input wire [addrSize - 1:0] wptr,
	input wire [addrSize - 1:0] rptr,
	output wire [regWidth - 1:0] rData,
	output wire fifoEmpty,
	output wire fifoFull
);

// Register File
reg [1:regLength] [regWidth - 1:0] RegFileData, next_RegFileData;
reg fifoEmpty_reg, next_fifoEmpty_reg;
reg fifoFull_reg, next_fifoFull_reg;
integer i;

always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		for (i = 1; i <= (regLength); i++) begin
			RegFileData[i] = '0;
		end
		fifoEmpty_reg = 1;
		fifoFull_reg = 0;
	end else begin
		RegFileData = next_RegFileData;
		fifoEmpty_reg = next_fifoEmpty_reg;
		fifoFull_reg = next_fifoFull_reg;
	end
end

always_comb
begin
	if (wptr == (rptr+1)%regLength) begin
		next_fifoEmpty_reg = 1;
	end else begin
		next_fifoEmpty_reg = 0;
	end
	if (rptr == wptr) begin
		next_fifoFull_reg = 1;
	end else begin
		next_fifoFull_reg = 0;
	end
	if (wEnable == 1) begin
		next_RegFileData[wptr+1] = wData; 
	end else begin
		next_RegFileData = RegFileData;
	end
end

assign rData = RegFileData[rptr+1];
assign fifoEmpty = fifoEmpty_reg;
assign fifoFull = fifoFull_reg;

endmodule
