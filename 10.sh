#!/bin/bash

num1=20
num2=5

echo $(( num1 + num2 )) #perform addition we need to use double brackets
echo $(( num1 - num2 ))
echo $(( num1 * num2 ))
echo $(( num1 / num2 ))
echo $(( num1 % num2 ))


# or we can do arthemetic operations using expr while using * we need to \ before it

echo $(expr $num1 + $num2 )
echo $(expr $num1 - $num2 )
echo $(expr $num1 \* $num2 )
echo $(expr $num1 / $num2 )
echo $(expr $num1 % $num2 )