#include "fimage.h"
int allocate_array(int nbits,struct image *img){
  long int i;
  if(nbits==32)
	img->arr=(int *)malloc(img->nrows*img->ncols*sizeof(int));
  else if (nbits==16)
	img->arr16=(short int *)malloc(img->nrows*img->ncols*sizeof(short int));
  else if (nbits==8)
	img->arr8=(char *)malloc(img->nrows*img->ncols*sizeof(char));
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
  if(img->bitpix==32)
    free(img->arr);
  if(img->bitpix==16)
    free(img->arr16);
  if(img->bitpix==8)
    free(img->arr8);
  fprintf(stderr,"fimage::free_array() freed the %d bit array\n",img->bitpix);
  return img->status;
}
int save_bin(struct image *img){
  /* remove the file if exists */
  fprintf(stderr,"fimage::save_bin() going to remove the file if yet existent\n");
  remove(img->fname);
  fprintf(stderr,"fimage::save_bin() file %s removed\n",img->fname);
  /* open fits file for writing */
//  if (fits_create_file(&img->ofp, img->fname, &img->status)) /* create new FITS file */
//         printerror( img->status );           /* call printerror if error occurs */
  img->ofp=fopen(img->fname,"wb");
//  fprintf(stderr,"fimage::save_bin() raw file created\n");
  /* create the image */
//  if ( fits_create_img(img->ofp, img->bitpix, img->naxis, img->naxes, &img->status) )
//         printerror( img->status );
//  fprintf(stderr,"fimage::save_bin() image created\n");
  /* initialize the array*/
	img->status=0;
/*  if(allocate_array(img->bitpix,img)) fprintf(stderr,"error in allocating array memory\n"); 
  fprintf(stderr,"fimage::save_fits() array allocated\n");
*/
  /* write the image */
  fprintf(stderr,"fimage::save_bin() raw file %s opened\n",img->fname);
  fprintf(stderr,"fimage::save_bin() size of the array %ld\n",img->nelements);
  if(img->bitpix==32){
        fprintf(stderr,"fimage::save_bin() going to write a 32 bits int image \n");
        fwrite(img->arr,img->nelements*4,1,img->ofp);
//  if ( fits_write_img(img->ofp, TINT, img->fpixel, img->nelements, img->arr, &img->status) )
//        printerror( img->status );
  } else if (img->bitpix==16) {
  fprintf(stderr,"fimage::save_bin() going to write a 16 bits int image \n");
        fwrite(img->arr16,img->nelements*2,1,img->ofp);
//  if ( fits_write_img(img->ofp, TSHORT, img->fpixel, img->nelements, img->arr16, &img->status) )
//        printerror( img->status );
  } else if (img->bitpix==8){
  fprintf(stderr,"fimage::save_bin() going to write a 8 bits int image \n");
//  if ( fits_write_img(img->ofp, TBYTE, img->fpixel, img->nelements, img->arr8, &img->status) )
//        printerror( img->status );
        fwrite(img->arr8,img->nelements,1,img->ofp);
  } else if (img->bitpix==-32){
  fprintf(stderr,"fimage::save_bin() going to write a 32 bits float image \n");
//  if ( fits_write_img(img->ofp, TFLOAT, img->fpixel, img->nelements, img->arr8, &img->status) )
//        printerror( img->status );
        fwrite(img->arr,img->nelements,1,img->ofp);
  }
  fprintf(stderr,"fimage::save_bin() raw file written\n");
  /* close fits file */
  //if ( fits_close_file(img->ofp, &img->status) ) /* close the file */
         //printerror( img->status );           
         fclose(img->ofp);
  fprintf(stderr,"fimage::save_bin() raw file closed\n");
  return img->status;
}

