#!/bin/sh

isNumber() {
    #https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash?page=1&tab=votes#tab-top
    isnumber_int=$1
    case "$isnumber_int" in
              -*) isnumber_int=${isnumber_int#-} ;; # remove sign
    esac

    case "$isnumber_int" in
        '' | *[!0-9]* )  unset isnumber_int;  return 1 ;;
        *)  unset isnumber_int; return 0 ;;
    esac
   
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

toLowercase()
# convert string to lowercase
# $1 string
# set VALUE_LOWERCASE
 {
    if [ "$SHELL_SUPPORT_TYPESET" -eq 1 ]; then
        #shellcheck disable=SC3044
        typeset -l lowcasestr # -l option -> lowercase on assignment/or ignored
    fi

    if [ -n "$BASH_VERSION" ]; then
        eval 'VALUE_LOWERCASE=${1,,}' #eval prevents ksh from stopping parsing on syntax error
    elif [ -n "$ZSH_VERSION" ]; then
        #shellcheck disable=SC3057
        VALUE_LOWERCASE=${1:l}
    elif [ -n "$KSH_VERSION" ]; then
        # Android 11 runds mir bsd korn shell http://www.mirbsd.org/mksh.htm
        lowcasestr=$1
        VALUE_LOWERCASE=$lowcasestr
    else
        VALUE_LOWERCASE=$(echo "$1" | tr '[:upper:]' '[:lower:]')
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

roundFloat()
#https://unix.stackexchange.com/questions/89712/how-to-convert-floating-point-number-to-integer
{
    if [ "$SHELL_SUPPORT_BULTIN_PRINTF_VOPT" -eq 1 ]; then
    #shellcheck disable=SC3045
       printf -v VALUE_FLOAT_TO_INT "%.0f" "$1"
    else
        VALUE_FLOAT_TO_INT=$(printf "%.0f" "$1")
    fi
}

test_printf_sformat()
{
    od_unicode=$(printf "%2s" "🔋" | od -A n -t x1)

    if [ "$od_unicode" = " 20 f0 9f 94 8b" ]; then #zsh printf correctly insert a space infront
        SHELL_SUPPORT_PRINTF_UNICODE_SFORMAT=1
        [ "$DEBUG" -eq 1 ] && echo >&2 "Shell support printf unicode right/left adjustment"
    else
        #shellcheck disable=SC2034
        SHELL_SUPPORT_PRINTF_UNICODE_SFORMAT=0
         [ "$DEBUG" -eq 1 ] && echo >&2 "Shell NO SUPPORT for printf unicode right/left adjustment"
    fi

    unset od_unicode
}

argEmptyOrOption() {
    [ "$DEBUG" -eq 1 ] && echo >&2 argEmptyOrOption "$@"
    if [ -z "$1" ]; then
        return 0
    else
        case "$1" in

        -*)
            return 0
            ;;

        *)
            return 1
            ;;
        esac
    fi
}

getDateUTC()
{
    VALUE_DATE_UTC=$(date -u -d @"$1" +'%F %T') #add field
}

newRuler()
#creates a ruler for debugging positioning on screen
{
    n=1
    unset VALUE_RULER
    while [ "$n" -le "$1" ]; do
        VALUE_RULER=$VALUE_RULER"123456789${ANSIESC_SGI_BOLD_INVERT}0${ANSIESC_SGI_NORMAL}"
        n=$(( n + 1 ))
    done

    unset n
}

parseRangeExpression()
{
    IFS=- # range with hyphen, for example 31-33
            #shellcheck disable=SC2086
    set -- $1
    VALUE_RANGE_LOW=$1 #global for use if 
    VALUE_RANGE_HIGH=$2
}

padSpaceRight()
# insert trailing spaces
# $1 string $2 width
# set VALUE_PADSPACERIGHT
{
    VALUE_PADSPACERIGHT="$1"
    padspacenum=$(( $2 - ${#1} ))
    if [ $padspacenum -le 0 ]; then
      return 1
    fi

    padspace_n=1
    while  [ $padspace_n -le $padspacenum ]; do
        VALUE_PADSPACERIGHT="$VALUE_PADSPACERIGHT "
        padspace_n=$(( padspace_n + 1 ))
    done

    unset padspace_n padspacenum
}

getVersionInt()
# get version integer from GW1000A_V1.6.8 -> 168
# $1 version
# set VALUE_VERSION
{
    VALUE_VERSION=$1
    VALUE_VERSION=${VALUE_VERSION#*_V}
    IFS=.
    #shellcheck disable=SC2086
    set -- $VALUE_VERSION
    VALUE_VERSION="$1$2$3"

}

isGWdevice()
# device firmware version
# $1 version string
{
    case "$1" in
      GW*) return 0 ;;
      *) return 1 ;;
    esac
}


