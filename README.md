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
###
`addfbtable.c`
###
`addfbtable.exe`
###
`usage:addfbtable.exe <infile.fits>`
###
now running this command, where mynewfile001.fits it's a fits
image of Mercury planet surface, seen by Mariner 10 spacecraft in 1974.
###
![mercury planet by Mariner 10 (1974)](mercury.png)
###
`addfbtable.exe mynewfile001.fits` 
set_chdu() current hdu set to 1
set_chdu() going to open fits file mynewfile001.fits
set_chdu() opened fits file mynewfile001.fits
set_chdu() moved to hdu 1 tyoe 0
main() hdu set
add_table() defined columns metadata
add_table() defined columns content
add_table() created table
add_table() written column 1
add_table() written column 2
add_table() written column 3
add_table() closed fits file
main() binary table addedd
###
cfirst.c
This program takes in input a fits file and prints header keywords
usage: cfirst <fitsfile>
cfirst image001.fits
FLEN_CARD =81
SIMPLE  =                    T / file does conform to FITS standard
BITPIX  =                    8 / number of bits per data pixel
NAXIS   =                    2 / number of data axes
NAXIS1  =                  500 / length of data axis 1
NAXIS2  =                  320 / length of data axis 2
EXTEND  =                    T / FITS dataset may contain extensions
COMMENT   FITS (Flexible Image Transport System) format is defined in 'Astronomy
COMMENT   and Astrophysics', volume 376, page 359; bibcode: 2001A&A...376..359H
DATE    = '2025-11-18T10:28:27' / file creation date (YYYY-MM-DDThh:mm:ss UT)
EXPOSURE=                 1500 / Total Exposure Time
END
###
changekeys.c
`changekeys`
usage:changekeys <nrows> <ncols> <infile>
`changekeys 320 500 image001.fits`
changekeys: temp=.fits
changekeys: n=8
changekeys: ofname=image001_new.fits
changekeys: going to open the file image001.fits
changekeys: file yet open
changekeys:going to read file keywords
changekeys:keywords read
changekeys:naxis = 2
changekeys:naxes[0] = 500
changekeys:naxes[1] = 320
changekeys:npixels = 160000
changekeys: going to close the input file image001.fits
changekeys: input file yet closed
changekeys: going to open the output file image001_new.fits
changekeys: output file yet opened
changekeys: going to create the image in image001_new.fits
changekeys: image yet created
changekeys: going to write the image in image001_new.fits
changekeys: image yet written
changekeys: going to close the output file image001_new.fits
changekeys: input file yet closed
###
cookbook.c
cookbook is the example program of the cfitsio library, it execute all example of write/read of images, 
tables and keywords(metadata)
###
createimage.c
usage:createimage <nrows> <ncols> <fitsfile>
  /* create image */
    /* write the required keywords for the primary array image.     */
    /* Since bitpix = USHORT_IMG, this will cause cfitsio to create */
    /* a FITS image with BITPIX = 16 (signed short integers) with   */
    /* BSCALE = 1.0 and BZERO = 32768.  This is the convention that */
    /* FITS uses to store unsigned integers.  Note that the BSCALE  */
    /* and BZERO keywords will be automatically written by cfitsio  */
    /* in this case.                                                */

###
createraw.c
###
fimage.c
###
fimage2bin.c
###
pofp2d.c
###
pofp2df.c
###
readfdimg.c
###
readfimage.c
###
readfimg.c
###
readraw.c
###
readrawf.c
###
readwriterawf.c
###
rff.c
###
sizes.c
###
structrows.c
###
testf1.c
###
testf2.c
###
testf3.c
###
teststrx.c
###
writefimage.c
###
writefits.c
###
writeftable.c
###