int save_fits(struct image *img){
  /* remove the file if exists */
  fprintf(stderr,"fimage::save_fits() going to remove the file if yet existent\n");
  remove(img->fname);
  fprintf(stderr,"fimage::save_fits() file %s removed\n",img->fname);
  /* open fits file for writing */
  if (fits_create_file(&img->ofp, img->fname, &img->status)) /* create new FITS file */
         printerror( img->status );           /* call printerror if error occurs */
  fprintf(stderr,"fimage::save_fits() fits file created\n");
  /* create the image */
  if ( fits_create_img(img->ofp, img->bitpix, img->naxis, img->naxes, &img->status) )
         printerror( img->status );
  fprintf(stderr,"fimage::save_fits() image created\n");
  /* initialize the array*/
	img->status=0;
/*  if(allocate_array(img->bitpix,img)) fprintf(stderr,"error in allocating array memory\n"); 
  fprintf(stderr,"fimage::save_fits() array allocated\n");
*/
  /* write the image */
  fprintf(stderr,"fimage::save_fits() fits file opened\n");
  if(img->bitpix==32){
        fprintf(stderr,"fimage::save_fits() going to write a 32 bits image \n");
  if ( fits_write_img(img->ofp, TINT, img->fpixel, img->nelements, img->arr, &img->status) )
        printerror( img->status );
  } else if (img->bitpix==16) {
  fprintf(stderr,"fimage::save_fits() going to write a 16 bits image \n");
  if ( fits_write_img(img->ofp, TSHORT, img->fpixel, img->nelements, img->arr16, &img->status) )
        printerror( img->status );
  } else if (img->bitpix==8){
  fprintf(stderr,"fimage::save_fits() going to write a 8 bits image \n");
  if ( fits_write_img(img->ofp, TBYTE, img->fpixel, img->nelements, img->arr8, &img->status) )
        printerror( img->status );
  }
  fprintf(stderr,"fimage::save_fits() fits file written\n");
  /* close fits file */
  if ( fits_close_file(img->ofp, &img->status) ) /* close the file */
         printerror( img->status );           
  fprintf(stderr,"fimage::save_fits() fits file closed\n");
  return img->status;
}
int init_table(struct image *img){
  fprintf(stderr,"init_table() going to remove the file if yet existent\n");
  remove(img->fname);
  fprintf(stderr,"init_table() file %s removed\n",img->fname);
  /* open fits file for writing */
  if (fits_create_file(&img->ofp, img->fname, &img->status)) /* create new FITS file */
         printerror( img->status );           /* call printerror if error occurs */
  fprintf(stderr,"init_table() fits file created\n");
  return img->status;
}
void set_element(long rownum,long colnum,int val,struct image *img){
	if(img->bitpix==32){
		img->arr[rownum*img->ncols+colnum]=val;
	} else if(img->bitpix==16){
		img->arr16[rownum*img->ncols+colnum]=val;
	} else if (img->bitpix==8){
		img->arr8[rownum*img->ncols+colnum]=val;
    }
}
int get_element(long rownum,long colnum,struct image *img){
	if(img->bitpix==32){
		return img->arr[rownum*img->ncols+colnum];
    } else if(img->bitpix==16){
		return img->arr16[rownum*img->ncols+colnum];
    } else if(img->bitpix==8){
		return img->arr8[rownum*img->ncols+colnum];
	} else
	  return 0;
}
int load_fits(struct image *img){
long int i,j;
  /* open fits file for reading */
  img->status=0;
  fprintf(stderr,"fimage::load_fits() going to open file %s\n",img->ifname);
  if ( fits_open_file(&img->ifp, img->ifname, READONLY, &img->status) )
     printerror( img->status );
  fprintf(stderr,"fimage::load_fits() input fits file opened\n");
  /* load image in memory */
  if(fits_read_key(img->ifp, TLONG, (char*)"NAXIS", &img->naxis,
       (char*)img->cmt, &img->status)) printerror(img->status);
  fprintf(stderr,"naxis:%ld comment:%s\n",img->naxis,img->cmt);
  if(fits_read_key(img->ifp, TLONG, (char*)"NAXIS1", &img->naxes[0],
       (char*)img->cmt, &img->status)) printerror(img->status);
  fprintf(stderr,"naxes[0]:%ld comment:%s\n",img->naxes[0],img->cmt);
  if(fits_read_key(img->ifp, TLONG, (char*)"NAXIS2", &img->naxes[1],
       (char*)img->cmt, &img->status)) printerror(img->status);
  fprintf(stderr,"naxes[1]:%ld comment:%s\n",img->naxes[1],img->cmt);
  if(fits_read_key(img->ifp, TLONG, (char*)"BITPIX", &img->bitpix,
       (char*)img->cmt, &img->status)) printerror(img->status);
  fprintf(stderr,"bitpix:%d comment:%s\n",img->bitpix,img->cmt);
  img->ncols=img->naxes[0];
  img->nrows=img->naxes[1];
  img->nelements=img->naxes[0]*img->naxes[1];
  /* initialize the array*/
  img->status=0;
  if(allocate_array(img->bitpix,img)) fprintf(stderr,"error in allocating array memory\n");
  fprintf(stderr,"fimage::load_fits() array allocated\n");

  if(img->bitpix==32){
                  fprintf(stderr,"fimage::load_fits() reading a 32 bit per pixel image\n");
  if ( fits_read_img(img->ifp, TINT, img->fpixel, img->nelements, &img->nullval,
                  img->arr, &img->anynull, &img->status) ) printerror( img->status );
  } else if (img->bitpix==16){
                  fprintf(stderr,"fimage::load_fits() reading a 16 bit per pixel image\n");
  if ( fits_read_img(img->ifp, TSHORT, img->fpixel, img->nelements, &img->nullval,
                  img->arr16, &img->anynull, &img->status) ) printerror( img->status );
  } else if (img->bitpix==8){
                  fprintf(stderr,"fimage::load_fits() reading a 8 bit per pixel image\n");
  if ( fits_read_img(img->ifp, TBYTE, img->fpixel, img->nelements, &img->nullval,
                  img->arr8, &img->anynull, &img->status) ) printerror( img->status );
  }
  fprintf(stderr,"fimage::load_fits() image loaded in memory\n");
  /* close fits file */
  if ( fits_close_file(img->ifp, &img->status) ) printerror( img->status );
  fprintf(stderr,"fimage::load_fits() input fits file closed\n");
return img->status;
}

