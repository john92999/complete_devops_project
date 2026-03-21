#!/bin/bash

echo -e "Enter the name of the file: \c" #\c is used to interpret the file -e is used to so that \c will not be taken as a string but interpreted
read file_name

if [ -e $file_name] # -e is a special operator to check the file -f is used to check if file exist and it is a regular file or not, -d is used to check directory, -s to check if the file is empty or not, -b to check if it is a block file or not, -r to check if file has read permission, -w to check if file has write permission
then
    echo "$file_name found"
else
    echo "$$file_name not found"
fi