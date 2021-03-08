#!/bin/bash 
source ~/.bashrc

${HOME}/goldilocks_home/entrypoint-init-view.sh

tail -f $GOLDILOCKS_DATA/trc/system.trc
