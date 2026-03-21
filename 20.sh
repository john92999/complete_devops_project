#!/bin/bash

function name(){
    commands
}

# or

name () {
    commands
}

function Hello(){
    echo "Hello"
}

quit () {
    exit
}

Hello
echo "foo"
quit

#----------------------------------------------------------------------------

function Print(){
    echo $1
}

Print hello
Print world

#----------------------------------------------------------------------------

function Print(){
    name = $1
    echo "The name is $name"
}

name = "Tom"
echo "the name is $name : Before"

Print John

echo "the name is $name : After"

#----------------------------------------------------------------------------

function Print(){
    local name = $1
    echo "The name is $name"
}

name = "Tom"
echo "the name is $name : Before"

Print John

echo "the name is $name : After"

#----------------------------------------------------------------------------

usage(){
    echo "You need to provide an argument"
    echo "usage : $0 file_name"
}

is_file_exists() {
    local file = "$1"
    [[ -f $file ]] && return 0 || return 1
}

[[ $# -eq 0 ]] && usage

if ( is_file_exists "$1" )
then
    echo "File Found"
else
    echo "File not found"
fi





