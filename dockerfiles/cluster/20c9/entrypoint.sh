#!/bin/bash 
source ~/.bashrc

${HOME}/goldilocks_home/entrypoint-init.sh

tail -f $GOLDILOCKS_DATA/trc/system.trc
