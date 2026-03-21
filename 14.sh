#!/bin/bash

os=('ubuntu' 'windows' 'kali')

echo "${os[@]}"

echo "${os[1]}"

echo "${!os[@]}" # it will print the indices of the array

os[3] = 'mac' # to append values to the array

unset os[2] #To remove the value from the array

string=cffdsjhfjdsj
echo "${string[@]}"
echo "${string[0]}"
echo "${string[1]}"
echo "${#string[@]}"