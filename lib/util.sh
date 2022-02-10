#!/bin/sh

isNumber() {
    #https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash?page=1&tab=votes#tab-top
    isnumber_int=$1
    case "$isnumber_int" in
              -*) isnumber_int=${isnumber_int#-} ;; # remove sign
    esac

    case "$isnumber_int" in
        '' | *[!0-9]* ) return 1 ;;
        *) return 0 ;;
    esac
    unset isnumber_int
   #echo "1: $1"
   #if [ "$1" -ge 0 ] || [ "$1" -lt 0 ]; then #does not work in ksh93
   #  return 0
   #else
   #  return 1
   #fi
}

isHex()
{
    case $1 in 
      '' | *[!0-9a-fA-F]*) return 1 ;;
      *) return 0 ;;
    esac
}

toLowercase() {
    if [ "$SHELL_SUPPORT_TYPESET" -eq 1 ]; then
        #shellcheck disable=SC3044
        typeset -l lowcasestr # -l option -> lowercase on assignment/or ignored
    fi

    if [ -n "$BASH_VERSION" ]; then
        eval 'LOWERCASE=${1,,}' #eval prevents ksh from stopping parsing on syntax error
    elif [ -n "$ZSH_VERSION" ]; then
        #shellcheck disable=SC3057
        LOWERCASE=${1:l}
    elif [ -n "$KSH_VERSION" ]; then
        # Android 11 runds mir bsd korn shell http://www.mirbsd.org/mksh.htm
        lowcasestr=$1
        LOWERCASE=$lowcasestr
    else
        LOWERCASE=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    fi

    if [ -n "$KSH_VERSION" ]; then
       unset lowcasestr
    fi

}

dumpstack()
#https://wiki.bash-hackers.org/commands/builtin/caller
{
    if type caller >/dev/null 2>/dev/null  && type local >/dev/null 2>/dev/null ; then 
    #shellcheck disable=SC3043
        local stackframe=0
    #shellcheck disable=SC3044
        while caller $stackframe; do
            stackframe=$(( stackframe + 1 ))
        done
   fi
}