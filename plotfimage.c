#include<string.h>
#include "fimage.h"
/* read an image from a FITS file */
int main(int argc, char **argv){
  struct image img;
  strcpy(img.fname,"myimage.raw");
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
/* plot the image */
img.status=0;
if(plot_image(&img)) fprintf(stderr,"error in plotting the image\n");
fprintf(stderr,"main() read array plotted\n");
  return 0;
}
