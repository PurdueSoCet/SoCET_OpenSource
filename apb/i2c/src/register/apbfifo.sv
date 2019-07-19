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

module apbfifo
(
	input reg [7:0] w_data,
	input wire w_enable,
	input wire r_enable,
	input wire r_clk,
	input wire w_clk,
	input wire n_rst,
	output reg [7:0] r_data,
	output reg full,
	output reg empty,
	output reg almost_full
);

// Declarations for Overall FIFO
reg w_ena;
reg r_ena;
reg [3:0] w_ptr;
reg [3:0] r_ptr;
reg [7:0] ss;
//reg [7:0] ram_data;
reg [3:0] next_ptr;
reg write;
reg [2:0] temp_ptr;

// Declarations for registers
wire [7:0] data1;
wire [7:0] data2;
wire [7:0] data3;
wire [7:0] data4;
wire [7:0] data5;
wire [7:0] data6;
wire [7:0] data7;
wire [7:0] data8;

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
	.clear(w_ena & (w_ptr == 4'b1111)), 
	.count_enable(w_ena),
	.count_out(w_ptr),
	.rollover_val(4'd15)
);

// Read Pointer Counter
flex_counter IX1 (
	.clk(r_clk),
	.n_rst(n_rst),
	.clear(r_ena & (r_ptr == 4'b1111)),
	.count_enable(r_ena),
	.count_out(r_ptr),
	.rollover_val(4'd15)
);

// Empty Logic
always_comb
begin
	if(w_ptr == r_ptr) begin
		empty = 1'b1;
	end else begin
		empty = 1'b0;
	end
end

// Full Logic
always_comb
begin
	if((w_ptr[2:0] == r_ptr[2:0]) & (w_ptr[3] != r_ptr[3])) begin
		full = 1'b1;
	end else begin
		full = 1'b0;
	end
end

// Almost Full Logic
always_comb
begin
	temp_ptr = r_ptr[2:0] - 1'b1;
	if(temp_ptr == w_ptr[2:0]) begin
		almost_full = 1'b1;
	end else begin
		almost_full = 1'b0;
	end
end

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
	if(w_ptr == next_ptr) begin
		write = 1'b0;
	end else begin
		write = 1'b1;
	end
end

// Ram Input Logic
always_comb
begin
	if(write == 1) begin
		case(w_ptr[2:0])
			3'd0: begin
				ss = 8'b10000000;
			end
			3'd1: begin
				ss = 8'b00000001;
			end
			3'd2: begin
				ss = 8'b00000010;
			end
			3'd3: begin
				ss = 8'b00000100;
			end
			3'd4: begin
				ss = 8'b00001000;
			end
			3'd5: begin
				ss = 8'b00010000;
			end
			3'd6: begin
				ss = 8'b00100000;
			end
			3'd7: begin
				ss = 8'b01000000;
			end
			default: begin
				ss = '0;
			end
		endcase
	end else begin
		ss = '0;
	end
end

// Shift Register 1
p2p IX3 (
	.data_in(w_data),
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(ss[0]),
	.data_out(data1)
);

// Shift Register 2
p2p IX4 (
	.data_in(w_data),
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(ss[1]),
	.data_out(data2)
);

// Shift Register 3
p2p IX5 (
	.data_in(w_data),
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(ss[2]),
	.data_out(data3)
);

// Shift Register 4
p2p IX6 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(ss[3]),
	.data_in(w_data),
	.data_out(data4)
);

// Shift Register 5
p2p IX7 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(ss[4]),
	.data_in(w_data),
	.data_out(data5)
);

// Shift Register 6
p2p IX8 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(ss[5]),
	.data_in(w_data),
	.data_out(data6)
);

// Shift Register 7
p2p IX9 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(ss[6]),
	.data_in(w_data),
	.data_out(data7)
);

// Shift Register 8
p2p IX10 (
	.clk(w_clk),
	.n_rst(n_rst),
	.shift_enable(ss[7]),
	.data_in(w_data),
	.data_out(data8)
);

// Ram Output Logic
always_comb
begin
	case(r_ptr[2:0])
		3'd0: begin
			r_data = data1;
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
