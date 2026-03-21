#!/bin/bash

echo "Enter name : "
read name #Whatever we enter after read name will be stored in name variable
echo "Entered name is $name"


echo "Enter name : "
read name1 name2 name3 #when giving input give space across names
echo "Entered name are $name1, $name2, $name3 "

echo -p "Username : " user_var #This will allow to input username in the same line 
echo "username : $user_var"

echo -sp "Password : " password_var #s means secure this will make the text not redable when giving input
echo "Password : $password_var"

echo "Enter names: "
read -a names #a means array we can change the input into array while giving input give space
echo "Names : ${names[0]} ${names[1]}"


echo "Enter name: "
read # If we don't give any varaiable then input goes into inbuilt variable REPLY
echo "Names : $REPLY"
