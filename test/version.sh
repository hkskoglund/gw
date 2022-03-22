#!/bin/sh
for sh in dash bash ksh mksh zsh; do echo $sh; DEBUG_BUFFER_STRING=1 $sh ./gw -g 192.168.3.16 -c version; done