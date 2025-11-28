rem gnuplot ascii matrix
echo off
set GNUPLOT=gnuplot -p 
set ifname=%1
set ofname=%ifname%.gp
echo set size square>%ofname%
echo unset border>>%ofname%
echo unset xlabel>>%ofname%
echo unset ylabel>>%ofname%
echo unset xtics>>%ofname%
echo unset ytics>>%ofname%
echo set title ''>>%ofname%
echo set palette gray; plot '%1' matrix with image>>%ofname%
%GNUPLOT% %ofname%
echo ciao

