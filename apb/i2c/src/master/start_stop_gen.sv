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
module start_stop_gen(
	input clk, n_rst, bus_busy, start, stop, logic[31:0] clock_div,
	output logic SDA, SCL, done
);

localparam COUNTER_BITS = 9;	// ceil(log2(STANDARD_DELAY+1))

typedef enum bit[4:0] {
	IDLE_NOT_BUSY,	//The line is busy and the module is not active
	IDLE_BUSY,	//The line is not busy and is not active
	START1,		//Sequence to send start or repeated start condition
	START2,
	START3,
	START_DONE,
	STOP1,		//Sequence to send stop condition
	STOP2,
	STOP3,
	STOP_DONE
} StateType;

logic enabled, wait_expired;
StateType state, next_state;
assign enabled = start | stop; //Is the unit doing something?


//Include flex counter
//=====================================================================
flex_counter #(32) counter (
	.clk(clk),
	.n_rst(n_rst),
	.rollover_val(clock_div),
	.rollover_flag(wait_expired),
	.count_enable(enabled),
	.clear(!enabled)
);

//Next state logic
//=====================================================================
always_comb begin
	next_state = state;	//Default behavior, do not change state
	case(state)
		IDLE_NOT_BUSY: begin
			if (start)
				next_state = START1;
			else if (stop)
				next_state = STOP1;
			else if(bus_busy)
				next_state = IDLE_BUSY;
		end
		IDLE_BUSY: begin
			if (start)
				next_state = START1;
			else if (stop)
				next_state = STOP1;
			else if(!bus_busy)
				next_state = IDLE_NOT_BUSY;
		end
		START1:	next_state = wait_expired ? START2 : START1;
		START2:next_state = wait_expired ? START3 : START2;
		START3:next_state = wait_expired ? START_DONE : START3;
		STOP1:next_state = wait_expired ? STOP2 : STOP1;
		STOP2:next_state = wait_expired ? STOP3 : STOP2;
		STOP3:next_state = wait_expired ? STOP_DONE : STOP3;
	endcase

	//Override case statement if not enabled
	if(!enabled & bus_busy)
		next_state = IDLE_BUSY;
	else if(!enabled & !bus_busy)
		next_state = IDLE_NOT_BUSY;
end

//State register
//=====================================================================
always_ff @(posedge clk, negedge n_rst) begin
	if(!n_rst)
		state <= IDLE_NOT_BUSY;
	else
		state <= next_state;
end

//Output logic
//=====================================================================
always_comb begin
	//Default values
	SDA = 1;
	SCL = 1;
	done = 0;
	
	case(state)
		IDLE_NOT_BUSY:	begin SDA=1; SCL=1; done=0; end
		IDLE_BUSY:	begin SDA=1; SCL=0; done=0; end

		START1:		begin SDA=1; SCL=1; done=0; end
		START2:		begin SDA=0; SCL=1; done=0; end
		START3:		begin SDA=0; SCL=0; done=0; end
		START_DONE:	begin SDA=0; SCL=0; done=1; end

		STOP1:		begin SDA=0; SCL=0; done=0; end
		STOP2:		begin SDA=0; SCL=1; done=0; end
		STOP3:		begin SDA=1; SCL=1; done=0; end
		STOP_DONE:	begin SDA=1; SCL=1; done=1; end
	endcase
end



	
endmodule
