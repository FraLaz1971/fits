#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"
void printerror( int status);
int main(int argc, char **argv){
  long nrows,ncols,naxis=2,naxes[2], fpixel=1, nelements;
  int status,i,j,bitpix=USHORT_IMG; /* 16 bit*/
  unsigned short count=0;
  char fname[128];
  fitsfile *ofp;
  if(argc<4){
    fprintf(stderr,"usage:%s <nrows> <ncols> <fitsfile>\n",argv[0]);
    return 1;
  }
  nrows=atol(argv[1]); ncols=atol(argv[2]);
  naxes[0]=ncols;naxes[1]=nrows;
  unsigned short *arr[naxes[1]];
  /* allocate memory for the whole image */
  arr[0] = (unsigned short *)malloc(naxes[0]*naxes[1]*sizeof(unsigned short));
 /* initialize pointers to the start of each row of the image */
  for(i=1; i<naxes[1];i++)
    arr[i] = arr[i-1]+naxes[0];
  nelements=naxes[0]*naxes[1];
  strcpy(fname,argv[3]);
    remove(fname);
    puts("removed old file");
  /* create fits file */
    status=0;
    if (fits_create_file(&ofp, fname, &status)) /* create new FITS file */
         printerror( status );           /* call printerror if error occurs */
    puts("created the file");

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
   puts("created the image");
  /* fill the array */
  for(i=0;i<nrows;i++){
    for(j=0;j<ncols;j++){
         arr[i][j]=(unsigned short)(i*ncols+j);
         printf("%hd ",arr[i][j]);
    }
    puts("");
  }
  /* write image */
    if ( fits_write_img(ofp, TUSHORT, fpixel, nelements, (unsigned short*)*arr, &status) )
        printerror( status );
    puts("written the image");

   free(arr[0]);

  /* close file */
    if ( fits_close_file(ofp, &status) )                /* close the fits file */
         printerror( status );
    puts("closed the file");

  return 0;
}
void printerror( int status)
{
    /*****************************************************/
    /* Print out cfitsio error messages and exit program */
    /*****************************************************/


    if (status)
    {
       fits_report_error(stderr, status); /* print error report */

       exit( status );    /* terminate the program, returning error status */
    }
    return;
}

