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
module tb_busy_tester();

//Test bench parameters
parameter CLOCK_PERIOD = 15ns;
	
//Test bench variables
logic tb_clk, tb_n_rst, tb_SDA, tb_SCL, tb_bus_busy;

//Drive clock
always begin
	tb_clk=0;
	#(CLOCK_PERIOD/2.0);
	tb_clk=1;
	#(CLOCK_PERIOD/2.0);
end

//Design under test
busy_tester DUT(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.SDA_sync(tb_SDA),
	.SCL_sync(tb_SCL),
	.bus_busy(tb_bus_busy)
);

//Task to drive a value on the bus
task outputValue(input logic val);
	tb_SDA=val;
	@(negedge tb_clk);
	tb_SCL=1;
	@(negedge tb_clk);
	tb_SCL=0;
	@(negedge tb_clk);
endtask

initial begin
	//Initialize
	tb_n_rst=0;
	tb_SDA=1;
	tb_SCL=1;
	@(negedge tb_clk);
	@(negedge tb_clk);
	tb_n_rst=1;
	@(negedge tb_clk);

	//Test 1, make sure that it resets to the proper state
	assert(!tb_bus_busy) else
		$error("Busy signal asserted after reset!");
	
	@(negedge tb_clk);
	@(negedge tb_clk);
	@(negedge tb_clk);

	//Test 2 make sure it stays unasserted after a period of time
	assert(!tb_bus_busy) else
		$error("Busy signal asserted when there is not start condition");
	//Test 3, put a start condition on the bus, and make sure it shows as busy
	tb_SDA=0;
	@(negedge tb_clk);
	assert(tb_bus_busy) else
		$error("busy signal not asserted in time after start condition");
	@(negedge tb_clk);
	@(negedge tb_clk);

	//Test 4 make sure it stays asserted at end of start
	tb_SCL=0;
	@(negedge tb_clk);
	assert(tb_bus_busy) else
		$error("Busy signal not asserted at end of start condition");

	//Test 5, make sure busy is asserted through duration of data transfer
	fork
	begin
		outputValue(0);
		outputValue(1);
		outputValue(0);
		outputValue(0);
		outputValue(1);
		outputValue(1);
	end
	begin
		@(tb_bus_busy);
		$error("Busy flag changed during data transfer");
	end
	join_any
	disable fork;
	tb_SDA=0;
	tb_SCL=0;
	@(negedge tb_clk);
	@(negedge tb_clk);
	
	//Test 6, make sure busy is asserted through stop condition
	tb_SCL=1;
	@(negedge tb_clk);
	@(negedge tb_clk);
	assert(tb_bus_busy) else
		$error("Busy flag released during stop condition");

	//Test 7 make sure busy is not asserted after stop condition
	tb_SDA=1;
	@(negedge tb_clk);
	assert(!tb_bus_busy) else
		$error("Busy flag asserted after stop condition");

	$info("Testbench complete!");

end	
	
endmodule
