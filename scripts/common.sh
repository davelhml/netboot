#! /bin/bash

function __readINI() {
    # $1:ini, $2:section, $3:key
    awk -F'=' -v section="[$2]" -v key="$3"  '
       $0==section{ f=1; next }  # Enable a flag when the line is like your section
       /\[/{ f=0; next }         # For any lines with [ disable the flag
       f && $1==key{ print $2 }  # If flag is set and first field is the key print key=value
    ' $1
}

function log() {
    logger -p local0.warn -t "[$0]" -s "$*" 2>&1 | tee -a ~/.git.log
}

function logwarn() {
    echo -e "\033[1;32m\033[100m$*\033[0m"
}

function die() {
    echo -e "\033[1;31mFatal: $*\033[0m"
    exit 1
}
