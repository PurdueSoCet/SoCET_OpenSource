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

`timescale 1ns / 100ps
module tb_byte_counter();
//parameters
localparam CLOCK_PERIOD = 15ns;

//variables
logic tb_clk, tb_n_rst, tb_decrement, tb_load_buffer;
logic [5:0] tb_packet_length;
logic tb_zero;

//run clock
always begin
	tb_clk=0;
	#(CLOCK_PERIOD/2.0);
	tb_clk=1;
	#(CLOCK_PERIOD/2.0);
end

//tasks
task reset();
	tb_decrement=0;
	tb_load_buffer=0;
	@(negedge tb_clk);
	tb_n_rst=0;
	@(negedge tb_clk);
	tb_n_rst=1;
endtask

task countDown(logic [5:0] length);
	integer i;
	integer len;
	len = (length == 0) ? 64 : length;
	tb_packet_length = length;
	reset();

	tb_load_buffer = 1;
	@(negedge tb_clk);
	tb_load_buffer=0;

	for (i=len; i>0;i--) begin
		assert(!tb_zero) else
			$error("Counter reached zero too soon!");
		@(negedge tb_clk);
		tb_decrement=1;
		@(negedge tb_clk);
		tb_decrement=0;
		@(negedge tb_clk);
	end
		assert(tb_zero) else
			$error("Counter didn't reach zero!");
endtask

//Hook up DUT
byte_counter DUT(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.decrement(tb_decrement),
	.load_buffer(tb_load_buffer),
	.packet_length(tb_packet_length),
	.zero(tb_zero)
);

initial begin
	integer i;
	for(i=0;i<64;i++)
		countDown(i);
	$info("Testbench complete!");
end

endmodule
