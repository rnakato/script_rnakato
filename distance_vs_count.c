#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define max(a, b) ((a) > (b)) ? (a) :(b)

#define WINSIZE 10000
#define ARRAYNUM 25000
#define STR_LEN 10000
#define ELEM_NUM 256

typedef struct{
  char str[10240];
} Elem;

int ParseLine(char *str, Elem clm[]);
void *my_calloc(size_t n, size_t s, char *name);

int main(int argc, char *argv[])
{
  int i;
  FILE *IN;
  Elem clm[ELEM_NUM];

  char *str = (char *)my_calloc(STR_LEN, sizeof(char), "str");
  int *array = (int *)my_calloc(ARRAYNUM, sizeof(int), "array");

  if ((IN = fopen(argv[1], "r")) == NULL) {
    fprintf(stderr,"[E] cannot open %s.\n", argv[0]);
    exit(1);
  }
  while ((fgets(str, STR_LEN, IN))!=NULL) { 
    if(str[0]=='\n') continue;
    //    printf("str %s",str);
    
    int nclm = ParseLine(str, clm);
    //    printf("nclm = %d\n",nclm);
    if(nclm < 6) continue;
    if(strcmp(clm[1].str, clm[4].str)) continue;
    
    int start = atoi(clm[2].str);
    int end = atoi(clm[5].str);
    int length = end - start;
    if(length >= WINSIZE*ARRAYNUM) continue;
    array[length/WINSIZE]++;
  }

  for (i=0; i<ARRAYNUM; i++) {
    printf("%d - %d | %d\n", WINSIZE*i, WINSIZE*(i+1)-1, array[i]);
  }

  free(str);
  free(array);
  return 0;
}


int ParseLine(char *str, Elem clm[])
{
  int i, j=0, num=0, len=strlen(str);
  char *strtemp = (char *)my_calloc(len, sizeof(char), "ParseLine");
  for(i=0; i<=len; i++){
    if(str[i]=='\0' || str[i]=='\n'){
      strtemp[j]='\0';
      strcpy(clm[num].str, strtemp);
      free(strtemp);
      return ++num;
    }
    if(str[i]=='\t'){
      strtemp[j]='\0';
      strcpy(clm[num].str, strtemp);
      num++; 
      if(num >= ELEM_NUM){
	fprintf(stderr, "error: too many columns: %s", str);
	exit(0);
      }
      j=0;
    }else{
      strtemp[j]=str[i];
      j++;
    }
  }
  free(strtemp);
  return num;
}

void *my_calloc(size_t n, size_t s, char *name)
{
  void *p;
  p = calloc(n,s);
  if(!p){
    fprintf(stderr,"[E]failed calloc: %s\n", name); 
    exit(1);
  }
  return p;
}
