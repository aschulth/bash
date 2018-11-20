#!/bin/bash
readonly SCRIPT=${0##*/}

# Icinga exit codes
readonly EXIT_OK=0
readonly EXIT_WARN=1
readonly EXIT_CRIT=2
readonly EXIT_UNKN=3

function logf() {
  echo "$(date +%FT%T.%N) FATAL ${FUNCNAME[1]}: $1" >&2
}

function usage() {
  cat << EOT
  NAME
    ${SCRIPT} - Icinga port check
  
  DESCRIPTION
  
  OPTIONS
    -h|--help
      Print this help page.
    
    --warning=<float>
      Warning threshold for the response time if the port is up (NOTE: A
      leading number is required. Expressions like '.02' are invalid).
      If used in combination with --status=down, this option is ignored.
      
    --critical=<float>
      Critical threshold for the response time if the port is up (NOTE: A
      leading number is required. Expressions like '.02' are invalid).
      If used in combination with --status=down, this option is ignored.
      
    --target=<proto>://<FQDN|IP>:<port>
      FQDN|IP:port of the target to be checked.
      
    --status=up|down
      The expected status of the port to be checked (default: up).
  
  EXAMPLES
    ${SCRIPT} --target=tcp://www.example.com:12345
    ${SCRIPT} --target=tcp://www.example.com:12345 --status=up
      Checks whether www.example.com:12345(TCP) is up. Otherwise issues
      a critical.
    
    ${SCRIPT} --target=udp://www.example.com:12345
      Checks whether www.example.com:12345(UDP) is up. Otherwise issues
      a critical.
    
    ${SCRIPT} --target=tcp://www.example.com:12345 --status=down
      Checks whether www.example.com:12345(TCP) is down. Otherwise issues
      a critical.
      
    ${SCRIPT} --warning=0.01 --critical=0.02 --target=www.example.com:12345 \
        --proto=tcp
      Checks whether www.example.com:12345(TCP) is up. Otherwise issues
      a critical. If the response time is greate or equal to 10ms it will
      issues a warning. If it is greater or equal to 20ms it will issue
      a critical.
      
EOT
}

function parse_args_or_die() {
  if [[ -z $@ ]]; then
    logf "No arguments given! See '${SCRIPT} -h' for invocation."
    exit ${EXIT_UNKN}
  fi
  
  for arg in "$@"; do
    case ${arg} in
      -h|--help) usage; exit ;;
      --warning=*)
        if ! parse_float ${arg#*=} >/dev/null 2>&1; then
          logf "Invalid parameter format to argument '${arg%%=*}'!"
          logf "Want: <unsigned float>, have: '${arg#*=}'."
          exit ${EXIT_UNKN}
        fi
        WARN=${arg#*=}
        
      --critical=*)
        if ! parse_float ${arg#*=} >/dev/null 2>&1; then
          logf "Invalid parameter format to argument '${arg%%=*}'!"
          logf "Want: <unsigned float>, have: '${arg#*=}'."
          exit ${EXIT_UNKN}
        fi
        CRIT=${arg#*=}
        
      --target=*) TARGET=${arg#*=} ;;
      --proto=*) PROTO=${arg#*=} ;;
      --status=*) STATUS=${arg#*=} ;;
      *)
        logf "Unrecognized argument '${arg%%=*}'!"
        exit ${EXIT_UNKN}
        ;;
    esac
  done
  
  # set defaults
  PROTO=${PROTO:-tcp}
  STATUS=${STATUS:-up}
  
  if [[ -z ${TARGET} ]]; then
    logf "No target authority given to check!"
    exit ${EXIT_UNKN}
  fi
}

function parse_float() {
  [[ -z $1 || ! $1 =~ [0-9]+\.[0-9]+$ ]] && return 1
  echo $1
}

function main() {
  #parse_args_or_die "$@"
}

main "$@"