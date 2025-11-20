#include <stdio.h>
#include <string.h>
#include "fitsio.h"
#define MAXSIZE 10000
void printerror(int status);

int main(int argc, char **argv){
  unsigned short int arr[MAXSIZE][MAXSIZE];
  fitsfile *fp;
  int status=0,i,j,anynul,nstart,nkeys,nfound,keynum, bval=0;
  long naxis, naxes[2], bitpix, bzero, firstelem, nelements, group=0,lval=0;
  unsigned short nulval;
  char keyname[32],keyval[128],cmt[128],*strs[10],card[FLEN_CARD];   /* standard string lengths defined in fitsioc.h */
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
       (char*)cmt, &status)) {
		   puts("error in reading keyword BZERO");
		   /*printerror(status);*/
		   status=0;
		   }
  printf("bzero:%ld comment:%s\n",bitpix,cmt);
  strcpy(keyname,"EXPOSURE");
  printf("reading keyword %s\n",keyname);
  if(fits_read_key_lng(fp,keyname,&lval,(char*)&cmt,&status)) {
	  printf("error in reading keyword %s\n",keyname);
	  /*printerror(status);*/
   fits_report_error(stderr,status);
 		   status=0;
	  }
  printf("lval: %ld comment: %s\n",lval,cmt);
  strcpy(keyname,"SIMPLE");
  printf("reading keyword %s\n",keyname);
  if(fits_read_key_log(fp,keyname,&bval,(char*)&cmt,&status)) {
	  printf("error in reading keyword %s\n",keyname);
	  /*printerror(status);*/
   fits_report_error(stderr,status);
 		   status=0;
	  }
  printf("bval: %d comment: %s\n",bval,cmt);
  strcpy(keyname,"EXTEND");
  printf("reading keyword %s\n",keyname);
  if(fits_read_key_log(fp,keyname,&bval,(char*)&cmt,&status)) {
	  printf("error in reading keyword %s\n",keyname);
	  /*printerror(status);*/
   fits_report_error(stderr,status);
 		   status=0;
	  }
  printf("bval: %d comment: %s\n",bval,cmt);
  keynum=7;
  if ( fits_read_record(fp,keynum, (char*)card, &status) ) printerror(status);
  printf("record: %s\n",card);
  keynum=8;
  if ( fits_read_record(fp,keynum, (char*)card, &status) ) printerror(status);
  printf("record: %s\n",card);
  strcpy(keyname,"COMMENT");
  nstart=1;nkeys=2;
  firstelem=1;nelements=naxes[0]*naxes[1];
  nulval=0;
 
  if((bitpix==16)&&(bzero==32768)&&(naxis==2)){
  }
 if(fits_close_file(fp,&status)) printerror(status);
  return 0;
}
