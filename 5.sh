#!/bin/bash

#integer comparison

# -eq - is equal to - if [ "$a" -eq "$b" ]
# -ne - is not equal to - if [ "$a" -ne "sb" ]
# -gt - is greater than - if [ "$a" -gt "$b" ]
# -ge - is greater than or equal to - if [ "$a" -ge "$b" ]
# -lt - is less than - if [ "$a" -lt "sb" ]
# -le - is less than or equal to - if [ "$a" -le "$b" ]
# < - is less than - (("$a" < "$b"))
# <= - is less than or equal to - (("$a" <= "$b"))
# > - is greater than - (("$a" > "$b"))
# >= - is greater than or equal to - (("$a" >= "$b"))

#string comparison

# = - is equal to - if [ "$a" = "$b"]
# == - is equal to - if [ "$a" == "$b"]
# != - is not equal to - if [ "$a" != "$b" ]
# < - is less than, in ASCII alphabetical order - if [[ "$a" < "$b" ]]
# > - is greater than, in ASCII alphabetical order - if [[ "$a" > "$b]]
# -z - string is null, that is, has zero Length

count=10

if [ $count -eq 9]
then
    echo "condition is true"
fi

word = abc

if [$word != "abcvcc"]
then
    echo "condition is true"
elif [[$word < 'b']]
then
    echo "condition is true"
else
    echo "condition is false"
fi