# fits
###
programs in c,c++ and fortran to read and write FITS files
###
Works on MS Windows with the MinGW gcc,g++,gfortran compilers.
To compile on GNU/linux with gcc,g++,gfortran
(needs NASA cfitsio lib.). It is supposed that
the the libraries and .h header files are in the directory
pointed by CFITSIO_HOME env variable, otherwise change the makefile.
It can be compiled also with clang,clang++ and flang.
###
`make`
###
to run on linux
###
`./writefimage 3 5 img3x5_001.fits`
###
`./readfimage img3x5_001.fits`
###
fimage2ascii converts a fits image file in image matrix data ascii file.
###
`./fimage2ascii <<< m31sl2.fits 2>err.log > m31sl2.asc`
