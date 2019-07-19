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

`ifndef _AHBL_COMMON_VH
`define _AHBL_COMMON_VH

interface ahbl #(parameter DW = 32)
    (input wire HCLK,
    input wire HRESETn);

    import ahbl_common::*;

    // Master Signals
    logic      [31:0] HADDR;
    HBURST_t    HBURST;
    logic             HMASTLOCK;
    logic      [ 3:0] HPROT;
    logic      [ 2:0] HSIZE;
    logic      [ 1:0] HTRANS;
    logic      [DW:0] HWDATA;
    logic             HWRITE;

    // Slave Signals
    logic      [DW:0] HRDATA;
    logic             HREADYOUT;
    logic             HRESP;
       
    // Decoder Signals 
    logic             HSELx;

    logic             HREADY;

    modport master (
        input  HREADY,
        input  HRESP,
        input  HRDATA,
        output HADDR,
        output HWRITE,
        output HSIZE,
        output HBURST,
        output HPROT,
        output HTRANS,
        output HMASTLOCK,
        output HWDATA );

    modport slave (
        input  HSELx,
        input  HADDR,
        input  HWRITE,
        input  HSIZE,
        input  HBURST,
        input  HPROT,
        input  HTRANS,
        input  HMASTLOCK,
        input  HREADY,
        input  HWDATA,
        output HREADYOUT,
        output HRESP,
        output HRDATA );

endinterface : ahbl

`endif
 
 
 
 
 
