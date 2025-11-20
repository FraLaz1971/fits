#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"
#define MAXCOLS 10000
int debug=0;
void printerror( int status);

int main(int argc, char **argv){
  int intnull=0;
  int anynull=0;
  int status,  nfound, nullval;
  int *buffer;
  int **arr;
  long naxes[2], naxis=2,fpixel, nbuffer, npixels, ii;
  float datamin, datamax;
  size_t n;
  int val=0;
  fitsfile *ifp,*ofp;
  int i, j, res;
  unsigned int nrows=atoi(argv[1]);
  unsigned int ncols=atoi(argv[2]); 
  char *temp;
  char *fname=argv[3];/* input file name */
  char *ofname;/* output file name */
  if(argc<4){
    fprintf(stderr,"usage:%s <nrows> <ncols> <infile>\n",argv[0]);
    return 1;
  }
  arr=(int **)malloc(nrows*sizeof(int*));
  for(i=0; i<nrows;i++)
	arr[i]=(int*)malloc(ncols*sizeof(int));
  buffer = (int *) malloc(nrows*ncols*sizeof(int));
  temp = strrchr(fname, '.');
  printf("temp=%s\n",temp);
  n=strlen(fname)-strlen(temp);
  ofname=(char *)malloc(n*sizeof(char));
  printf("n=%ld\n",n);
  ofname=strncpy(ofname, fname, n);
  ofname[n]='\0';
  ofname=strcat(ofname,"_new.fits");
  printf("ofname=%s\n",ofname);
  printf("readwriterawf: going to open the file %s\n", fname);
  if (fits_open_image(&ifp, fname, READONLY, &status))
      printerror(status);
  puts("readwriterawf: file yet open");
/*    read the NAXIS1 and NAXIS2 keyword to get image size */
/*
int fits_read_keys_[log, lng, flt, dbl] / ffgkn[ljed]
(fitsfile *fptr, char *keyname, int nstart, int nkeys,
> DTYPE *numval, int *nfound, int *status)
*/
    puts("readwriterawf:going to read file keywords");
    if ( fits_read_keys_lng(ifp, "NAXIS", 1, 2, naxes, &nfound, &status) )
         printerror( status );
    puts("readwriterawf:keywords read");
	naxes[0] = nrows; naxes[1] = ncols;
    npixels  = naxes[0] * naxes[1];         /* number of pixels in the image */
    printf("readwriterawf:naxis = %ld\n",naxis);
    printf("readwriterawf:naxes[0] = %ld\n",naxes[0]);
    printf("readwriterawf:naxes[1] = %ld\n",naxes[1]);
    printf("readwriterawf:npixels = %ld\n",npixels);
    fpixel   = 1;
    nullval  = 0;                /* don't check for null values in the image */
    datamin  = 1.0E30f;
    datamax  = -1.0E30f;

/*
res=fread(&arr[i][j],4,1,ifp);
int fits_read_col(fitsfile *fptr, int datatype, int colnum, long firstrow, long firstelem, long nelements, void *nulval, void *array,
int *anynul, int *status)


    /* read the NAXIS1 and NAXIS2 keyword to get image size */
/*    if ( fits_read_keys_lng(fptr, "NAXIS", 1, 2, naxes, &nfound, &status) )
         printerror( status );


      nbuffer = npixels;
      if (npixels > buffsize)
        nbuffer = buffsize;    /* read as many pixels as will fit in buffer */

      /* Note that even though the FITS images contains unsigned integer */
      /* pixel values (or more accurately, signed integer pixels with    */
      /* a bias of 32768),  this routine is reading the values into a    */
      /* float array.   Cfitsio automatically performs the datatype      */
      /* conversion in cases like this.                                  
int fits_read_img / ffgpv
(fitsfile *fptr, int datatype, long firstelem, long nelements,
DTYPE *nulval, > DTYPE *array, int *anynul, int *status)
       * */
  for(i=0; i<nrows;i++){
	  for(j=0; j<ncols;j++){
				  fpixel=i*ncols+j+1;
                  if (debug) printf("fpixel=%ld ",fpixel);
      if ( fits_read_img(ifp, TINT, fpixel, (long)1, &nullval, &val, &anynull, &status) )
                  printerror(status);
                  if (debug) printf("%d ",val);
                  buffer[i*ncols+j]=val;
      }
      if (debug) puts("");
  }
  if (debug) {
  puts("readwriterawf: printing the 1d array buffer");
  for(i=0; i<nrows;i++){
	  for(j=0; j<ncols;j++){
	    printf("%d ",buffer[i*ncols+j]);
  }
  }
}
  fpixel=1;
                  /* buffer will contain the read array*/
    if (debug) {
  puts("\nreadwriterawf: going to read the whole array");
  for(i=0; i<nrows;i++){
	  for(j=0; j<ncols;j++){
		  printf("%d ",buffer[i*ncols+j]);
      }
      puts("");
  }
 } 
  printf("readwriterawf: going to close the input file %s\n", fname);
  if(fits_close_file(ifp, &status))
	printerror(status);
  puts("readwriterawf: input file yet closed");
  printf("readwriterawf: going to open the input file %s\n", ofname);
  /* 
   * int fits_open_file / ffopen
(fitsfile **fptr, char *filename, int iomode, > int *status)
*/
   /* delete the file if it exist yet */
   remove(ofname);
   if(fits_create_file(&ofp,ofname,&status))
		printerror(status);
  puts("readwriterawf: output file yet opened");
  printf("readwriterawf: going to create the image %s\n", ofname);
  if(fits_create_img(ofp, LONG_IMG, naxis, naxes, &status))
  printerror(status);
  puts("readwriterawf: image yet created");
  fpixel=1;
  printf("readwriterawf: going to write the image %s\n", ofname);
  if(fits_write_img(ofp, TINT, fpixel, npixels, buffer, &status))
		printerror(status);
  puts("readwriterawf: image yet written");
  
  printf("readwriterawf: going to close the output file %s\n", ofname);
  if(fits_close_file(ofp, &status)) printerror(status);
  puts("readwriterawf: input file yet closed");
  for(i=0; i<nrows;i++)
		free(arr[i]);
  free(arr);

  return 0;
}

/*
    for(j=0;j<ncols;j++){
  for(i=0;i<nrows;i++){
	if (fits_read_col(ifp, TINT, j,(long)i,(long)1,(long)1,&intnull,&val,&anynull,&status) )
//	arr[i][j]=val;
        printf("%3d ",val);
    }
  }
 */

