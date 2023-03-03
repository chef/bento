#!/bin/bash

exit_script() {
    echo "Received signal: $1"
    echo "Going to kill a process"
    trap - SIGHUP SIGINT SIGTERM # clear the trap
    # Do stuff to clean up
    exit
}

trap 'exit_script SIGHUP' SIGHUP
trap 'exit_script SIGTERM' SIGTERM
trap 'exit_script SIGINT' SIGINT


echo "running the job! PID: $$"
i=0
while true;
do
    sleep 1;
    i=+1
    echo "$(hostname) $i";
done

echo "Script finished Done"
