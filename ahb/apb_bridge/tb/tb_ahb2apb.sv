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

// File name:   tb_serialport.sv
// Created:     6/11/2014
// Author:      Xin Tze Tee
// Version:     1.0  
// Description: Test for APB Slave interfacing with a AHB to APB Bridge
//				using the file reading bus master as the AHB master 


`timescale 1ns / 10ps

//Interfaces
`include "ahb2apb_if.vh"
`include "ahb_if.vh"
`include "apb_if.vh"

//module tb_serialport();
module tb_ahb2apb();

// Define parameters
parameter CLK_PERIOD = 20;

//Interfacing Variables
logic 	clk;
logic 	n_rst;

ahb2apb_if a2aif();

//------------------------------PORT MAP---------------------------------------//
ahb_frbm
#(
  .TIC_CMD_FILE("/home/ecegrid/a/mg139/repos/SoCET_Public/ahb/apb_bridge/scripts/test.tic")
) ahbFrbm (
	.HCLK(clk),
	.HRESETn(n_rst),
	.HADDR(a2aif.ahb.HADDR),
	.HBURST(a2aif.ahb.HBURST),
	.HPROT(a2aif.ahb.HPROT),
	.HSIZE(a2aif.ahb.HSIZE),
	.HTRANS(a2aif.ahb.HTRANS),
	.HWDATA(a2aif.ahb.HWDATA),
	.HWRITE(a2aif.ahb.HWRITE),
	.HRDATA(a2aif.ahb.HRDATA),
	.HREADY(a2aif.ahb.HREADY),
	.HRESP(a2aif.ahb.HRESP),
	.HBUSREQ(),
	.HLOCK(a2aif.ahb.HMASTLOCK), 
	.HGRANT(1'b1)
);

// AHB to APB Bridge
ahb2apb ahb2apb
(
	.clk(clk), 
	.n_rst(n_rst),
	.apbif(a2aif.apb),
	.ahbif(a2aif.ahb),
	.slaveif(a2aif.slave_decode)
);

// APB Slave Interface

//-------------------------------------------------------------------------------------------------------------------//

// Clock Generation
always
begin : CLK_GEN
	clk = 1'b0;
	#(CLK_PERIOD / 2);
	clk = 1'b1;
	#(CLK_PERIOD / 2);
end

initial
  begin
	// Initialize variables
    n_rst = 1'b0;
	#20;
	@(negedge clk);
    n_rst = 1'b1;

end

endmodule
