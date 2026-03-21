#!/bin/bash

age=25

if [ $age -gt 18 ] || [ $age -lt 30 ] 
then
    echo "valid age"
else
    echo "age not valid"
fi


# or -o for or operator

if [ $age -gt 18 -o $age -lt 30 ] 
then
    echo "valid age"
else
    echo "age not valid"
fi


# or


if [[ $age -gt 18 || $age -lt 30 ]]
then
    echo "valid age"
else
    echo "age not valid"
fi