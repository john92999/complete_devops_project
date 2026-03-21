#!/bin/bash

echo -e "Enter some character : \c"
read value

case $value in
    [a-z] )
        echo "User Entered $value a to z";;
    [A-Z] )
        echo "User Entered $value A to Z";;
    [0-9] )
        echo "User Entered $value 0 to 9";;
    ? )
        echo "User Entered $value Special Character";; #? for one character
    * )
        echo "unknown vehicle";; #* for more than one character
esac
