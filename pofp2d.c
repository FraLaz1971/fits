#include <stdio.h>
#include <stdlib.h>
int main(int argc, char **argv){
  int **arr, i,j,count=0;
  long nrows,ncols;
  if (argc<3){
    fprintf(stderr,"usage:%s <nrows> <ncols>\n",argv[0]);
    return 1;
  }
  nrows=atol(argv[1]);ncols=atol(argv[2]);
  arr=(int **)malloc(nrows*sizeof(int*));
  for(i=0;i<nrows;i++)
	arr[i]=(int *)malloc(ncols*sizeof(int));
/* fill the array */
  for(i=0;i<nrows;i++)
    for(j=0;j<ncols;j++)
       arr[i][j]=++count;
/* print the array*/
  for(i=0;i<nrows;i++){
    for(j=0;j<ncols;j++)
       printf("%d ",arr[i][j]);
    puts("");
  }
/* free the 2D array */
  for(i=0;i<nrows;i++)
  	free(arr[i]);
  free(arr);
  return 0;
}
