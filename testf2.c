#include <stdio.h>
#include "fitsio.h"
#define MAXSIZE 10000
void printerror(int status);

int main(int argc, char **argv){
  unsigned short int arr[MAXSIZE][MAXSIZE];
  fitsfile *fp;
  int status=0,i,j,anynul;
  long naxis, naxes[2], bitpix, bzero, firstelem, nelements, group=0;
  unsigned short nulval,**arr2;
  char keyname[32],cmt[128];
  long nkeys;
  char *fname=argv[1];
  if(argc<2) {
    fprintf(stderr,"usage:%s <fitsfile>\n",argv[0]);
    return 1;
  }
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
  if(fits_read_key(fp, TLONG, (char*)"BZERO", &bzero,
       (char*)cmt, &status)) printerror(status);
  printf("bzero:%ld comment:%s\n",bitpix,cmt);
  /* define the array dynamically */
  firstelem=1;nelements=naxes[0]*naxes[1];
  nulval=0;
  arr2=(unsigned short **)malloc(naxes[1]*sizeof(unsigned short*));
  for (i=0;i<naxes[1];i++)
     arr2[i]=(unsigned short*)malloc(naxes[0]*sizeof(unsigned short));

  if((bitpix==16)&&(bzero==32768)&&(naxis==2)){
	  printf("&arr[0][0]:%p\n",&arr[0][0]);
	  printf("&arr[0]:%p\n",&arr[0]);
	  printf("arr[0]:%p\n",arr[0]);
	  printf("arr:%p\n",arr);
	  printf("*arr:%p\n",*arr);
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
for (i=0;i<naxes[1];i++)
      free(arr2[i]);
  free(arr2);
  if(fits_close_file(fp,&status)) printerror(status);
  return 0;
}
