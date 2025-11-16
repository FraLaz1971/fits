#include "fimage.h"
/* read an image from a FITS file */
int main(int argc, char **argv){
  struct image img;
  if (argc<2){
    fprintf(stderr,"usage:%s <infile.fits>\n",argv[0]);
    return 1;
  }
  img.count=0;
  strcpy(img.ifname,argv[1]);
  fprintf(stderr,"argv[1]: %s ifname: %s\n", argv[1],img.ifname);
  img.fpixel=1;
/* read fits file content in the array */
img.status=0;
if(load_fits(&img)) fprintf(stderr,"error in loading fits file\n");
fprintf(stderr,"main() fits image loaded\n");
/* print the array*/
img.status=0;
if(print_array(&img)) fprintf(stderr,"error in printing the array\n");
fprintf(stderr,"main() read array printed\n");
  return 0;
}
