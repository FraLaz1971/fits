#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(int argc, char **argv){
  int i,j,res;
  FILE *ofp;
  unsigned int nrows=atoi(argv[1]);
  unsigned int ncols=atoi(argv[2]);
  char *fname = argv[3];
  int **arr;
  if(argc<4){
    fprintf(stderr, "usage:%s <nrows> <ncols> <filename>\n",argv[0]);
    return 1;
  }
 arr = (int**) malloc(nrows*sizeof(int*));
 
  for(i=0; i<nrows; i++)
	arr[i] = (int*) malloc(ncols*sizeof(int));
 
  for(i=0; i<nrows; i++)
    for(j=0; j<ncols; j++)
  /* fill the array*/
	  arr[i][j]=-1*(i*ncols+j+1);
  ofp = fopen(fname, "wb");
  /* write down the array */
  for(i=0;i<nrows; i++){
    for(j=0; j<ncols; j++){
      res = fwrite(&arr[i][j],sizeof(int),1,ofp);
    }
  }
  fclose(ofp);
  for(i=0; i<nrows; i++)
	free(arr[i]); 
  free(arr);
  return 0;
}
