#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"
void printerror(int status);

int main(int argc, char **argv){
  fitsfile *fp;
  char cmt[128], keyname[32];
  int status, nfound=0, anynull=0;
  long int naxis=0,naxes[2]={0,0},bitpix=0,fpixel=1,npixels,i,j;
  unsigned short nullval=0;
  unsigned short ** arr;
  char *fname=argv[1];
  if(argc<2){
    fprintf(stderr,"usage:%s <fitsfile>\n",argv[0]);
    return 1;
  }
  /* open image file */
  status=0;
  if(fits_open_file(&fp,fname,READONLY,&status)) printerror(status);
  fprintf(stderr,"opened image file %s\n",fname);

  /* read the NAXIS1 and NAXIS2 keyword to get image size */
  /*

int fits_read_keys_[log, lng, flt, dbl] / ffgkn[ljed]
      (fitsfile *fptr, char *keyname, int nstart, int nkeys,
        > DTYPE *numval, int *nfound, int *status)

*/  strcpy(keyname,"NAXIS");
    status=0;
    if ( fits_read_keys_lng(fp, keyname, 1, 2, naxes, &nfound, &status) )
         printerror( status );

  printf("nfound = %d \n",nfound);
  printf("naxis = %ld \n",naxis);
  printf("naxes[0] = %ld \n",naxes[0]);
  printf("naxes[1] = %ld \n",naxes[1]);

    status=0;
if( fits_read_key_lng(fp, (char*)keyname, &naxis, (char *)cmt,&status)) printerror(status);
  printf("status = %d \n",status);
  printf("naxis = %ld comment: %s\n",naxis,cmt); 

/* 
 int fits_read_key_[log, lng, flt, dbl, cmp, dblcmp] / ffgky[ljedcm]
      (fitsfile *fptr, char *keyname, > DTYPE *numval, char *comment,
       int *status)
 */  
/*  printf("naxes[0]=%ld naxes[1]=%ld\n",naxes[0],naxes[1]); 
  strcpy(keyname,"BITPIX");
  printf("keyname = %s\n",keyname);
  if ( fits_read_keys_lng(fp, "BITPIX", 1, 1, &bitpix, &nfound, &status) )
         printerror( status );*/
  strcpy(keyname,"BITPIX");
  status=0;
  if(fits_read_key_lng(fp,keyname,&bitpix,(char*)cmt,&status)) printerror(status);
  printf("status = %d \n",status);
  printf("bitpix = %ld comment: %s\n",bitpix,cmt); 
  arr=(unsigned short**)malloc(sizeof(naxes[0]*sizeof(unsigned short*)));
  for(i=0;i<naxes[0];i++)
  arr=(unsigned short*)malloc(sizeof(naxes[1]*sizeof(unsigned short)));
  
  npixels=naxes[0]*naxes[1];

  /* load the image */
      if ( fits_read_img(fp, TUSHORT, fpixel, npixels, &nullval,
                  arr, &anynull, &status) )
           printerror( status );
  puts("read array into RAM");
  printf("nullval: %hd\n",nullval);
  printf("anynull: %hd\n",anynull);
  for(i=0;i<naxes[1];i++){
    for(j=0;j<naxes[0];j++)
      printf("%hd ",arr[i][j]);
    puts("");
  }
  /* close image file */
  free(arr);
  status=0;
  if(fits_close_file(fp,&status)) printerror(status);
  for(i=0;i<naxes[0];i++)
	free(arr[i]);
  free(arr);
  return 0;
}
