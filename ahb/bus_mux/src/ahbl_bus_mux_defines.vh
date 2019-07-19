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

`ifndef _AHBL_BUS_MUX_COMMON_VH
`define _AHBL_BUS_MUX_COMMON_VH

interface aphase_c #(parameter DW = 32);

    import ahbl_common::*;

    // Master Signals
    logic      [31:0] HADDR;
    logic      [ 2:0] HBURST;
    logic             HMASTLOCK;
    logic      [ 3:0] HPROT;
    logic      [ 2:0] HSIZE;
    logic      [ 1:0] HTRANS;
    logic             HWRITE;
    logic             HREADY;

    modport in (
    input  HADDR,
    input  HBURST,
    input  HMASTLOCK,
    input  HPROT,
    input  HSIZE,
    input  HTRANS,
    input  HWRITE,
    input  HREADY );

    modport out (
    output HADDR,
    output HBURST,
    output HMASTLOCK,
    output HPROT,
    output HSIZE,
    output HTRANS,
    output HWRITE,
    output HREADY );

endinterface : aphase_c

`endif
