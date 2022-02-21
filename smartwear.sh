#! /bin/sh

# Copyright (c) 2018-2022 Slawomir Wojciech Wojtczak (vermaden)
# All rights reserved.
#
# THIS SOFTWARE USES FREEBSD LICENSE (ALSO KNOWN AS 2-CLAUSE BSD LICENSE)
# https://www.freebsd.org/copyright/freebsd-license.html
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that following conditions are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS 'AS IS' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ------------------------------
# SSD WEAR FROM smartcrl(8) TOOL
# ------------------------------
# vermaden [AT] interia [DOT] pl
# https://vermaden.wordpress.com

__usage() {
  cat << __EOF
usage: $( basename ${0} ) DEVICE [TBW]

__EOF
  exit 1
}

[ ${#} -ne 1 -a ${#} -ne 2 ] && __usage

REGEX="[0-9]+"
REGEX_NUMBER=$( echo ${2} | grep -E -o "${REGEX}" )

if [ "${2}" != "${REGEX_NUMBER}" ]
then
  echo "NOPE: the TBW must be natural number of TERABYTES"
  exit 1
fi

if [ ! -e "${1}" ]
then
  echo "NOPE: device '${1}' does not exists"
  exit 1
fi

SMARTCTL=$( smartctl -a "${1}" )
DISK=$( diskinfo -v "${1}" | awk -F '#' '/Disk descr./ {print $1}' | tr -d '\t' )
SECTOR=$( echo "${SMARTCTL}" | awk '/Sector Size/ {print $3}' )
LBA=$( echo "${SMARTCTL}" | awk '/Total_LBAs_Written/ {print $NF}' )

echo "Disk: ${DISK}"
echo "Sector: ${SECTOR}"

if ! echo "${SMARTCTL}" | grep -q Total_LBAs_Written
then
  echo "Written (Sectors): [DATA NOT AVAILABLE]"
  echo "Written (TB): [DATA NOT AVAILABLE]"
else
  WRITTEN=$( echo "scale=1; ${SECTOR} * ${LBA} / 1024 / 1024 / 1024 / 1024" | bc -l )
  echo "Written (Sectors): ${LBA}"
  printf "Written (TB): %3.1f\n" ${WRITTEN}
fi

if [ ${2} ]
then
  printf "Written/TBW (%%): %3.1f\n" $( echo ${WRITTEN} / ${2} \* 100 | bc -l )
fi

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
