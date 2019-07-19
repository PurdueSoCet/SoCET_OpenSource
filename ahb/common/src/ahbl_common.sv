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

package ahbl_common;

    //AHBLite bus typedefs for constant values
    typedef enum bit [ 1:0] {IDLE=2'b00, BUSY=2'b01, NONSEQ=2'b10, SEQ=2'b11} HTRANS_t;
    typedef enum logic [ 2:0] {SINGLE=3'b000, INCR=3'b001, WRAP4=3'b010, INCR4=3'b011, WRAP8=3'b100, INCR8=3'b101, WRAP16=3'b110, INCR16=3'b111} HBURST_t;
    //implement HPROT

    typedef enum bit        {OK=1'b0, ERROR=1'b1} HRESP_t;
    typedef enum bit [ 2:0] {BYTE=3'b000, HWORD=3'b001, WORD=3'b010, DWORD=3'b011, QWORD=3'b100, WORD8=3'b110, WORD16=3'b111} HSIZE_t;

    //Address phase struct
    typedef struct {
        logic      [31:0] HADDR;
        logic      [ 2:0] HBURST;
        logic             HMASTLOCK;
        logic      [ 3:0] HPROT;
        logic      [ 2:0] HSIZE;
        logic      [ 1:0] HTRANS;
        logic             HWRITE;
    } APhase;

endpackage : ahbl_common

