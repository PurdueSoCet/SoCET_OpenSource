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
   Interface for the I/O of GPIO (top level)

   Author: Dwezil D'souza
*/

`ifndef GPIO_IF_VH
`define GPIO_IF_VH

interface gpio_if();

  parameter NUM_PINS = 8; //MAX32

  logic interrupt;  
  logic [NUM_PINS - 1 : 0] r_data;
  logic [NUM_PINS - 1 : 0] w_data;
  logic [NUM_PINS - 1 : 0] en_data; 

  modport gpio( 
    output interrupt, w_data, en_data,  
    input r_data
  );

endinterface

`endif //GPIO_IF_VH
