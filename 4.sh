#!/bin/bash

echo $0 $1 $2 $2 ' > echo $1 $2 $3' # when we execute arguments from script they will be stored in $1, $2, $3 like that ./4.sh john wesley prasanth

args=("$@") #another way of passimg arguments through a script is $@ here the arguments go as an array

echo ${args[0]} ${args[1]} ${args[2]} ${args[3]}

echo $@ #instead of writing each argument seperatley like args[0] we can use this

echo $# #To know the lenght of argument passed