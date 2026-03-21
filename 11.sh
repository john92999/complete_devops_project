#!/bin/bash

# for floating numbers this will give us error we use bc basic calculator

num1=20.5
num2=5

echo "20.5+5" | bc
echo "20.5-5" | bc
echo "20.5*5" | bc
echo "scale=2,20.5/5" | bc #scale tells us how many values after decimal we want the value
echo "20.5%5" | bc

#we can also use variables

echo "$num1+$num2" | bc
echo "$num1-$num2" | bc

num=27
echo "scale=2, sqrt($num)" | bc -l #alone using bc it is not possible we need to include math library -l is used to include it
echo "scale=2, 3^3" | bc -l