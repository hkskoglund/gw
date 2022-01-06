#!/usr/bin/bash
#!/usr/bin/dash
set -x

DEBUG=0
CONVERT_HEXANDOCT_USING_SUBSHELL=0
SHELL_SUPPORT_TYPESET=0

convertHexToOctal ()
{
  if [ "$SHELL_SUPPORT_TYPESET" -eq 1 ]; then
#shellcheck disable=SC3044
 {
    typeset dec
    typeset lsb
    typeset msb
    typeset middle
 }
 else
    local dec
    local lsb
    local msb
    local middle
  fi
    dec=$(( $1 ))

    lsb=$(( dec & 7 ))
    middle=$(( (dec >> 3) & 7 ))
    msb=$(( dec >> 6 ))
    VALUE_OCTAL=$msb$middle$lsb
}

convertBufferFromHexToOctal ()
#convert from ff ff .. .. {checksum} to \0377\0377 .. ..
#strace: each $( printf ) creates a new process (strace: Process nnnn attached )
{
     unset VALUE_OCTAL_BUFFER
     for BYTE in $1; do
        if [ "$CONVERT_HEXANDOCT_USING_SUBSHELL" -eq 1 ]; then
            VALUE_OCTAL_BUFFER="$VALUE_OCTAL_BUFFER$( printf "\\%04o" "0x$BYTE")"
        else
            convertHexToOctal "0x$BYTE"
            VALUE_OCTAL_BUFFER="$VALUE_OCTAL_BUFFER\0$VALUE_OCTAL"
        fi

      done

      [ $DEBUG -eq 1 ] && >&2 echo "Octal buffer $VALUE_OCTAL_BUFFER"
}

N=1
while [ "$N" -lt 2 ]; do
    convertBufferFromHexToOctal "ff"
    N=$(( N + 1 ))
done