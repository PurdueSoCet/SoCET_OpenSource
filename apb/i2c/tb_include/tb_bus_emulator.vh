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

parameter CLOCK_PERIOD=15ns;
logic tb_n_rst;
logic tb_clk;

//bus signals
logic dut_SDA;		//signals from DUT
logic dut_SCL;
logic slave_SDA;	//signals from EMULATED slave
logic slave_SCL;
logic master_SDA;	//signals from EMULATED master
logic master_SCL;

logic SDA;		//The bus
logic SCL;

assign SDA = dut_SDA & slave_SDA & master_SDA; //open drain connection
assign SCL = dut_SCL & slave_SCL & master_SCL;

logic [7:0] tb_expected_data [63:0];

task delay(input integer j);
	integer i;
	for(i=0;i<j;i++) begin
		@(negedge tb_clk);
	end
endtask

always begin
	tb_clk=0;
	#(CLOCK_PERIOD/2.0);
	tb_clk=1;
	#(CLOCK_PERIOD/2.0);
end
