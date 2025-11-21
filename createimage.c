#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"
void printerror( int status);
int main(int argc, char **argv){
  long nrows,ncols,naxis=2,naxes[2], *fpixel, nelements;
  int status,i,j,bitpix=USHORT_IMG; /* 16 bit*/
  unsigned short val,count=0;
  char fname[128];
  fitsfile *ofp;
  unsigned short **arr;
  if(argc<4){
    fprintf(stderr,"usage:%s <nrows> <ncols> <fitsfile>\n",argv[0]);
    return 1;
  }
  nrows=atol(argv[1]); ncols=atol(argv[2]);
  naxes[0]=ncols;naxes[1]=nrows;
  /*arr = (unsigned short *)malloc(naxes[1]*sizeof(unsigned short));*/
  /* allocate memory for the whole image */
  arr = (unsigned short **)malloc(naxes[1]*sizeof(unsigned short*));
  for(i=0; i<naxes[1]; i++)
	arr[i]=(unsigned short *)malloc(naxes[0]*sizeof(unsigned short));
  fpixel=(long *)malloc(3*sizeof(long));
 /* initialize pointers to the start of each row of the image */
  nelements=naxes[0]*naxes[1];
  strcpy(fname,argv[3]);
    remove(fname);
    puts("createimage: removed old file");
  /* create fits file */
    status=0;
    if (fits_create_file(&ofp, fname, &status)) /* create new FITS file */
         printerror( status );           /* call printerror if error occurs */
    puts("createimage: created the file");

  /* create image */
    /* write the required keywords for the primary array image.     */
    /* Since bitpix = USHORT_IMG, this will cause cfitsio to create */
    /* a FITS image with BITPIX = 16 (signed short integers) with   */
    /* BSCALE = 1.0 and BZERO = 32768.  This is the convention that */
    /* FITS uses to store unsigned integers.  Note that the BSCALE  */
    /* and BZERO keywords will be automatically written by cfitsio  */
    /* in this case.                                                */

    if ( fits_create_img(ofp,  bitpix, naxis, naxes, &status) )
         printerror( status );
   puts("createimage: created the image");
  /* fill the array and write image 
   int fits_write_pix(fitsfile *fptr, int datatype, long *fpixel,
               long nelements, void *array, int *status);
Write pixels into the FITS data array. 'fpixel' is an array of length NAXIS which gives the coordinate of the starting pixel to be written 
to, such that fpixel[0] is in the range 1 to NAXIS1, fpixel[1] is in the range 1 to NAXIS2, etc. 
The first pair of routines simply writes the array of pixels to the FITS file (doing data type conversion if necessary) whereas the second
routines will substitute the appropriate FITS null value for any elements which are equal to the input value of nulval 
(note that this parameter gives the address of the null value, not the null value itself). 
For integer FITS arrays, the FITS null value is defined by the BLANK keyword (an error is returned if the BLANK keyword doesn't exist). 
For floating point FITS arrays the special IEEE NaN (Not-a-Number) value will be written into the FITS file. 
If a null pointer is entered for nulval, then the null value is ignored and this routine behaves 
the same as fits_write_pix. 


   */
  fpixel[0]=1; /* in the range [1,ncols] (x-axis) */
  fpixel[1]=1;/* in the range [1,nrows] (y-axis) */
  nelements=1;
  for(i=0;i<nrows;i++){
    for(j=0;j<ncols;j++){
         arr[i][j]=(unsigned short)(i*ncols+j+1);
         fpixel[0]=j;
         fpixel[1]=i;
         val=arr[i][j];
         val=200;
         if ( fits_write_pix(ofp, TUSHORT, fpixel, nelements, &val, &status) ) printerror( status );
         printf("%hd ",arr[i][j]);
    }
    puts("");
  }
    puts("createimage: written the image");

  for(i=0; i<naxes[1]; i++)
	free(arr[i]);
  free(arr);
  free(fpixel);
    /* close file */
    if ( fits_close_file(ofp, &status) )                /* close the fits file */
         printerror( status );
    puts("createimage: closed the file");
  return 0;
}
