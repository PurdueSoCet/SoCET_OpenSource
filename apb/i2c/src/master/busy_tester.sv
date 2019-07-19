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

//This module is to detect whether the i2c bus is currently busy, whether it
//be our i2c module that is using, or some other external module.
module busy_tester(
	input	clk, n_rst, SDA_sync, SCL_sync,
	output	bus_busy
);

typedef enum bit[2:0]{
	IDLE = 3'b000,		
	ALMOST_BUSY = 3'b001,
	ALMOST_BUSY2 =3'b010,
	BUSY =3'b100,
	ALMOST_IDLE=3'b101,
	ALMOST_IDLE2=3'b110
}	StateType;

StateType state, nextState;

//Next state logic
//=====================================================================
always_comb begin
	nextState = state;	//Default case
	case(state)
		IDLE: nextState = (SCL_sync & SDA_sync) ? ALMOST_BUSY : IDLE;
		ALMOST_BUSY: begin
			if(SCL_sync & SDA_sync)
				nextState = ALMOST_BUSY;
			else if(SCL_sync & !SDA_sync)
				nextState = ALMOST_BUSY2;
			else
				nextState = IDLE;
		end
		ALMOST_BUSY2: nextState = (SCL_sync & !SDA_sync) ? BUSY : IDLE;

		BUSY: nextState = (SCL_sync& !SDA_sync) ? ALMOST_IDLE : BUSY;
		ALMOST_IDLE: begin
			if(SCL_sync & !SDA_sync)
				nextState = ALMOST_IDLE;
			else if (SCL_sync & SDA_sync)
				nextState = ALMOST_IDLE2;
			else
				nextState = BUSY;
		end
		ALMOST_IDLE2: nextState = (SCL_sync & SDA_sync) ? IDLE : BUSY;
	endcase
end

//State Register
//=====================================================================
always_ff @(posedge clk, negedge n_rst) begin
	if(!n_rst)
		state <= IDLE;
	else
		state <= nextState;
end

//Output logic
//=====================================================================
assign bus_busy = state[2];
//The values used to represent each state were carefully selected so that
//the states that should output bus_busy=1 are represented by state=1xx and
//states that should output bus_busy=0 are represented by state=0xx.  This saves
//output combinatorial logic and ensures the output is registered.
endmodule
