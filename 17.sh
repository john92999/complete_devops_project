#!/bin/bash

for VARIABLE in 1 2 3 ..... N
do
    command1
    command2
done

#OR--------------------------------------------------------------

for VARIABLE in file1 file2 file3
do
    command1 on $VARIABLE
    command2
done

#OR--------------------------------------------------------------

for OUTPUT in $(Linux or unix command)
do
    command1 on $OUTPUT
    command2
done

#OR--------------------------------------------------------------

for (( EXP1; EXP2; EXP3 ))
do
    command1 on $OUTPUT
    command2



for i in 1 2 3
do
    echo $i
done

for i in {1..10}
do
    echo $i
done

for i in {1..10..2} # 1 - 10 and then increment by 2 
do
    echo $i
done


for (( i=0; i<5; i++ )) # 1 - 10 and then increment by 2 
do
    echo $i
done

for command in ls pwd date # 1 - 10 and then increment by 2 
do
    echo "----------------$command------------------"
done

for item in * # 1 - 10 and then increment by 2 
do
    if [ -d $item ]
    then
        echo $item
    fi
done


