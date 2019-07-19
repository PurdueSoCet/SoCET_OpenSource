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

# The script must be given an argument that will point it to a folder within the SoCET_Public directory
if [[ ! -d ~/SoCET_Public/$1 ]]; then
    echo "Error: pass in a folder as the first argument to the script"
    echo "       The script will look at ~/SoCET_Public/$1"
    echo "       So please make sure $1 is a valid file path"
    exit 1
fi


FILETYPES=".sv .vh"

shopt -s globstar

for t in $FILETYPES; do
    # Yikes. This has been a learning experience in bash. The first line should re-create the directory tree necessary to copy all the targetted files over to SoCET_OpenSource
    find ~/SoCET_Public/$1/ -name *$t | sed -e "s/^.*SoCET_Public//" | xargs -I '{}' dirname .'{}' | xargs -I '{}' mkdir -p '{}'
    find ~/SoCET_Public/$1/ -name *$t | sed -e "s/^.*SoCET_Public//" | xargs -I '{}' cp ~/SoCET_Public'{}' .'{}'
done