int set_chdu(int hdunum,struct image *img){
  img->chdu=hdunum;
  fprintf(stderr,"fimage::set_chdu() current hdu set to %d\n",img->chdu);
  fprintf(stderr,"fimage::set_chdu() going to open fits file %s\n",img->fname);
if (fits_open_file(&img->ofp, img->fname, READWRITE, &img->status) )
   printerror(img->status);
  fprintf(stderr,"fimage::set_chdu() opened fits file %s\n",img->fname);
if ( fits_movabs_hdu(img->ofp, img->chdu, &img->btable.hdutype, &img->status) )
  printerror(img->status);
  fprintf(stderr,"fimage::set_chdu() moved to hdu %d tyoe %d\n",img->chdu,img->btable.hdutype);
  return img->status;
}
int add_table(struct image *img){
    img->btable.tfields = 3;/* table will have 3 columns */
    img->btable.nrows = 6;/* table will have 6 rows    */
    img->btable.firstrow = 1;/* first row in table to write */
    img->btable.firstelem = 1;/* first elwment in row*/
    strcpy(img->btable.extname,"PLANETS_Binary");           /* extension name */

    /* define the name, datatype, and physical units for the 3 columns */
    img->btable.ttype[0] = "Planet";
    img->btable.ttype[1] = "Diameter";
    img->btable.ttype[2] = "Density";
    img->btable.tform[0] = "8a";
    img->btable.tform[1] = "1J";
    img->btable.tform[2] = "1E";
    img->btable.tunit[0] = "\0";
    img->btable.tunit[1] = "km";
    img->btable.tunit[2] = "g/cm^3";
  fprintf(stderr,"fimage::add_table() defined columns metadata\n");

    /* define the name, diameter, and density of each planet */
    img->btable.planet[0] = "Mercury";
    img->btable.planet[1] =  "Venus";
    img->btable.planet[2] = "Earth";
    img->btable.planet[3] = "Mars";
    img->btable.planet[4] = "Jupiter";
    img->btable.planet[5] = "Saturn";
    img->btable.diameter[0] = 4880;
    img->btable.diameter[1] = 12112;
    img->btable.diameter[2] = 12742;
    img->btable.diameter[3] = 6800;
    img->btable.diameter[4] = 143000;
    img->btable.diameter[5] = 121000;
    img->btable.density[0]  = 5.1f;
    img->btable.density[1]  = 5.3f;
    img->btable.density[2]  = 5.52f;
    img->btable.density[3]  = 3.94f;
    img->btable.density[4]  = 1.33f;
    img->btable.density[5]  = 0.69f;
  fprintf(stderr,"fimage::add_table() defined columns content\n");
if ( fits_create_tbl( img->ofp, BINARY_TBL,
img->btable.nrows, img->btable.tfields,
img->btable.ttype, img->btable.tform,
img->btable.tunit, img->btable.extname, &img->status) )
         printerror( img->status );
  fprintf(stderr,"fimage::add_table() created table\n");

    if(fits_write_col(img->ofp, TSTRING, 1, img->btable.firstrow, img->btable.firstelem, img->btable.nrows, img->btable.planet,
                   &img->status)) printerror(img->status);
    fprintf(stderr,"fimage::add_table() written column 1\n");
    if(fits_write_col(img->ofp, TLONG, 2, img->btable.firstrow, img->btable.firstelem, img->btable.nrows, img->btable.diameter,
                   &img->status)) printerror(img->status);
    fprintf(stderr,"fimage::add_table() written column 2\n");
    if(fits_write_col(img->ofp, TFLOAT, 3, img->btable.firstrow, img->btable.firstelem, img->btable.nrows, img->btable.density,
                   &img->status)) printerror(img->status);
    fprintf(stderr,"fimage::add_table() written column 3\n");
    if ( fits_close_file(img->ofp, &img->status) )
         printerror( img->status );
    fprintf(stderr,"fimage::add_table() closed fits file\n");
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
