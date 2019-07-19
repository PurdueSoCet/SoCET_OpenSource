#!/bin/bash
## ------------------------------------------------------------------------
## Copyright 2019 Purdue University SoCET design team
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ------------------------------------------------------------------------

# Author: Isaiah Grace
# Date Created: 18 July 2019

# This is a list of filetypes that we are trying to target for Open Source export
FILETYPES=".sv .vh"

# globstar is needed for the **/*.sv syntax to work correctly
shopt -s globstar

# extglob is needed to exclude RISCVBusiness from the search
shopt -s extglob

# script to copy the headers to all the source files and header files
# Thanks to stack exchange for bash help


for t in $FILETYPES; do
    for f in **/*$t; do
	if (grep Copyright $f -q);
	then 
	    #echo "No need to copy the License Header to $f"
	    :
	else
	    cat licenseHeader $f > $f.new
	    mv $f.new $f
	    echo "License Header copied to $f"
	fi
    done
done
