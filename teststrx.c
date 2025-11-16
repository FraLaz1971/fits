#include <stdio.h>
#include <string.h>
#include <stdlib.h>
size_t mstrxfrm (char *dst, const char *org, size_t n);
int main(){
  char *dest;
  char *src="The weather is good";
  size_t n = 10;
  dest=(char *)malloc(n*sizeof(char));
  n=strxfrm(dest,src,n);
  printf("dest: %s\n", dest);
  return 0;
}
size_t mstrxfrm (char *dst, const char *org, size_t n)
{
  size_t i;
  if (n == 0 && dst == NULL)
    {
      return strlen (org);
    }
  else
    {
      for (i = 0; i < n ; i++)
        {
          printf("%c %c\n",dst[i],org[i]);
          dst[i]=org[i];
          if (org[i] == 0)
            {
              break;
            }
        }
      return i;
    }
}

