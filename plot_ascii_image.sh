#!/bin/bash
if [[ $# != 1 ]]
then
  echo "usage: $(basename $0) <image.asc>"
  exit 1
fi
GNUPLOT="gnuplot -p "
ifname=$1
PP=`expr index $fname "."`
PPM1=$(( $PP - 1 ))
ofname=${ifname:0:$PPM1}".gp"
echo "set palette gray; plot '"$1"' matrix with image">$ofname
$GNUPLOT $ofname

