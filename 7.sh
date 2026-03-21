#!/bin/bash

echo -e "enter the file name: \c"
read file_name

if [ -f $file_name ]
then
    if [ -w $file_name ]
    then
        echo "Type some text data. To quit press ctrl+d ."
        cat >> $file_name
    else
        echo "the file doesnot have write permissions"
    fi
else
    echo "$file_name doesnot exists"
fi