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

module checker
(
  input clk,
  input n_rst,
	input	SDA_sync,
	input	SCL_sync,
	input	[7:0] RX_data,
	input	[9:0] bus_address,
	output	bus_busy
);

typedef enum bit[1:0]{
	IDLE,
	ALMOST_BUSY,
	BUSY,
	ALMOST_IDLE
}	StateType;

StateType state, nextState;

//Next state logic
//=====================================================================
always_comb begin
	nextState = state;	//Default case
	case(state)
		IDLE: nextState = (SCL_sync & !SDA_sync) ? ALMOST_BUSY : IDLE;
		ALMOST_BUSY: begin
			if(SDA_sync)
				nextState = IDLE;
			if(!SDA_sync & !SCL_sync)
				nextState = BUSY;
		end
		BUSY: nextState = (SCL_sync& !SDA_sync) ? ALMOST_IDLE : BUSY;
		ALMOST_IDLE: begin
			if(!SCL_sync)
				nextState = BUSY;
			if(SCL_sync & SDA_sync)
				nextState = IDLE;
		end
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
assign bus_busy = (state !=IDLE);
endmodule
