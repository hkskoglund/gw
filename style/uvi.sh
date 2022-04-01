#!/bin/sh
#shellcheck disable=SC2034
#export STYLE_UVI_LOW="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_BRIGHT_GREEN}m"
#export STYLE_UVI_MODERATE="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_BRIGHT_YELLOW}m"
#export STYLE_UVI_HIGH="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC$SGI_BACKGC${SGI_COLOR_ORANGE}m"
#export STYLE_UVI_VERY_HIGH="$CSI$SGI_FOREGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_BRIGHT_RED}m"
#export STYLE_UVI_EXTERME="$CSI$SGI_BACKGC$SGI_COLOR_BLACK;$SGI_BACKGC${SGI_COLOR_MAGENTA}m"

# standard colors - watch --color compatibility procps-ng 3.3.16
export STYLE_UVI_LOW="$CSI${SGI_FOREGC_BLACK}m$CSI${SGI_BACKGC_GREEN}m"  
export STYLE_UVI_MODERATE="$CSI${SGI_FOREGC_BLACK}m$CSI${SGI_BACKGC_YELLOW}m" 
export STYLE_UVI_HIGH="$CSI${SGI_FOREGC_BLACK}m${CSI}${SGI_BACKGC_BLUE}m"
export STYLE_UVI_VERY_HIGH="$CSI${SGI_FOREGC_BLACK}m${CSI}${SGI_BACKGC_RED}m"
export STYLE_UVI_EXTREME="$CSI${SGI_FOREGC_BLACK}m${CSI}${SGI_BACKGC_MAGENTA}m"

setStyleUVI()
#$1 UVI
#https://en.wikipedia.org/wiki/Ultraviolet_index
{
    #TEST set -- 11
    if [ "$1" -ge 0 ] && [ "$1" -le 2 ]; then
       STYLE_UVI=$STYLE_UVI_LOW
    elif [ "$1" -ge 3 ] && [ "$1" -le 5 ]; then
        STYLE_UVI=$STYLE_UVI_MODERATE
    elif [ "$1" -ge 6 ] && [ "$1" -le 7 ]; then
        STYLE_UVI=$STYLE_UVI_HIGH
    elif [ "$1" -ge 8 ] && [ "$1" -le 10 ]; then
        STYLE_UVI=$STYLE_UVI_VERY_HIGH
    elif [ "$1" -ge 11 ]; then
        STYLE_UVI=$STYLE_UVI_EXTREME
    fi
}
