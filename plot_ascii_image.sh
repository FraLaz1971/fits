#!/bin/bash
if [[ $# != 1 ]]
then
  echo "usage: $(basename $0) <image.asc>"
  exit 1
fi
GNUPLOT="gnuplot -p "
ifname=$1
ofname=${ifname:0:-4}".gp"
#echo set size square>$ofname
echo unset border>>$ofname
echo unset xlabel>>$ofname
echo unset ylabel>>$ofname
echo unset xtics>>$ofname
echo unset ytics>>$ofname
echo set title ''>>$ofname
echo "set palette gray; plot '"$1"' matrix with image">>$ofname
$GNUPLOT $ofname

