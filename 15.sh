#!/bin/bash
#while loops

while [ condition ]
do
    command1
    command2
done

n=1

while [ $n -le 10 ]
do
    echo "$n"
    n = $(( n+1 ))
done

# or

while (( $n <= 10 ))
do
    echo "$n"
    (( ++n ))
done


while (( $n <= 10 ))
do
    echo "$n"
    (( n++ ))
    sleep 1
done


while read p
do
    echo $p
done < 15.sh #this is used to read the file


cat 14.sh | while read p
do
    echo $p
done