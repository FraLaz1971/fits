#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"
void printerror(int status);

int main(int argc, char **argv){
  fitsfile *fp;
  char cmt[128], keyname[32];
  int status, nfound;
  long int naxis=0,naxes[2]={0,0},bitpix=0;
  if(argc<2){
    fprintf(stderr,"usage:%s <nrows> <ncols> <fitsfile>\n",argv[0]);
    return 1;
  }
  long nrows=atol(argv[1]), ncols=atol(argv[2]);
  unsigned char(* arr)[ncols]=malloc(sizeof(unsigned char [nrows][ncols]));
  long npixels=nrows*ncols;
  char *fname=argv[3];
  /* open image file */
  if(fits_open_file(&fp,fname,READONLY,&status)) printerror(status);
  fprintf(stderr,"opened image file %s\n",fname);

  /* read the NAXIS1 and NAXIS2 keyword to get image size */
  /*

int fits_read_keys_[log, lng, flt, dbl] / ffgkn[ljed]
      (fitsfile *fptr, char *keyname, int nstart, int nkeys,
        > DTYPE *numval, int *nfound, int *status)

  strcpy(keyname,"NAXIS");*/
    if ( fits_read_keys_lng(fp, "NAXIS", 1, 2, naxes, &nfound, &status) )
         printerror( status );

  printf("nfound = %d \n",nfound);
  printf("naxis = %ld \n",naxis);
  printf("naxes[0] = %ld \n",naxes[0]);
  printf("naxes[1] = %ld \n",naxes[1]);
/* 
 int fits_read_key_[log, lng, flt, dbl, cmp, dblcmp] / ffgky[ljedcm]
      (fitsfile *fptr, char *keyname, > DTYPE *numval, char *comment,
       int *status)
 */  
/*  printf("naxes[0]=%ld naxes[1]=%ld\n",naxes[0],naxes[1]); */
/*  strcpy(keyname,"BITPIX");
  printf("keyname = %s\n",keyname);
  if ( fits_read_keys_lng(fp, "BITPIX", 1, 1, &bitpix, &nfound, &status) )
         printerror( status );*/
  if(fits_read_key_lng(fp,"BITPIX",&bitpix,cmt,&status)) printerror(status);
  printf("comment = %s \n",cmt);
  printf("bitpix = %ld \n",bitpix); 
  /* close image file */
  free(arr);
  if(fits_close_file(fp,&status)) printerror(status);
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
      /* exit( status );     terminate the program, returning error status */
    }
    return;
}

