cd ~/.wine/drive_c/Colin\ McRae\ Rally\ 2.0
wine explorer /desktop=name,800x600 CMR2.exe
xrandr -s 0

echo '1' 2> /dev/null >> ~/scripts/stats/${0##*/}
