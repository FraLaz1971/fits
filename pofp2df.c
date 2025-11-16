#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"
struct image{
  int *arr; /* the array */
  long nrows;
  long ncols;
  long count;
  long fpixel; /* first pixel in the array */
  long nelements; /* n. of elements of the array */
  int nullval;
  int anynull;
  int status;
  fitsfile *ifp;
  fitsfile *ofp;
  int bitpix; /* n. of bits for each pixel */
  long naxis; /*n. of axis(dimensions) */
  long naxes[2]; /*dimension of each axis */
  char fname[40]; /* name of the output file */
  char ifname[40]; /* name of the input file */
  char cmt[80];
};
int allocate_array(struct image *img);
int fill_array(struct image *img);
int print_array(struct image *img);
int free_array(struct image *img);
int save_fits(struct image *img);
int load_fits(struct image *img);
void set_element(long rownum,long colnum,int val,struct image *img);
int get_element(long rownum,long colnum,struct image *img);
void printerror( int status);
/* create a 2D array using pointers of pointers and save it on a FITS file */
int main(int argc, char **argv){
  struct image img;
  if (argc<4){
    fprintf(stderr,"usage:%s <nrows> <ncols> <outfile.fits>\n",argv[0]);
    return 1;
  }
  img.count=0;
  img.nrows=atol(argv[1]);img.ncols=atol(argv[2]);
  strcpy(img.fname,argv[3]);
  img.naxis=2;
  img.bitpix=LONG_IMG;
  img.naxes[0]=img.ncols;
  img.naxes[1]=img.nrows;
  img.nelements=img.naxes[0]*img.naxes[1];
  img.fpixel=1;
/* initialize the array*/
img.status=0;
if(allocate_array(&img)) fprintf(stderr,"error in allocating array memory\n");
puts("main() array allocated");
/* fill the array */
if(fill_array(&img)) fprintf(stderr,"error in filling the array\n");
puts("main() array filled");
/* print the array*/
if(print_array(&img)) fprintf(stderr,"error in filling the array\n");
puts("main() array printed");
/* save image on fits file */
if(save_fits(&img))fprintf(stderr,"error in saving fits file\n");
puts("main() image saved on file");
/* free the 2D array */
if(free_array(&img))  fprintf(stderr,"error in freeing array memory\n");
puts("main() array freed");
  strcpy(img.ifname,argv[3]);
if(load_fits(&img)) fprintf(stderr,"error in loading fits file\n");
puts("main() fits image loaded");
/* print the array*/
if(print_array(&img)) fprintf(stderr,"error in filling the array\n");
puts("main() read array printed");
  return 0;
}
int allocate_array(struct image *img){
  long int i;
  img->arr=(int *)malloc(img->nrows*img->ncols*sizeof(int));
  return img->status;
}
int fill_array(struct image *img){
long int i,j;
  for(i=0;i<img->nrows;i++)
    for(j=0;j<img->ncols;j++)
       set_element(i,j,++img->count,img);
  return img->status;
}
int print_array(struct image *img){
long int i,j;
  for(i=0;i<img->nrows;i++){
    for(j=0;j<img->ncols;j++)
       printf("%d ",get_element(i,j,img));
    puts("");
  }
  return img->status;
}
int free_array(struct image *img){
  long int i;
  free(img->arr);
  printf("free_array() freed the array");
  return img->status;
}
int save_fits(struct image *img){
  /* remove the file if exists */
  remove(img->fname);
  /* open fits file for writing */
  if (fits_create_file(&img->ofp, img->fname, &img->status)) /* create new FITS file */
         printerror( img->status );           /* call printerror if error occurs */
  puts("save_fits() fits file opened");
  /* create the image */
  if ( fits_create_img(img->ofp, img->bitpix, img->naxis, img->naxes, &img->status) )
         printerror( img->status );          
  puts("save_fits() image created");
  /* write the image */
  puts("save_fits() fits file opened");
  if ( fits_write_img(img->ofp, TINT, img->fpixel, img->nelements, img->arr, &img->status) )
        printerror( img->status );
  puts("save_fits() fits file written");
  /* close fits file */
  if ( fits_close_file(img->ofp, &img->status) ) /* close the file */
         printerror( img->status );           
  puts("save_fits() fits file closed");
  return img->status;
}
void set_element(long rownum,long colnum,int val,struct image *img){
	img->arr[rownum*img->ncols+colnum]=val;
}
int get_element(long rownum,long colnum,struct image *img){
    return img->arr[rownum*img->ncols+colnum];
}
int load_fits(struct image *img){
long int i,j;
  /* open fits file for reading */
  img->status=0;
  if ( fits_open_file(&img->ifp, img->ifname, READONLY, &img->status) )
     printerror( img->status );
  puts("load_fits() input fits file opened");
  /* load image in memory */
  if(fits_read_key(img->ifp, TLONG, (char*)"NAXIS", &img->naxis,
       (char*)img->cmt, &img->status)) printerror(img->status);
  printf("naxis:%ld comment:%s\n",img->naxis,img->cmt);
  if(fits_read_key(img->ifp, TLONG, (char*)"NAXIS1", &img->naxes[0],
       (char*)img->cmt, &img->status)) printerror(img->status);
  printf("naxes[0]:%ld comment:%s\n",img->naxes[0],img->cmt);
  if(fits_read_key(img->ifp, TLONG, (char*)"NAXIS2", &img->naxes[1],
       (char*)img->cmt, &img->status)) printerror(img->status);
  printf("naxes[1]:%ld comment:%s\n",img->naxes[1],img->cmt);
  if(fits_read_key(img->ifp, TLONG, (char*)"BITPIX", &img->bitpix,
       (char*)img->cmt, &img->status)) printerror(img->status);
  printf("bitpix:%d comment:%s\n",img->bitpix,img->cmt);
  if ( fits_read_img(img->ifp, TINT, img->fpixel, img->nelements, &img->nullval,
                  img->arr, &img->anynull, &img->status) ) printerror( img->status );
  puts("load_fits() image loaded in memory");
  /* close fits file */
  if ( fits_close_file(img->ifp, &img->status) ) printerror( img->status );
  puts("load_fits() input fits file closed");
return img->status;
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
