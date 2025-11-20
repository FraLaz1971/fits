#include <stdio.h>
#include "fitsio.h"
void printerror(int status);

int main(int argc, char **argv){
  fitsfile *fp;
  int status=0,i,j,anynul;
  long naxis, naxes[2], bitpix, bzero, firstelem, nelements, group;
  unsigned int nulval;
  char keyname[32],cmt[128];
  long nkeys;
  char *fname;
  unsigned int *arr;
  if(argc<2) {
    fprintf(stderr,"usage:%s <fitsfile>\n",argv[0]);
    return 1;
  }
  fname=argv[1];
  if(fits_open_file(&fp,fname,READONLY,&status)) 
     printerror(status);
  if(fits_read_key(fp, TLONG, (char*)"NAXIS", &naxis,
       (char*)cmt, &status)) printerror(status);
  printf("naxis:%ld comment:%s\n",naxis,cmt);
  if(fits_read_key(fp, TLONG, (char*)"NAXIS1", &naxes[0],
       (char*)cmt, &status)) printerror(status);
  printf("naxes[0]:%ld comment:%s\n",naxes[0],cmt);
  if(fits_read_key(fp, TLONG, (char*)"NAXIS2", &naxes[1],
       (char*)cmt, &status)) printerror(status);
  printf("naxes[1]:%ld comment:%s\n",naxes[1],cmt);
  if(fits_read_key(fp, TLONG, (char*)"BITPIX", &bitpix,
       (char*)cmt, &status)) printerror(status);
  printf("bitpix:%ld comment:%s\n",bitpix,cmt);
/*  if(fits_read_key(fp, TLONG, (char*)"BZERO", &bzero,
       (char*)cmt, &status)) printerror(status);
  printf("bzero:%ld comment:%s\n",bzero,cmt); */
  /* define the array dynamically */
  firstelem=1;nelements=naxes[0]*naxes[1];
  nulval=0;
//  if((bitpix==16)&&(bzero==32768)&&(naxis==2)){
	  arr=(unsigned int *)malloc(naxes[0]*naxes[1]*sizeof(unsigned int));
	  printf("&arr[0]:%p\n",&arr[0]);
	  printf("arr[0]:%p\n",arr[0]);
	  printf("arr:%p\n",arr);
/* Read the image data */
	  if(fits_read_img(fp, TUINT, firstelem, nelements, NULL, arr, &anynul, &status)) printerror(status);


	  for(i=1;i<=naxes[1];i++){
		  for(j=0;j<naxes[0];j++)
			printf("arr[%d][%d]=%hd ",i-1,j,arr[(i-1)*naxes[0]+j]);
		  puts("");
	  }
  free(arr);
  if(fits_close_file(fp,&status)) printerror(status);
  return 0;
}
/*--------------------------------------------------------------------------*/
//void printerror( int status)
//{
    ///*****************************************************/
    ///* Print out cfitsio error messages and exit program */
    ///*****************************************************/


    //if (status)
    //{
       //fits_report_error(stderr, status); /* print error report */

       //exit( status );    /* terminate the program, returning error status */
    //}
    //return;
//}
