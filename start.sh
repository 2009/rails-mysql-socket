#!/bin/bash

# Wrapper script for docker ENTRY_POINT/CMD
#
# Create sockets to allow socket connections to TCP mysql instance
# running on hostname: db
#
# This is done for compatibility with alternative configs across
# our rails projects.

mkdir -p /var/run/mysqld

# Start the first process
socat \
  UNIX-LISTEN:/var/run/mysqld/mysqld.sock,fork,reuseaddr,unlink-early,mode=777 \
  TCP:db:3306 &

status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start socket 1: $status"
  exit $status
fi

# Start the second process
socat \
  UNIX-LISTEN:/tmp/mysqld.sock,fork,reuseaddr,unlink-early,mode=777 \
  TCP:db:3306 &

status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start socket 2: $status"
  exit $status
fi

echo "Running"

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container will exit with an error
# if it detects that either of the processes has exited.
# Otherwise it will loop forever, waking up every 60 seconds

while /bin/true; do
  ps aux |grep 'socat UNIX-LISTEN:/var/run/' |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep 'socat UNIX-LISTEN:/tmp/' |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they will exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit -1
  fi
  sleep 60
done
