#include <stdio.h>
int main(){
  char b;
  unsigned char ub;
  short int si;
  unsigned short usi;
  int i;
  unsigned int ui;
  long int li;
  unsigned long int uli;
  long long int lli;
  unsigned long long ulli;
  float f;
  double d;
  long double ld;
  printf("sizeof b: %ld bytes\n",sizeof(b));
  printf("sizeof ub: %ld bytes\n",sizeof(ub));
  printf("sizeof si: %ld bytes\n",sizeof(si));
  printf("sizeof usi: %ld bytes\n",sizeof(usi));
  printf("sizeof i: %ld bytes\n",sizeof(i));
  printf("sizeof ui: %ld bytes\n",sizeof(ui));
  printf("sizeof ii: %ld bytes\n",sizeof(li));
  printf("sizeof uii: %ld bytes\n",sizeof(uli));
  printf("sizeof lli: %ld bytes\n",sizeof(lli));
  printf("sizeof ulli: %ld bytes\n",sizeof(ulli));
  printf("sizeof f: %ld bytes\n",sizeof(f));
  printf("sizeof d: %ld bytes\n",sizeof(d));
  printf("sizeof ld: %ld bytes\n",sizeof(ld));
  return 0;
}
