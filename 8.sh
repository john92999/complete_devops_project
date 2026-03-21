#!/bin/bash

age=25

if [ $age -gt 18 ] && [ $age -lt 30 ] 
then
    echo "valid age"
else
    echo "age not valid"
fi

# or and can also be written as -a

if [ $age -gt 18 -a $age -lt 30 ] 
then
    echo "valid age"
else
    echo "age not valid"
fi

# or

if [[ $age -gt 18 && $age -lt 30 ]] 
then
    echo "valid age"
else
    echo "age not valid"
fi