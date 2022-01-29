#!/bin/sh

initShell() {
    #shellcheck disable=SC3010,SC2050
    if type "[[" >/dev/null && 2>/dev/null [[ a =~ a ]]; then
        SHELL_SUPPORT_TILDE_REGEX=1
    else
        SHELL_SUPPORT_TILDE_REGEX=0
    fi

    #shellcheck disable=SC3044
    if type typeset >/dev/null; then
        SHELL_SUPPORT_TYPESET=1
    else
        SHELL_SUPPORT_TYPESET=0
    fi

    if [ -n "$ZSH_VERSION" ]; then
    #https://zsh.sourceforge.io/FAQ/zshfaq03.html
       setopt shwordsplit  #zsh compability for "1 2 3" -> split in 1 2 3
    fi

    case "$(type printf)" in 
        
        *builtin) #mksh does not have printf bulitin -> printf calls clone a new process -> reduced performance -> prefer echo over printf unless formatting is absolutely required
            
            SHELL_SUPPORT_PRINTF=1 

            #storing value in variable from printf
            #shellcheck disable=SC3045
            if printf -v SHELL_SUPPORT_PRINTF_VOPT "%s" "-v" 1>/dev/null 2>/dev/null && [ "$SHELL_SUPPORT_PRINTF_VOPT" = '-v' ]; then
              SHELL_SUPPORT_PRINTF_VOPT=1
            else
              SHELL_SUPPORT_PRINTF_VOPT=0
            fi

            ;;
        
        *)

            SHELL_SUPPORT_PRINTF=0
            ;;
    esac

}

writeString() 
{
  # PACKET_TX_BODY="${#1} $(printf "%s" "$1" | od -A n -t u1)"

    if [ "$SHELL_SUPPORT_TYPESET" -eq 1 ]; then
        #shellcheck disable=SC3044
        typeset len str decstr n
    else
        local  len str decstr n
    fi 


  str=$1
  len=${#str}

  [ "$DEBUG" -eq 1 ] && >&2 echo  "writeString $1 len $len"

  PACKET_TX_BODY="$len"
  unset APPEND_FORMAT APPEND_STRING

  n=1
  while [ -n "$str" ]; do
    suffix=${str#?}
    eval C$n="${str%%"$suffix"}"
     APPEND_FORMAT=$APPEND_FORMAT'%d ' # wait with printf-processing until entire sting is built
     APPEND_STRING=$APPEND_STRING'\"$'"C$n " # \'$var or \"$var - char to ascii conversion in printf bulitin/command argument
    str=$suffix
    n=$(( n + 1 ))
  done
 
    if [ "$SHELL_SUPPORT_PRINTF_VOPT" -eq  1 ]; then
        eval printf -v decstr \""$APPEND_FORMAT"\" "$APPEND_STRING"
        PACKET_TX_BODY="$PACKET_TX_BODY $decstr"
    else
       PACKET_TX_BODY="$PACKET_TX_BODY $(eval printf \""$APPEND_FORMAT"\" "$APPEND_STRING")" #ok, run in subshell
    fi

  #cleanup variables
  n=1
  while [ "$n" -le "$len" ]; do
     unset C$n 
     n=$(( n + 1 ))
  done

  if [ -n "$KSH_VERSION" ]; then
      unset len str decstr n
  fi

}

writeString2()
{
   PACKET_TX_BODY="${#1} $(printf "%s" "$1" | od -A n -t u1)"
}

DEBUG=0

initShell
writeString "test"
echo "$PACKET_TX_BODY"