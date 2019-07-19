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
:set expandtab
:set tabstop=4
:set shiftwidth=4
:retab

*/

`include "ahbl_defines.vh"
`include "ahbl_bus_mux_defines.vh"

import ahbl_common::*;
import ahbl_bus_mux_common::*;

module APhase_cache ( 
    input HCLK,
    input HRESETn,
    input ARB_SEL,
    
    aphase_c.in m_in, 
    aphase_c.out m_out );

    logic valid;

    always_ff @(posedge HCLK or negedge HRESETn)
    begin : latch
        if (!HRESETn) begin
           valid <= 0; 
 /*       end else begin
            if(m_in.HTRANS != 0) */
        end
    end : latch

    assign m_out.HADDR = m_in.HADDR;

endmodule : APhase_cache

 
