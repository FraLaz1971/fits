#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"
int debug=1;
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
  unsigned int nrows;
  unsigned int ncols; 
  char *temp;
  char *fname;/* input file name */
  char *ofname;/* output file name */
  if(argc<4){
    fprintf(stderr,"usage:%s <nrows> <ncols> <infile>\n",argv[0]);
    return 1;
  }
  nrows=atoi(argv[1]);
  ncols=atoi(argv[2]); 
  fname=argv[3];/* input file name */
  arr=(int **)malloc(nrows*sizeof(int*));
  for(i=0; i<nrows;i++)
	arr[i]=(int*)malloc(ncols*sizeof(int));
  buffer = (int *) malloc(nrows*ncols*sizeof(int));
  temp = strrchr(fname, '.');
  printf("changekeys: temp=%s\n",temp);
  n=strlen(fname)-strlen(temp);
  ofname=(char *)malloc(n*sizeof(char));
  printf("changekeys: n=%ld\n",n);
  ofname=strncpy(ofname, fname, n);
  ofname[n]='\0';
  ofname=strcat(ofname,"_new.fits");
  printf("changekeys: ofname=%s\n",ofname);
  printf("changekeys: going to open the file %s\n", fname);
  status=0;
  if (fits_open_image(&ifp, fname, READONLY, &status))
      printerror(status);
  puts("changekeys: file yet open");
/*    read the NAXIS1 and NAXIS2 keyword to get image size */
/*
int fits_read_keys_[log, lng, flt, dbl] / ffgkn[ljed]
(fitsfile *fptr, char *keyname, int nstart, int nkeys,
> DTYPE *numval, int *nfound, int *status)
*/
    puts("changekeys:going to read file keywords");
    status=0;
    if ( fits_read_keys_lng(ifp, "NAXIS", 1, 2, naxes, &nfound, &status) )
         printerror( status );
    puts("changekeys:keywords read");
	naxes[0] = ncols; naxes[1] = nrows;
    npixels  = naxes[0] * naxes[1];         /* number of pixels in the image */
    printf("changekeys:naxis = %ld\n",naxis);
    printf("changekeys:naxes[0] = %ld\n",naxes[0]);
    printf("changekeys:naxes[1] = %ld\n",naxes[1]);
    printf("changekeys:npixels = %ld\n",npixels);
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
#ifdef DEBUG
  if (debug) {
  puts("changekeys: printing the 1d array buffer");
  for(i=0; i<nrows;i++){
	  for(j=0; j<ncols;j++){
	    printf("%d ",buffer[i*ncols+j]);
  }
  }
}
  fpixel=1;
                  /* buffer will contain the read array*/
    if (debug) {
  puts("\nchangekeys: going to read the whole array");
  for(i=0; i<nrows;i++){
	  for(j=0; j<ncols;j++){
		  printf("%d ",buffer[i*ncols+j]);
      }
      puts("");
  }
 } 
#endif
  printf("changekeys: going to close the input file %s\n", fname);
  if(fits_close_file(ifp, &status))
	printerror(status);
  puts("changekeys: input file yet closed");
  printf("changekeys: going to open the output file %s\n", ofname);
  /* 
   * int fits_open_file / ffopen
(fitsfile **fptr, char *filename, int iomode, > int *status)
*/
   /* delete the file if it exist yet */
   remove(ofname);
   if(fits_create_file(&ofp,ofname,&status))
		printerror(status);
  puts("changekeys: output file yet opened");
  printf("changekeys: going to create the image in %s\n", ofname);
  if(fits_create_img(ofp, LONG_IMG, naxis, naxes, &status))
  printerror(status);
  puts("changekeys: image yet created");
  fpixel=1;
  printf("changekeys: going to write the image in %s\n", ofname);
  if(fits_write_img(ofp, TINT, fpixel, npixels, buffer, &status))
		printerror(status);
  puts("changekeys: image yet written");
  
  printf("changekeys: going to close the output file %s\n", ofname);
  if(fits_close_file(ofp, &status)) printerror(status);
  puts("changekeys: input file yet closed");
  for(i=0; i<nrows;i++)
		free(arr[i]);
  free(arr);

  return 0;
}

