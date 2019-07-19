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

module byte_counter 
#(parameter BITS = 6)
(
	input clk, n_rst, decrement, load_buffer, [BITS-1:0] packet_length,
	output zero, one
);

//Note, a packet length of zero actual means a length of 2^(BITS)
logic [BITS:0] count, next_count;
logic [BITS:0] load_value;
assign load_value = packet_length==32'b0 ? 32'b1<<(BITS) : {1'b0,packet_length};

//Next state logic
//=====================================================================
always_comb begin
	if(load_buffer)
		next_count = load_value;
	else if(decrement)
		next_count = count-1;
	else
		next_count = count;
end

//State Register
//=====================================================================
always_ff @(posedge clk, negedge n_rst) begin
	if(!n_rst)
		count<=0;
	else
		count<=next_count;
end

//Output Logic
//=====================================================================
assign zero = (count==0);
assign one = (count==1);

endmodule
