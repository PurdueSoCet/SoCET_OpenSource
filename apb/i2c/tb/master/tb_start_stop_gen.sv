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

//`include "i2c.vh"
module tb_start_stop_gen();

//parameters
localparam CLOCK_PERIOD = 	15ns;
localparam STANDARD_DELAY = 	300;
localparam FAST_DELAY = 	90;
localparam FAST_PLUS_DELAY = 	36;

//Variables
logic	tb_clk;
logic	tb_n_rst;
logic	tb_busy;
logic	tb_start;
logic	tb_stop;
logic	tb_done;
logic	tb_SDA;
logic	tb_SCL;
logic[31:0] tb_clock_div;

//Begin clock
always begin
	tb_clk=0;
	#(CLOCK_PERIOD/2.0);
	tb_clk=1;
	#(CLOCK_PERIOD/2.0);
end

//DUT
start_stop_gen DUT(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.bus_busy(tb_busy),
	.start(tb_start),
	.stop(tb_stop),
	.clock_div(tb_clock_div),
	.SDA(tb_SDA),
	.SCL(tb_SCL),
	.done(tb_done)
);

//Tasks
task reset();
	@(negedge tb_clk);
	tb_start=0;
	tb_stop=0;
	@(negedge tb_clk);
endtask

task testStart(input integer delay, input logic busy);
	integer i;
	tb_clock_div = delay;
	tb_busy = busy;
	reset();

	//Check that idle state is correct
	assert(tb_SDA==1) else
		$error("SDA should be high in IDLE state");
	assert(tb_SCL==!busy) else
		$error("SCL doesn't match busy in idle state!");
	assert(!tb_done) else
		$error("Done asserted during IDLE state!");

	//Check that subsequent state are correct
	tb_start=1;
	for(i=0;i<delay;i++) begin
		@(negedge tb_clk);
		assert(tb_SDA==1 && tb_SCL==1) else
			$error("START1 does not output correctly");
		assert(!tb_done) else
			$error("START1 done signal asserted too early!");
	end
	for(i=0;i<delay;i++) begin
		@(negedge tb_clk);
		assert(tb_SDA==0 && tb_SCL==1) else
			$error("START2 does not output correctly");
		assert(!tb_done) else
			$error("START2 done signal asserted too early!");
	end
	for(i=0;i<delay;i++) begin
		@(negedge tb_clk);
		assert(tb_SDA==0 && tb_SCL==0) else
			$error("START3 does not output correctly");
		assert(!tb_done) else
			$error("START3 done signal asserted too early!");
	end
	for(i=0;i<delay;i++) begin
		@(negedge tb_clk);
		assert(tb_SDA==0 && tb_SCL==0) else
			$error("START_DONE does not output correctly");
		assert(tb_done) else
			$error("START_DONE done not asserted!");
	end
	reset();
	//Check that idle state is correct
	assert(tb_SDA==1) else
		$error("SDA should be high in IDLE state");
	assert(tb_SCL==!busy) else
		$error("SCL doesn't match busy in idle state!");
	assert(!tb_done) else
		$error("Done asserted during IDLE state!");
	
endtask

task testStop(input integer delay, input logic busy);
	integer i;
	tb_clock_div = delay;
	tb_busy = busy;
	reset();

	//Check that idle state is correct
	assert(tb_SDA==1) else
		$error("SDA should be high in IDLE state");
	assert(tb_SCL==!busy) else
		$error("SCL doesn't match busy in idle state!");
	assert(!tb_done) else
		$error("Done asserted during IDLE state!");

	//Check that subsequent state are correct
	tb_stop=1;
	for(i=0;i<delay;i++) begin
		@(negedge tb_clk);
		assert(tb_SDA==0 && tb_SCL==0) else
			$error("STOP1 does not output correctly");
		assert(!tb_done) else
			$error("STOP1 done signal asserted too early!");
	end
	for(i=0;i<delay;i++) begin
		@(negedge tb_clk);
		assert(tb_SDA==0 && tb_SCL==1) else
			$error("STOP2 does not output correctly");
		assert(!tb_done) else
			$error("STOP2 done signal asserted too early!");
	end
	for(i=0;i<delay;i++) begin
		@(negedge tb_clk);
		assert(tb_SDA==1 && tb_SCL==1) else
			$error("STOP does not output correctly");
		assert(!tb_done) else
			$error("STOP done signal asserted too early!");
	end
	for(i=0;i<delay;i++) begin
		@(negedge tb_clk);
		assert(tb_SDA==1 && tb_SCL==1) else
			$error("STOP_DONE does not output correctly");
		assert(tb_done) else
			$error("STOP_DONE done not asserted!");
	end
	reset();
	//Check that idle state is correct
	assert(tb_SDA==1) else
		$error("SDA should be high in IDLE state");
	assert(tb_SCL==!busy) else
		$error("SCL doesn't match busy in idle state!");
	assert(!tb_done) else
		$error("Done asserted during IDLE state!");
	
endtask
initial begin
	tb_n_rst=0;
	@(negedge tb_clk);
	@(negedge tb_clk);
	tb_n_rst=1;
	testStart(STANDARD_DELAY, 0);
	testStart(STANDARD_DELAY, 1);
	testStart(FAST_DELAY, 0);
	testStart(FAST_DELAY, 1);
	testStart(FAST_PLUS_DELAY, 0);
	testStart(FAST_PLUS_DELAY, 1);

	testStop(STANDARD_DELAY, 0);
	testStop(STANDARD_DELAY, 1);
	testStop(FAST_DELAY, 0);
	testStop(FAST_DELAY, 1);
	testStop(FAST_PLUS_DELAY, 0);
	testStop(FAST_PLUS_DELAY, 1);

	$info("Testbench complete!");
end
endmodule
