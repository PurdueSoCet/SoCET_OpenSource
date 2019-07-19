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

// File name:   ahb2apb_if.vh
// Created:     9/10/2015
// Author:      Erin Rasmussen
// Version      1.0
// Description: Interface for AHB2APB

`ifndef AHB2APB_IF_VH
`define AHB2APB_IF_VH

`include "ahb_if.vh"
`include "apb_if.vh"

interface ahb2apb_if;
  parameter NUM_SLAVES = 2;
   
   // APB input
   logic [31:0] PRData_slave[NUM_SLAVES-1:0];
   
   logic [NUM_SLAVES-1:0]	PSEL_slave; //one hot select for apb slaves

   modport slave_decode (
     input PRData_slave,
     output PSEL_slave
   );
   
endinterface // ahb2apb_if

`endif //  `ifndef AHB2APB_IF_VH


   
   
