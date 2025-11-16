#include <stdio.h>
#include "fitsio.h"
void printerror(int status);

int main(int argc, char **argv){
  fitsfile *fp;
  int status=0,i,j,anynul;
  long naxis, naxes[2], bitpix, bzero, firstelem, nelements, group=0;
  unsigned short nulval,**arr2;
  char keyname[32],cmt[128];
  long nkeys;
  if(argc<2) {
    fprintf(stderr,"usage:%s <fitsfile>\n",argv[0]);
    return 1;
  }
  char *fname=argv[1];
  if(fits_open_file(&fp,fname,READONLY,&status)) 
     printerror(status);
/*
int fits_read_key / ffgky (fitsfile *fptr,
int datatype, char *keyname, > DTYPE *value,
       char *comment, int *status)
*/
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
  if(fits_read_key(fp, TLONG, (char*)"BZERO", &bzero,
       (char*)cmt, &status)) printerror(status);
  printf("bzero:%ld comment:%s\n",bitpix,cmt);
  /* define the array dynamically */
  firstelem=1;nelements=naxes[0]*naxes[1];
  nulval=0;
  unsigned short int arr[naxes[1]][naxes[0]];
  arr2=(unsigned short **)malloc(naxes[1]*sizeof(unsigned short*));
  for (i=0;i<naxes[1];i++)
     arr2[i]=(unsigned short*)malloc(naxes[0]*sizeof(unsigned short));

  if((bitpix==16)&&(bzero==32768)&&(naxis==2)){
/*	   unsigned short arr[naxes[1]][naxes[0]]; */

/*		int fits_read_img / ffgpv
(fitsfile *fptr, int datatype, long firstelem, long nelements,
DTYPE *nulval, > DTYPE *array, int *anynul, int *status)
* 
* int fits_read_img_[byt, sht, usht, int, uint, lng, ulng, lnglng, flt, dbl] /
ffgpv[b,i,ui,k,uk,j,uj,jj,e,d]
(fitsfile *fptr, long group, long firstelem, long nelements,
DTYPE nulval, > DTYPE *array, int *anynul, int *status)
*/
	  printf("&arr[0][0]:%p\n",&arr[0][0]);
	  printf("&arr[0]:%p\n",&arr[0]);
	  printf("arr[0]:%p\n",arr[0]);
	  printf("arr:%p\n",arr);
	  printf("*arr:%p\n",*arr);
/*	  arr=(unsigned short**)malloc(naxes[1]*sizeof(unsigned short*));
	  for(i=0;i<naxes[1];i++)
		arr[i]=(unsigned short*)malloc(naxes[0]*sizeof(unsigned short));
*/
/*	  if(fits_read_img(fp,TUSHORT,firstelem,nelements,&nulval,arr[0],&anynul,&status) ) printerror(status);*/
/*      if(fits_read_img_usht(fp,group,firstelem,nelements,nulval,(short unsigned*)*arr,&anynul,&status)) printerror(status);
	  for(i=0;i<naxes[1];i++);
		free(arr[i]);*/
      if(fits_read_img_usht(fp,group,firstelem,nelements,nulval,(short unsigned*)*arr,&anynul,&status)) printerror(status);
	  for(i=0;i<naxes[1];i++){
		  for(j=0;j<naxes[0];j++){
		    arr2[i][j]=arr[i][j];
			printf("arr[%d][%d]=%hd ",i,j,arr[i][j]);
		  }
		  puts("");
	  }

	  for(i=0;i<naxes[1];i++){
		  for(j=0;j<naxes[0];j++){
			printf("arr2[%d][%d]=%hd ",i,j,arr2[i][j]);
		  }
		  puts("");
	  }

  }
/*	  for(i=0;i<naxes[1];i++)
        free(arr[i]);
      free(arr);
  for (i=0;i<naxes[1];i++)
      free(arr2[i]);
*/
for (i=0;i<naxes[1];i++)
      free(arr2[i]);
  free(arr2);
  if(fits_close_file(fp,&status)) printerror(status);
  return 0;
}
void printerror(int status){
  if(status){
    fits_report_error(stderr,status);
    exit(0);
  }
  return;
}
