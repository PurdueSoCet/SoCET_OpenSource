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

//Top level external interface for i2c module
`ifndef __I2C_IF_VH
`define __I2C_IF_VH


interface i2c_if();
	logic SDA;	//The raw unsychronized bus value
	logic SCL;	//The raw unsychronized bus value
	logic SDA_out;	//The value to be driven on the bus as open drain
	logic SCL_out;	//The value to be driven on the bus as open drain
	logic interrupt;//Interrupt flag

	modport i2c(
		input SDA, SCL,
		output SDA_out, SCL_out, interrupt
	);
endinterface

`endif //__I2C_IF_VH
