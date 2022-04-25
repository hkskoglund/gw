#!/bin/sh
for char in $(seq -s' ' 0 255); do oct=$(printf "%03o" "$char"); printf "%3d %03o %b\n" "0$oct" "0$oct"  "\\$oct"; done
