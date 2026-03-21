#!/bin/bash

until [condition]
do
    command1
    command2
done

n=1
until [ $n -ge 10 ]
do
    echo $n
    n=$(( n+1 ))
done

#or

until (( $n > 10 ))
do
    echo $n
    (( n++ ))
done
