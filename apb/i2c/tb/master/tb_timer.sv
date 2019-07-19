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

`include "i2c.vh"
`timescale 1ns / 100ps
module tb_timer();

//Parameters
localparam CLOCK_PERIOD = 15ns;
localparam STANDARD_MODE = 300;
localparam FAST_MODE = 60;
localparam FAST_MODE_PLUS = 24;

//Signals
logic tb_clk, tb_n_rst, tb_SDA_sync, tb_SCL_sync, tb_SDA_out;
logic[31:0] tb_clock_div;
DataDirection tb_direction;
logic tb_SCL_out, tb_shift_strobe, tb_byte_complete, tb_ack_gen, tb_ack, tb_abort, tb_timer_active;
logic tb_should_nack;
integer strobe_count;

logic SCL_other, SDA_other; //Simulate the behavior of another device on the bus
logic SCL, SDA;	//Actual bus lines
logic abort_asserted;

logic [7:0] shift_data;

//Bus simulation
//=====================================================================
logic SCL_buffered;
always @(posedge tb_clk, negedge tb_n_rst) begin
	if(!tb_n_rst)
		SCL_buffered = 0;
	else
		SCL_buffered = tb_SCL_out;
end

assign SCL = SCL_other & SCL_buffered;
assign SDA = SDA_other & tb_SDA_out;
sync_high SDA_SYNC (tb_clk, tb_n_rst, SDA, tb_SDA_sync);
sync_high SCL_SYNC (tb_clk, tb_n_rst, SCL, tb_SCL_sync);
	
//Begin clock
//=====================================================================
always begin
	tb_clk=0;
	#(CLOCK_PERIOD/2.0);
	tb_clk=1;
	#(CLOCK_PERIOD/2.0);
end

//Hook up DUT
//=====================================================================
timer DUT(
	.clk(tb_clk),
	.n_rst(tb_n_rst),
	.clock_div(tb_clock_div),
	.direction(tb_direction),
	.should_nack(tb_should_nack),
	.SDA_sync(tb_SDA_sync),
	.SCL_sync(tb_SCL_sync),
	.SDA_out(tb_SDA_out),
	.SCL_out(tb_SCL_out),
	.shift_strobe(tb_shift_strobe),
	.byte_complete(tb_byte_complete),
	.ack_gen(tb_ack_gen),
	.ack(tb_ack),
	.abort(tb_abort),
	.timer_active(tb_timer_active)
);

//Helper hardware
//=====================================================================
//Count shifts
always @(posedge tb_clk) begin
	if (tb_shift_strobe)
		strobe_count++;
end

//Emulate shift register operation
assign tb_SDA_out = tb_direction==TX ? shift_data[7] : !tb_ack_gen;
always @(posedge tb_clk) begin
	if(tb_shift_strobe)
		shift_data = shift_data<<1;
end
always @(posedge tb_clk, negedge tb_n_rst) begin
	if(!tb_n_rst)
		abort_asserted=0;
	else if(tb_abort)
		abort_asserted=1;
end
//Tasks
//=====================================================================
//Reset the DUT
task reset();
	strobe_count=0;
	SDA_other=1;
	SCL_other=1;
	tb_timer_active=0;
	@(negedge tb_clk);
	@(negedge tb_clk);
endtask

task delay(integer cycles);
	integer i;
	for(i=0;i<cycles;i++) begin
		@(posedge tb_clk);
	end
	@(negedge tb_clk);
endtask


//Start the timer to run in RX or TX and make sure the correct signals are asserted
task startTimer(input	DataDirection dir,
			logic[31:0] clock_div,
			logic [7:0] data,
			logic should_nack=0,
			logic should_abort=0
		);

	integer i;
	abort_asserted=0;
	shift_data=data;
	tb_clock_div = clock_div;
	tb_direction = dir;
	tb_should_nack=should_nack;
	@(negedge tb_clk);
	tb_timer_active=1;
	//Now we wait for the appropriate signals and ensure that they happen at the same time
	fork
	begin
		@(posedge abort_asserted); //Quit if abort asserted
		assert(should_abort) else
			$error("Aborted transmission when shouldn't have!");
	end
	begin
	if(dir==RX) begin
		for(i=1;i<=9;i++) begin
			@(posedge SCL);
			assert(strobe_count==i-1) else
				$error("Incorrect # of strobes detected, detected %d expected %d",strobe_count, i-1);
		end
		if(!should_nack) begin
			assert(tb_ack_gen) else
				$error("No ack generated in RX mode");
		end else begin
			assert(!tb_ack_gen) else
				$error("ACK generated when NACK expected!");
		end
		@(negedge SCL);
	end else begin
		for(i=1;i<=9;i++) begin
			@(posedge SCL);
			assert(strobe_count==i-1) else
				$error("Incorrect # of strobes detected");
		end
		@(negedge SCL);
		assert(!should_abort) else
			$error("Failed to abort when should have!");
	end
	@(posedge tb_byte_complete);
	end	
	join_any
	disable fork;
endtask


//Drive the clock as in a two master system.  Drive SDA and SCL as well
//register SCL coming from timer

task driveWave(input integer half_period, logic[7:0] data);
	integer i;
	for(i=7;i>=0;i--) begin
		SCL_other=0;
		SDA_other = data[i];
		delay(half_period);
		SCL_other=1;
		if(!SCL)
			@(posedge SCL);
		fork
			delay(half_period);
			@(negedge SCL);
		join_any
		disable fork;
	end
	SDA_other=1;
	@(negedge tb_clk);
	
endtask


//Main block
//=====================================================================
initial begin
	//Try each mode without interference
	tb_n_rst=0;
	reset();
	tb_n_rst=1;
	startTimer(RX,STANDARD_MODE,255);
	reset();
	startTimer(RX,FAST_MODE,255, .should_nack(1));
	reset();
	startTimer(RX,FAST_MODE_PLUS,255);
	reset();
	startTimer(TX,STANDARD_MODE,8'b00110011);
	reset();
	startTimer(TX,FAST_MODE,8'b11001010);
	reset();
	startTimer(TX,FAST_MODE_PLUS,8'b11000101);
	reset();

	//Drive faster wave with slow speed
	fork
		startTimer(TX,STANDARD_MODE,8'b00001111, .should_abort(1));
		driveWave(FAST_MODE, 8'b11110000);
	join
	assert(tb_abort) else
		$error("Timer failed to abort during dual transfer!");

	//Drive slower wave with fast bus speed
	reset();
	fork
		startTimer(TX,FAST_MODE_PLUS,8'b00001111, .should_abort(1));
		driveWave(STANDARD_MODE, 8'b11110000);
	join
	assert(tb_abort) else
		$error("Timer failed to abort during dual transfer!");

	$info("Testbench complete!");

	
end
endmodule
