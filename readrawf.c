#include <stdio.h>
#include <stdlib.h>
#include "fitsio.h"
#define buffsize 6000

void printerror( int status);

int main(int argc, char **argv){
  int intnull=0;
  int anynull=0;
  int status,  nfound, nullval;
  int buffer[buffsize];
  long naxes[2], fpixel, nbuffer, npixels, ii;
  float datamin, datamax;
  int val=0;
  fitsfile *ifp;
  int i, j, res;
  int **arr;
  unsigned int nrows=atoi(argv[1]);
  unsigned int ncols=atoi(argv[2]);
  char *fname=argv[3];
  if(argc<4){
    fprintf(stderr,"usage:%s <nrows> <ncols> <infile>\n",argv[0]);
    return 1;
  }
  arr=(int**)malloc(nrows*sizeof(int*));
  for(i=0; i<nrows;i++)
	arr[i]=(int*)malloc(ncols*sizeof(int));
  
  printf("readrawf: going to open the file %s\n", fname);
  if (fits_open_image(&ifp, fname, READONLY, &status))
      printerror(status);
  puts("readrawf: file yet open");
/*    read the NAXIS1 and NAXIS2 keyword to get image size */
/*
int fits_read_keys_[log, lng, flt, dbl] / ffgkn[ljed]
(fitsfile *fptr, char *keyname, int nstart, int nkeys,
> DTYPE *numval, int *nfound, int *status)
*/
    puts("readrawf:going to read file keywords");
    if ( fits_read_keys_lng(ifp, "NAXIS", 1, 2, naxes, &nfound, &status) )
         printerror( status );
    puts("readrawf:keywords read");
	naxes[0] = nrows; naxes[1] = ncols;
    npixels  = naxes[0] * naxes[1];         /* number of pixels in the image */
    printf("readrawf:naxes[0] = %ld\n",naxes[0]);
    printf("readrawf:naxes[1] = %ld\n",naxes[1]);
    printf("readrawf:npixels = %ld\n",npixels);
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
                  printf("fpixel=%ld ",fpixel);
      if ( fits_read_img(ifp, TINT, fpixel, (long)1, &nullval, &val, &anynull, &status) )
                  printerror(status);
                  printf("%d ",val);
                  buffer[i*ncols+j]=val;
      }
      puts("");
  }
  puts("readrawf: printing the 1d array buffer");
  for(i=0; i<nrows;i++){
	  for(j=0; j<ncols;j++){
	    printf("%d ",buffer[i*ncols+j]);
  }
  }
  
                  /* buffer will contain the read array*/
           printerror( status );
  puts("\nreadrawf: going to read the whole array");
  fpixel=1;
  for(i=0; i<nrows;i++){
	  for(j=0; j<ncols;j++){
//		  printf("buffer[%d][%d]=%d ",i,j,buffer[i*ncols+j]);
		  printf("%d ",buffer[i*ncols+j]);
//		  printf("%d ",i*ncols+j);
      }
      puts("");
  }
  
  printf("readrawf: going to close the file %s\n", fname);
  if(fits_close_file(ifp, &status))
	printerror(status);
  puts("readrawf: file yet closed");
  return 0;
}

