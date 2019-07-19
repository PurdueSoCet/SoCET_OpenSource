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

`ifndef __I2C_MASTER_CONST
`define __I2C_MASTER_CONST

//This file contains constants to use in the master module
//package i2c_master_const;
//Typedef to select which value to load into the transmit shift register
//=====================================================================
typedef enum bit[1:0]{
	SS_10_BIT_ADDRESS_BYTE_1,
	SS_10_BIT_ADDRESS_BYTE_2,
	SS_7_BIT_ADDRESS,
	SS_TX_FIFO
}	ShiftSelectType;

//Typedef to select which lines drive SDA_out and SCL_out
//=====================================================================
typedef enum bit[1:0]{
	DS_IDLE,
	DS_START_STOP,
	DS_RECEIVE,
	DS_TRANSMIT
} DriveSelectType;
//endpackage
//import i2c_master_const::*;

`endif //__I2C_MASTER_CONST
