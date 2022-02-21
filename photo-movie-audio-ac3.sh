#! /bin/sh

if [ ${#} -eq 0 -o ${#} -ne 3 ]
then
  echo "usage: ${0##*/} ARATE VRATE FILE"
  echo
  exit 1
fi

ARATE=${1}
VRATE=${2}

ffmpeg -y -i "${3}" -acodec ac3 -ab ${1}k -aq 50 -vcodec libx264 -threads 1 \
       -minrate 0k -bufsize ${2}k -maxrate ${2}k "${3}".x264.mkv

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
