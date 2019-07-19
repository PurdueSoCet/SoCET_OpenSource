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

// File name:   APB_SlaveInterface.sv
// Updated:     03/01/2016
// Author:      Xin Tze Tee and Travis Garza
// Version:     2.0 
// Description: APB Slave Interface which sits between APB Bridge and Registers in the slave.
//				This module interacts with serial port registers
//				Can be duplicated and used for other slaves (eg. GPIO, etc)

module APB_SlaveInterface
#(
	parameter [11:0] xmitRegAddr = 12'h004,
	parameter [11:0] rcvRegAddr =  12'h008,
	parameter [11:0] statRegAddr = 12'h00C,
	parameter [11:0] baudRegAddr = 12'h010
)
(
	input wire clk, n_rst,
	// inputs from APB Bridge
	input wire [31:0] PADDR,
	input wire PENABLE,
	input wire PWRITE,
	input wire PSEL,
 	// input data from slave registers
	input wire [1:8][31:0] read_data,
	// output to slave registers
	output wire [7:0] Enable,
	// output to APB Bridge
	output wire [31:0] PRDATA,
	output wire pslverr
);

//Encoding for State Machine
parameter [2:0] IDLE = 3'b000,
			 	XMITDATA = 3'b001,
			 	RCVDATA = 3'b010,
			 	STATUS = 3'b011,
				BAUDDATA = 3'b100, // added bauddata
				ERROR = 3'b101;
reg [2:0] state, nextstate;
reg [7:0] enable_reg;
reg [31:0] prdata_reg;
reg pslverr_reg;

wire [11:0] ADDR_OFFSET;

assign ADDR_OFFSET = PADDR[11:0];

// State Machine Register
always_ff @(posedge clk, negedge n_rst) begin
	if (n_rst == 0) begin
		state <= IDLE;
	end else begin
		state <= nextstate;
	end
end

// Next State Logic
always_comb
begin
  case (state)
	IDLE: begin
	  if (PSEL == 1) begin
		  if (ADDR_OFFSET == xmitRegAddr)
			 nextstate = XMITDATA;
		  else if (ADDR_OFFSET == rcvRegAddr)
			 nextstate = RCVDATA;
		  else if (ADDR_OFFSET == statRegAddr)
			 nextstate = STATUS;
		  else if (ADDR_OFFSET == baudRegAddr)
			 nextstate = BAUDDATA;
		  else begin
			 nextstate = ERROR;
			end
	  end else begin
		  nextstate = IDLE;
	  end
	end
	
	XMITDATA: begin
		nextstate = IDLE;
	end

	RCVDATA: begin
		nextstate = IDLE;
	end

	STATUS: begin
		nextstate = IDLE;
	end
	//added this
	BAUDDATA: begin
		nextstate = IDLE;
	end

	ERROR: begin
		nextstate = IDLE;
	end

	default: begin
		nextstate = IDLE;
	end
  endcase
end

// Output Logic
always_comb
begin
  if (n_rst == 0) begin
	enable_reg = 8'b00000000;
	prdata_reg = '0;
	pslverr_reg = 1'b0;
  end else begin
	case (state)
		IDLE: begin
	  	  if (PSEL == 1) begin			// assert enable one cycle earlier for RCV
			if (PWRITE == 0) begin
				if (PADDR[11:0] == rcvRegAddr[11:0]) begin
					enable_reg = 8'b00000010;
					prdata_reg = 32'h00000000;
					pslverr_reg = 1'b0;
				end else if (PADDR[11:0] == statRegAddr[11:0]) begin
					enable_reg = 8'b00000100;
					prdata_reg = 32'h00000000;
					pslverr_reg = 1'b0;
				end else if (PADDR[11:0] == baudRegAddr[11:0]) begin
					enable_reg = 8'b00001000;
					prdata_reg = 32'h00000000;
					pslverr_reg = 1'b0;
			    end else begin
					enable_reg = 8'b00000000;
					prdata_reg = 32'h00000000;
					pslverr_reg = 1'b0;
			    end
			end else begin
				enable_reg = 8'b00000000;
				prdata_reg = 32'h00000000;
				pslverr_reg = 1'b0;
		  	end
		  end else begin
			enable_reg = 8'b00000000;
			prdata_reg = 32'h00000000;
			pslverr_reg = 1'b0;
		  end
		end
		XMITDATA: begin
		  if (PWRITE == 1) begin		// write
			enable_reg = 8'b00000001;
			prdata_reg = 32'h00000000;
			pslverr_reg = 1'b0;
		  end else begin				// read
			enable_reg = 8'b00000000;
			prdata_reg = 32'h00000000;
			pslverr_reg = 1'b0;		
		  end
		end
		RCVDATA: begin
		  if (PWRITE == 1) begin		// write
			enable_reg = 8'b00000010;
			prdata_reg = 32'h00000000;
			pslverr_reg = 1'b0;
		  end else begin				// read
			enable_reg = 8'b00000000;		//fix
			prdata_reg = read_data[2];
			pslverr_reg = 1'b0;		
		  end
		end
		STATUS: begin
		  if (PWRITE == 1) begin		// write
			enable_reg = 8'b00000100;
			prdata_reg = 32'h00000000;
			pslverr_reg = 1'b0;
		  end else begin				// read
			enable_reg = 8'b00000000;
			prdata_reg = read_data[3];
			pslverr_reg = 1'b0;
		  end
		end
		BAUDDATA: begin  
		  if (PWRITE == 1) begin		// write
			enable_reg = 8'b00001000;	
			prdata_reg = 32'h00000000;
			pslverr_reg = 1'b0;
		  end else begin				// read
			enable_reg = 8'b00000000;	//xmit(001) rcv(010) status(000) BAUDDATA(???)
			prdata_reg = read_data[3];	
			pslverr_reg = 1'b0;
		  end
		end
		ERROR: begin
			enable_reg = 8'b00000000;
			prdata_reg = 32'hdeadbeef;
			pslverr_reg = 1'b1;
		end
		default: begin
			enable_reg = 8'b00000000;
			prdata_reg = 32'hdeadbeef;
			pslverr_reg = 1'b0;
		end
	endcase
  end
end


assign Enable = enable_reg;
assign PRDATA = prdata_reg;
assign pslverr = pslverr_reg;

endmodule
