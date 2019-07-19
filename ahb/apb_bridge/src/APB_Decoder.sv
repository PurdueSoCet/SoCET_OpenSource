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

/*
// File name:   APB_Decoder.sv
// Created:     6/18/2014
// Author:      Xin Tze Tee
// Version:     1.0 
// Description: APB Decoder for AHB to APB Bridge.
                Decodes address sent from AHB Master to select which peripherals 
                to communicate with.
*/

module APB_Decoder
#(
  parameter NUM_SLAVES = 2
)
(
	input wire [31:0] PADDR,
	input wire psel_en,
	input wire [31:0] PRData_in [NUM_SLAVES-1:0],

  output wire [31:0] PRDATA_PSlave,
	output wire [NUM_SLAVES-1:0] PSEL_slave
);

logic [NUM_SLAVES-1:0] psel_slave_reg; //one hot select for slave 
int i;

/* psel_slave uses n bits where each bit corresponds to 
   the PSEL for each peripherals. (one hot)
*/
always_comb
begin
  psel_slave_reg = '0;
  if (psel_en) begin   
    psel_slave_reg = 1 << PADDR[14:12];
  end
end //always block

assign PSEL_slave = psel_slave_reg;

// Read Selection MUX                 
assign PRDATA_PSlave = PRData_in[PADDR[14:12]];

endmodule
