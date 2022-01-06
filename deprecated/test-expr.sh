#!/bin/bash

function testwhile
{
    typeset -i N
    N=0
    while [ "$N" -lt 10000 ]; do
       N=$(( N + 1 ))
    done
}

function testexpr
{
    typeset -i N
    N=0
    while [ "$N" -lt 10000 ]; do
       N=$(expr $N + 1)
    done
}

time testwhile
time testexpr
