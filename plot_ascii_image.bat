rem gnuplot ascii matrix
echo off
set GNUPLOT=gnuplot -p 
set ifname=%1
set ofname=%ifname%.gp
echo set palette gray; plot '%1' matrix with image>%ofname%
%GNUPLOT% %ofname%
echo ciao

