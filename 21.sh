#!/bin/bash

var = 31

readonly var

var = 50

echo "var => $var"

readonly -f hello(){
    echo "Hello World"
}

hello

readonly #it will give all the values which are readonly
readonly -f #give all readonly fucntion


