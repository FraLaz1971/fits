#include "fimage.h"
/* allocate and fill a binary table and save it on a FITS file */
int main(int argc, char **argv){
  struct image img;
  if (argc<2){
    fprintf(stderr,"usage:%s <infile.fits>\n",argv[0]);
    return 1;
  }
    strcpy(img.fname,argv[1]);
	img.status=0;
	fprintf(stderr,"main() going to initialize the fits file\n");
	if(init_table(&img))fprintf(stderr,"error in initializing fits file\n");
	fprintf(stderr,"main() image saved on file\n");
	if(set_chdu(1,&img))  fprintf(stderr,"error in setting the hdu\n");
	fprintf(stderr,"main() hdu set\n");
	if(add_table(&img))  fprintf(stderr,"error in adding a table\n");
	fprintf(stderr,"main() binary table addedd\n");
  return 0;
}
