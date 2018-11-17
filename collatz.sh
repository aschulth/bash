#!/bin/bash
# Author: A. Schultheiss, 2018
# License: GPLv3
#
# Calculates the Collatz sequence for any positive integer > 0.
# The conjecture is that for any given positive integer > 0 the
# sequence is finite and will end with 1.
#
# Input: int > 0
# Output: Collatz sequence.
readonly SCRIPT=${0##*/}

function logf() {
  echo "$(date +%FT%T.%N) FATAL ${FUNCNAME[1]}: $1" >&2
}

function usage() {
  cat << EOT
  SYNOPSIS
    ${SCRIPT} - Calculate the Collatz sequence for any given
    positive integer > 0.
  
  USAGE
    ${SCRIPT} -h
    ${SCRIPT} <int>
  
  EXAMLE
    ${SCRIPT} 3
    - Output: 3 10 5 16 8 4 2 1
    
EOT
}

function is_int() {
  [[ $1 =~ ^[0-9]+$ ]]
}

function is_even() {
  [[ -z $1 ]] && return 1
  [[ $(( $1 % 2 )) -eq 0 ]]
} 

function divide_by_two() {
  [[ -z $1 ]] && return 1
  echo "$(( $1 / 2 )) "
}

function times_three_plus_one() {
  [[ -z $1 ]] && return 1
  echo "$(( 3 * $1 + 1 ))"
}

function sequence() {
  ( [[ -z $1 || $1 -eq 0 ]] || ! is_int $1 ) && return 1
  
  echo $1 && [[ $1 -eq 1 ]] && return
  
  is_even $1 \
  && sequence $(divide_by_two $1) \
  || sequence $(times_three_plus_one $1)
}

main() {
  [[ $1 =~ ^-h$ ]] && usage && return
  
  if ! sequence $1; then
    logf "Invalid input format! Want: int > 0, have: '$1'!"
    exit 1
  fi
}

main "$@"