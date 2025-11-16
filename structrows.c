#include <stdio.h>
#include <string.h>
#include <stdlib.h>
  struct trow{
    char   str[8];
    long   inum;
    double rnum;
};
void set_table_data(struct trow *row);
int main(){
  int i,j;
  long nrows=6;
  long tfields=3;
  struct trow* row = (struct trow*)malloc(nrows * tfields * sizeof(struct trow));
  
  set_table_data(row);
  
    for(j=0; j<nrows; j++){
		printf("%s %ld %lf \n", row[j].str,row[j].inum,row[j].rnum);
  }
    
    free(row);  
  return 0;
}

void set_table_data(struct trow *row){
  /* */
  fprintf(stderr,"set_data() going to set the strings\n");
  strcpy(row[0].str,"Mercury");
  strcpy(row[1].str,"Venus");
  strcpy(row[2].str,"Earth");
  strcpy(row[3].str,"Mars");
  strcpy(row[4].str,"Jupiter");
  strcpy(row[5].str,"Saturn");
  fprintf(stderr,"set_data() strings rowumn set\n");
  /* */
  fprintf(stderr,"set_data() going to set the integers\n");
  row[0].inum=4880;
  row[1].inum=12112;
  row[2].inum=12742;
  row[3].inum=6800;
  row[4].inum=143000;
  row[5].inum=121000;
  fprintf(stderr,"set_data() integers rowumn set\n");
  /* */
  fprintf(stderr,"set_data() going to set the reals\n");
  row[0].rnum=5.1;
  row[1].rnum=5.3;
  row[2].rnum=5.52;
  row[3].rnum=3.94;
  row[4].rnum=1.33;
  row[5].rnum=0.69;
  fprintf(stderr,"set_data() reals rowumn set\n");
}
