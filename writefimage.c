#include "fimage.h"
/* allocate and fill a 2D array and save it on a FITS file */
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
  img.bitpix=32;
/* allocate the array */
if(allocate_array(img.bitpix,&img)) fprintf(stderr,"error allocating the array\n");
fprintf(stderr,"main() array allocated\n");

/* fill the array */
img.status=0;
if(fill_array(&img)) fprintf(stderr,"error in filling the array\n");
fprintf(stderr,"main() array filled\n");
/* print the array*/
if(print_array(&img)) fprintf(stderr,"error in filling the array\n");
fprintf(stderr,"main() array printed\n");
/* save image on fits file */
if(save_fits(&img))fprintf(stderr,"error in saving fits file\n");
fprintf(stderr,"main() image saved on file\n");
/* free the 2D array */
if(free_array(&img))  fprintf(stderr,"error in freeing array memory\n");
fprintf(stderr,"main() array freed\n");
  return 0;
}
