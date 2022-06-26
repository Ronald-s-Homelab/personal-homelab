#!/bin/bash

usage() {
    echo "Usage: $0 -d <mydomain.com> [-d <additionaldomain.com>] [options ...]
Options:
    -h, --help          Show this help message.
    -d, --domain        Specifies domain for cert, allowed multiple times.
    -f, --force         Force cert renewal.
    -r, --renew         Renew Certificate.
    --debug [0|1|2|3]   Output debug info. Defaults to 1 if argument is omitted.
" 1>&2; exit 1;
}

kill_and_wait() {
    local pid=$1
    [ -z $pid ] && return

    kill $pid 2> /dev/null
    while kill -s 0 $pid 2> /dev/null; do
        sleep 1
    done
}

log() {
    if [ -z "$2" ]
    then
        printf -- "%s %s\n" "[$(date)]" "$1"
    fi
}

while [ ${#} -gt 0 ]; do
    case "${1}" in
        -h|--help)
            usage
            ;;
        -f|--force)
            FORCE="--force"
            ;;
        -r|--renew)
            RENEW="--renew"
            ;;
        -i)
            shift
            ;;
        -d|--domain)
            if [ -z "$2" ] || [ "${2:0:1}" = "-" ]; then
                echo "Domain required"
                usage
            fi
            DOMAIN+=("$2")
            shift
            ;;
        --debug)
            if [ -z "$2" ] || [ "${2:0:1}" = "-" ]; then
                DEBUG="--debug 1"
            else
                DEBUG="--debug ${2}"
                shift
            fi
            ;;
        *)
            echo "Unknown parameter : ${1}"
            usage
            ;;
    esac
    shift 1
done

# check for required parameters
if [ ${#DOMAIN[@]} -eq 0 ]; then
    echo "Domain required"
    usage
fi

# prepare our domain flags for acme.sh
for val in "${DOMAIN[@]}"; do
     DOMAINARG+="-d $val "
done

ACMEHOME=/config/.acme.sh

mkdir -p /config/ssl
# trick sudo detection in acme.sh
unset SUDO_COMMAND
$ACMEHOME/acme.sh --issue $DOMAINARG --dns $RENEW \
--reloadcmd "cat $ACMEHOME/${DOMAIN[0]}/${DOMAIN[0]}.cer $ACMEHOME/${DOMAIN[0]}/${DOMAIN[0]}.key > /config/ssl/server.pem; cp $ACMEHOME/${DOMAIN[0]}/ca.cer /config/ss
l/ca.pem" \
--server letsencrypt ${FORCE} ${DEBUG}

log "Stopping temporary ACME challenge service."
if [ -e "$ACMEHOME/lighttpd.pid" ]; then
    kill_and_wait $(cat $ACMEHOME/lighttpd.pid)
fi

log "Starting GUI service."
if [ -x "/bin/systemctl" ]; then
    /bin/systemctl start lighttpd.service
else
    /usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
fi
