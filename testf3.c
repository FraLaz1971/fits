#include <stdio.h>
#include <string.h>
#include "fitsio.h"
void printerror(int status);

int main(int argc, char **argv){
  fitsfile *fp;
  int status=0,i,j,anynul,nstart,nkeys,nfound,keynum, bval=0;
  long naxis, naxes[2], bitpix, bzero, firstelem, nelements, group=0,lval=0;
  unsigned short nulval;
  char keyname[32],keyval[128],cmt[128],*strs[10],card[FLEN_CARD];   /* standard string lengths defined in fitsioc.h */
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
       (char*)cmt, &status)) {
		   puts("error in reading keyword BZERO");
		   /*printerror(status);*/
		   status=0;
		   }
  printf("bzero:%ld comment:%s\n",bitpix,cmt);
/*  int fits_read_keys_str / ffgkns
(fitsfile *fptr, char *keyname, int nstart, int nkeys,
> char **value, int *nfound, int *status)

* int fits_read_keys_[log, lng, flt, dbl] / ffgkn[ljed]
(fitsfile *fptr, char *keyname, int nstart, int nkeys,
> DTYPE *numval, int *nfound, int *status)
* 
* int fits_read_key_[log, lng, flt, dbl, cmp, dblcmp] / ffgky[ljedcm]
(fitsfile *fptr, char *keyname, > DTYPE *numval, char *comment,
int *status)
* */
  strcpy(keyname,"EXPOSURE");
  printf("reading keyword %s\n",keyname);
  if(fits_read_key_lng(fp,keyname,&lval,(char*)&cmt,&status)) {
	  printf("error in reading keyword %s\n",keyname);
	  /*printerror(status);*/
   fits_report_error(stderr,status);
 		   status=0;
	  }
  printf("lval: %ld comment: %s\n",lval,cmt);
/*  if(nfound>0){
  for(i=0;i<nfound;i++)
     printf("strs[%d]: %s\n",i,strs[i]);
 }*/
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
  /* 
   int fits_read_record / ffgrec
(fitsfile *fptr, int keynum, > char *card, int *status)
   */
  keynum=7;
  if ( fits_read_record(fp,keynum, (char*)card, &status) ) printerror(status);
  printf("record: %s\n",card);
  keynum=8;
  if ( fits_read_record(fp,keynum, (char*)card, &status) ) printerror(status);
  printf("record: %s\n",card);
  strcpy(keyname,"COMMENT");
  nstart=1;nkeys=2;
/*  int fits_read_key_str / ffgkys
    (fitsfile *fptr, char *keyname, > char *value, char *comment, int *status);*/
/*  if ( fits_read_key_str(fp, keyname, (char*)keyval, (char*)&cmt, &status) )
         printerror( status );
  printf("keyval: %s comment: %s\n",keyval,cmt);*/
  firstelem=1;nelements=naxes[0]*naxes[1];
  nulval=0;
  unsigned short int arr[naxes[1]][naxes[0]];
 
  if((bitpix==16)&&(bzero==32768)&&(naxis==2)){
/*
* int fits_read_img_[byt, sht, usht, int, uint, lng, ulng, lnglng, flt, dbl] /
ffgpv[b,i,ui,k,uk,j,uj,jj,e,d]
(fitsfile *fptr, long group, long firstelem, long nelements,
DTYPE nulval, > DTYPE *array, int *anynul, int *status)

	  printf("&arr[0][0]:%p\n",&arr[0][0]);
	  printf("&arr[0]:%p\n",&arr[0]);
	  printf("arr[0]:%p\n",arr[0]);
	  printf("arr:%p\n",arr);
	  printf("*arr:%p\n",*arr);
	  /*
      if(fits_read_img_usht(fp,group,firstelem,nelements,nulval,(short unsigned*)*arr,&anynul,&status)) printerror(status);
	  for(i=0;i<naxes[1];i++){
		  for(j=0;j<naxes[0];j++){
			printf("arr[%d][%d]=%hd ",i,j,arr[i][j]);
		  }
		  puts("");
	  }
	  */
  }
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
