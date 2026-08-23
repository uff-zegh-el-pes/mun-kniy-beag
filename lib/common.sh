#!/usr/bin/env bash

if LC_ALL=C.UTF-8 grep -qnP '[\x{201C}\x{201D}\x{2018}\x{2019}\x{2014}\x{2013}]' "$0"; then
	    echo "Smart punctuation found" >&2
	    exit 1
	fi


# = =    Config     = = = = = = =

SYSTEM_DISK="${SYSTEM_DISK:-/dev/nvme0n1}"
DATA_DISK="${DATA_DISK:-/dev/nvme1n1}"


USERNAME="logic"
HOSTNAME="machineherald"
KEYMAP="colemak"
TIMEZONE="America/New_York"
LOCALE="en_US.UTF-8"


RETRY_LIMIT=10


# = =    Partitions     = = = = = =


partsuffix() { [[ "$1" =~ [0-9]$ ]] && printf p || printf ''; }

SYSPART1="${SYSTEM_DISK}$(partsuffix "$SYSTEM_DISK")1"
SYSPART2="${SYSTEM_DISK}$(partsuffix "$SYSTEM_DISK")2"
DATAPART1="${DATA_DISK}$(partsuffix "$DATA_DISK")1"


# = =    Helpers     = = = = = = =


retry() {
    local attempt=1
    local answer
    until "$@"; do
        if (( attempt >= RETRY_LIMIT )); then
            echo "" >&2
            echo "Failed $RETRY_LIMIT times:" >&2
            echo "  $*" >&2
            read -rp "Continue anyway? YES or NO: " answer
            [[ "$answer" == YES ]] && return 0
            exit 1
        fi
        echo "Attempt $attempt failed. Retrying..." >&2
        attempt=$(( attempt + 1 ))
        sleep 2
    done
}


confirm() {
    local answer
    read -rp "Type YES to continue: " answer
    [[ "$answer" == YES ]] || exit 1
}


require_disk() {
    [[ -b "$1" ]] || { echo "Not a block device: $1" >&2; exit 1; }
}
