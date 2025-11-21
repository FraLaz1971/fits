#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"
void printerror( int status);
int main(int argc, char **argv){
  long nrows,ncols,naxis=2,naxes[2], nelements;
  int status,i,j,bitpix=USHORT_IMG; /* 16 bit*/
  long *fpixel;
  unsigned short count=0;
  char fname[128];
  fitsfile *ofp;
  unsigned short *block;
  if(argc<4){
    fprintf(stderr,"usage:%s <nrows> <ncols> <fitsfile>\n",argv[0]);
    return 1;
  }
  nrows=atol(argv[1]); ncols=atol(argv[2]);
  if(nrows <= 0 || ncols <= 0) {
    fprintf(stderr, "Error: nrows and ncols must be positive integers\n");
    return 1;
  }

  naxes[0]=ncols;naxes[1]=nrows;
  nelements=naxes[0]*naxes[1];
  block = (unsigned short *)malloc(nelements*sizeof(unsigned short));
  fpixel = (long *)malloc(3*sizeof(long));
 /* initialize pointers to the start of each row of the image */
    strcpy(fname,argv[3]);
    remove(fname);
    puts("removed old file");
  /* create fits file */
    status=0;
    if (fits_create_file(&ofp, fname, &status)) /* create new FITS file */
         printerror( status );           /* call printerror if error occurs */
    puts("created the file");

  /* create image */
    /* write the required keywords for the primary blockay image.     */
    /* Since bitpix = USHORT_IMG, this will cause cfitsio to create */
    /* a FITS image with BITPIX = 16 (signed short integers) with   */
    /* BSCALE = 1.0 and BZERO = 32768.  This is the convention that */
    /* FITS uses to store unsigned integers.  Note that the BSCALE  */
    /* and BZERO keywords will be automatically written by cfitsio  */
    /* in this case.                                                */

    if ( fits_create_img(ofp,  bitpix, naxis, naxes, &status) )
         printerror( status );
   puts("created the image");
  nelements=nrows*ncols;
  fpixel[0] = 1;   /* column index, starting at 1 */
  fpixel[1] = 1;   /* row index, starting at 1 */
  /* fill the blockay */
  for(i=0;i<nrows;i++){
    for(j=0;j<ncols;j++){
         block[i*ncols+j]=(unsigned short)(i*ncols+j+1);
         printf("%hd ",block[i*ncols+j]);
    }
    puts("");
  }
  /* int fits_write_pix(fitsfile *fptr, int datatype, long *fpixel,
               long nelements, void *array, int *status); */
  /* write image */
    if ( fits_write_pix(ofp, TUSHORT, fpixel, nelements, block, &status) ) printerror( status );
    puts("written the image");

  free(block);
  free(fpixel);
  /* close file */
    if ( fits_close_file(ofp, &status) )                /* close the fits file */
         printerror( status );
    puts("closed the file");
  return 0;
}
