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

module fp_fifo
(
	input wire [7:0] w_data,
	input wire w_enable,
	input wire r_enable,
	input wire r_clk,
	input wire w_clk,
	input wire n_rst,
  input wire clear,
	output reg [7:0] r_data,
	output reg full,
	output reg empty
	//output reg almost_full
);

// Declarations for Overall FIFO
reg w_ena;
reg r_ena;
reg [3:0] w_ptr;
reg [3:0] r_ptr;
reg [7:0] ss;
reg [7:0] ram_data;
reg [3:0] next_ptr;
reg write;
//reg temp_ptr;

// Declarations for registers
wire [7:0] data1;
wire [7:0] data2;
wire [7:0] data3;
wire [7:0] data4;
wire [7:0] data5;
wire [7:0] data6;
wire [7:0] data7;
wire [7:0] data8;
reg en_1, en_2, en_3, en_4, en_5, en_6, en_7, en_8;

// Write Enable Logic
always_comb
begin
	if(w_enable) begin
		if(full) begin
			w_ena = 1'b0;
		end else begin
			w_ena = 1'b1;
		end
	end else begin
		w_ena = 1'b0;
	end
end

// Read Enable Logic
always_comb
begin
	if(r_enable) begin
		if(empty) begin
			r_ena = 1'b0;
		end else begin
			r_ena = 1'b1;
		end
	end else begin
		r_ena = 1'b0;
	end
end

// Write Pointer Counter
flex_counter IX (
	.clk(w_clk),
	.n_rst(n_rst),
	.clear(clear), 
	.count_enable(w_ena),
	.count_out(w_ptr),
	.rollover_val(4'd15)
);

// Read Pointer Counter
flex_counter IX1 (
	.clk(r_clk),
	.n_rst(n_rst),
	.clear(clear),
	.count_enable(r_ena),
	.count_out(r_ptr),
	.rollover_val(4'd15)
);

// Full Logic
always_comb
begin
	//if(w_ptr == r_ptr) begin
		full = 1'b1;
	//end else begin
	//	full = 1'b0;
	//end
end

// Empty Logic
always_comb
begin
	if(w_ptr[2:0] == r_ptr[2:0]) begin
		empty = 1'b1;
	end else begin
		empty = 1'b0;
	end
end

// Almost Full Logic
/*always_comb
begin
	temp_ptr = w_ptr[2:0] + 1'b1;
	if(temp_ptr == r_ptr[2:0]) begin
		almost_full = 1'b1;
	end else begin
		almost_full = 1'b0;
	end
end*/

// Edge Detector
always_ff @(posedge w_clk, negedge n_rst)
begin
	if(0 == n_rst) begin
		next_ptr <= '0;
	end else begin
		next_ptr <= w_ptr;
	end
end

always_comb
begin
	write = !(next_ptr & w_ptr);
end

// Ram Input Logic
always_comb
begin
	if(write != 0) begin
		case(w_ptr[2:0])
			3'd0: begin
				en_1 = 1'b1;
			end
			3'd1: begin
				en_2 = 1'b1;
			end
			3'd2: begin
				en_3 = 1'b1;
			end
			3'd3: begin
				en_4 = 1'b1;
			end
			3'd4: begin
				en_5 = 1'b1;
			end
			3'd5: begin
				en_6 = 1'b1;
			end
			3'd6: begin
				en_7 = 1'b1;
			end
			3'd7: begin
				en_8 = 1'b1;
			end
			default: begin
				en_1 = 1'b0;
				en_2 = 1'b0;
				en_3 = 1'b0;
				en_4 = 1'b0;
				en_5 = 1'b0;
				en_6 = 1'b0;
				en_7 = 1'b0;
				en_8 = 1'b0;
			end
		endcase
	end else begin
		en_1 = 1'b0;
		en_2 = 1'b0;
		en_3 = 1'b0;
		en_4 = 1'b0;
		en_5 = 1'b0;
		en_6 = 1'b0;
		en_7 = 1'b0;
		en_8 = 1'b0;
	end
end

// Shift Register 1
p2p IX3 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(en_1),
	.data_in(w_data),
	.data_out(data1)
);

// Shift Register 2
p2p IX4 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(en_2),
	.data_in(ram_data),
	.data_out(data2)
);

// Shift Register 3
p2p IX5 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(en_3),
	.data_in(ram_data),
	.data_out(data3)
);

// Shift Register 4
p2p IX6 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(en_4),
	.data_in(ram_data),
	.data_out(data4)
);

// Shift Register 5
p2p IX7 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(en_5),
	.data_in(ram_data),
	.data_out(data5)
);

// Shift Register 6
p2p IX8 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(en_6),
	.data_in(ram_data),
	.data_out(data6)
);

// Shift Register 7
p2p IX9 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(en_7),
	.data_in(ram_data),
	.data_out(data7)
);

// Shift Register 8
p2p IX10 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(en_8),
	.data_in(ram_data),
	.data_out(data8)
);

// Ram Output Logic
always_comb
begin
	case(r_ptr[2:0])
		3'd0: begin
			if(empty) begin
				r_data = 8'd0;
			end else begin
				r_data = data1;
			end
		end
		3'd1: begin
			r_data = data2;
		end
		3'd2: begin
			r_data = data3;
		end
		3'd3: begin
			r_data = data4;
		end
		3'd4: begin
			r_data = data5;
		end
		3'd5: begin
			r_data = data6;
		end	
		3'd6: begin
			r_data = data7;
		end
		3'd7: begin
			r_data = data8;
		end
		default: begin
			r_data = 8'd0;
		end
	endcase
end
endmodule
