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

module foo #(parameter MM=1)
    (ahbl.master m[MM:0], ahbl.slave s);

    assign m[0].HWDATA = s.HWDATA;

endmodule : foo
