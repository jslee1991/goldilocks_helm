#!/bin/bash 

SET_INDEX=${HOSTNAME##*-}
echo "Starting initializing for pod $SET_INDEX"
if [ "$SET_INDEX" = "0" ]; then
  cp /tmp/goldilocks/set-0.conf /home/sunje/goldilocks_home/license
elif [ "$SET_INDEX" = "1" ]; then
  cp /tmp/goldilocks/set-1.conf /home/sunje/goldilocks_home/license
elif [ "$SET_INDEX" = "2" ]; then
  cp /tmp/goldilocks/set-2.conf /home/sunje/goldilocks_home/license
else
  echo "Invalid statefulset index"
  exit 1
fi
