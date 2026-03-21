#/bin/sh

#Signals and Traps

echo "pid is $$"
while (( count < 10 ))
do
    sleep 10
    (( count ++ ))
    echo $count
done
exit 0

#When we interrupt script in the middle using crtl + c or ctrl + z or kill the process trap command is used to run before termination
# TRap cannot catch SIGKILL or SIGSTOP command except then all the ctrl+c alos if we run the process wouldnot stop

trap "echo EXIT command is detected" 0

echo "Hello World"

exit 0