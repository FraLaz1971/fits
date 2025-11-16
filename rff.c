#include <stdio.h>
#include <string.h>
#include "fitsio.h"

void printerror( int status);

int main(){
  char keyname[32], cmt[128];
  int status, nfound;
  long naxis=0, naxes[2]={0,0}, bitpix=0;
  fitsfile *fp;
  char *fname="mercury1_500x320.fits";
  strcpy(keyname, "NAXIS");
  if(fits_open_file(&fp, fname, READONLY, &status)) printerror(status);
  printf("rff: file %s open\n", fname);
  if ( fits_read_keys_lng(fp, keyname, 1, 2, naxes, &nfound, &status) )
         printerror( status );
  printf("rff: keys %s read\n", keyname);
  printf("nfound = %d \n",nfound);
  printf("naxis = %ld \n",naxis);
  printf("naxes[0] = %ld \n",naxes[0]);
  printf("naxes[1] = %ld \n",naxes[1]);

  strcpy(keyname,"BITPIX");
  printf("keyname = %s\n",keyname);
  if(fits_read_key_lng(fp,"BITPIX",&bitpix,cmt,&status)) printerror(status);
  printf("comment = %s \n",cmt);
  printf("bitpix = %ld \n",bitpix);

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
       exit( status );    /* terminate the program, returning error status */
    }
    return;
}
