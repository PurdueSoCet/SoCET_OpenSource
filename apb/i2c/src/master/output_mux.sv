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

`include "i2c_master_const.vh"
module output_mux(
	input	DriveSelectType drive_select,
		logic tx_SDA,
		logic tx_SCL,
		logic rx_SDA,
		logic rx_SCL,
		logic start_stop_SDA,
		logic start_stop_SCL,
	output	logic SDA_out,
		logic SCL_out
);

//Begin mux
//=====================================================================
always_comb begin
	case(drive_select)
		DS_START_STOP: begin 
			SDA_out = start_stop_SDA;
			SCL_out = start_stop_SCL;
		end
		DS_RECEIVE: begin
			SDA_out = rx_SDA;
			SCL_out = rx_SCL;
		end
		DS_TRANSMIT: begin
			SDA_out = tx_SDA;
			SCL_out = tx_SCL;
		end
		default: begin	//IDLE state
			SDA_out=1;
			SCL_out=1;
		end
	endcase
end

endmodule
