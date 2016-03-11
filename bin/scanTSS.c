#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STR_LEN 102400
#define STR_NUM 128
#define DEFTOKEN '\t'
#define STRUCT_BS_MAX 1000000
#define STRUCT_GENE_MAX 100000

typedef enum{
  CODINGGENE,
  PSEUDO,
  RNA,
  OTHERS
} genetype;

struct exon{
  int start;
  int end;
};

struct gene_exon{
  char name[32];
  int start;
  int end;
  int exonnum;
  struct exon *exon;
  char chr[32];
  int dir;
  genetype genetype;
  int on;
};

struct elem{
  char str[12800];
};

struct bs{
  char chr[32];
  int start;
  int end;
  double maxvalue;
  int flag;
  int strand;
};


int read_gene_ENS(char *filename, struct gene_exon **ref_gene);
int ParseLine(char *, struct elem *, int);
int ParseLine_arbit(char *str, struct elem clm[STR_NUM], int len, char token);
void chomp(char *, int);

int main(int argc, char *argv[]){
  FILE *IN;
  int i,j, num=0, gene_num=0, start, end;
  char str[STR_LEN];
  struct gene_exon *gene;
  if(argc!=4){
    fprintf(stderr,"input: scanTSS <Ensembl gene file> <bs file> <extend length>\n");
    exit(1);
  }
  struct elem *clm;
  clm = (struct elem *)calloc(10, sizeof(struct elem));
  struct bs *bsarray;
  if((bsarray = (struct bs *)calloc(STRUCT_BS_MAX, sizeof(struct bs)))== NULL){
    fprintf(stderr,"[E]failed calloc: bsarray\n"); exit(1);
  }
  int extend_length=atoi(argv[3]);

  /* Ensembl genes */
  gene_num = read_gene_ENS(argv[1], &gene);

  /* read bs */
  if((IN = fopen(argv[2], "r"))==NULL){
    fprintf(stderr,"[E]Cannot open %s.\n", argv[2]);
    exit(1);
  }
  while((fgets(str, STR_LEN, IN))!=NULL){
    if(str[0]=='\n') continue;
    chomp(str, STR_LEN);
    ParseLine(str, clm, STR_LEN);
    strcpy(bsarray[num].chr, clm[0].str);
    bsarray[num].start = atoi(clm[1].str);
    bsarray[num].end = atoi(clm[2].str);
    bsarray[num].maxvalue = atof(clm[3].str);
    bsarray[num].flag = atoi(clm[4].str);
    if(clm[5].str) bsarray[num].strand = atoi(clm[5].str);
    num++;
  }
  fclose(IN);
  free(clm);

  int cnt_genic=0, cnt_intergenic=0;
  int on;
  for(i=0; i<num; i++){
    on=0;
    for(j=0; j<gene_num; j++){
      //if(gene[j].dir != bsarray[i].strand) continue;  /* タグの方向を考慮する */
      if(strcmp(bsarray[i].chr, gene[j].chr)) continue;

      if(gene[j].dir==1){
	start = gene[j].start - extend_length;
	end = gene[j].start;
      }else{
	start = gene[j].start;
	end = gene[j].start + extend_length;
      }
      if(start <= bsarray[i].end && end >= bsarray[i].start){
	/* overlapping binding sites */
	cnt_genic++;
	on=1;
	gene[j].on=1;
	break;
      }
    }
    if(!on) cnt_intergenic++;
  }

  int numall=0, num_coding=0, num_rna=0, num_pseudo=0, num_others=0; 
  int num_coding_all=0, num_rna_all=0, num_pseudo_all=0, num_others_all=0; 
  for(j=0; j<gene_num; j++){
    switch (gene[j].genetype){
    case CODINGGENE: num_coding_all++; break;
    case RNA: num_rna_all++; break;
    case PSEUDO: num_pseudo_all++; break;
    case OTHERS: num_others_all++; break;
    }
    if(gene[j].on){
      numall++;
      switch (gene[j].genetype){
      case CODINGGENE: num_coding++; break;
      case RNA: num_rna++; break;
      case PSEUDO: num_pseudo++; break;
      case OTHERS: num_others++; break;
      }
    }
  }

  printf("<binding site> all: %d, genic: %d, intergenic: %d\n", num, cnt_genic, cnt_intergenic);
  double ratio_all, ratio_coding, ratio_rna, ratio_pseudo, ratio_others;
  ratio_all = numall/(double)gene_num*100;
  ratio_coding = num_coding/(double)num_coding_all*100;
  ratio_rna = num_rna/(double)num_rna_all*100;
  ratio_pseudo = num_pseudo/(double)num_pseudo_all*100;
  ratio_others = num_others/(double)num_others_all*100;
  printf("<gene> all: %d(/%d (%.1f%%))\n", numall, gene_num, ratio_all);
  printf("<gene> coding gene:%d(/%d (%.1f%%))\n", num_coding, num_coding_all, ratio_coding);
  printf("<gene> RNA:%d(/%d (%.1f%%))\n", num_rna, num_rna_all, ratio_rna);
  printf("<gene> pseudo gene:%d(/%d (%.1f%%))\n", num_pseudo, num_pseudo_all, ratio_pseudo);
  printf("<gene> others:%d(/%d (%.1f%%))\n", num_others, num_others_all, ratio_others);

  free(bsarray);
  free(gene);

  return 0;
}


void *my_calloc(size_t n, size_t s, char *name){
  void *p;
  p = calloc(n,s);
  if(!p){
    fprintf(stderr,"[E]failed calloc: %s\n", name); 
    exit(1);
  }
  return p;
}

FILE *my_fopen_r(char *filename){
  FILE *IN;
  if((IN = fopen(filename, "r"))==NULL){
    fprintf(stderr,"[E] Cannot open <%s>.\n", filename); 
    exit(1);
  }
  return IN;
}

int read_gene_ENS(char *filename, struct gene_exon **ref_gene){
  FILE *IN;
  int i, num=0;
  char *str;
  str = (char *)my_calloc(STR_LEN, sizeof(struct elem), "str");
  struct elem *clm, *clm2;
  clm = (struct elem *)my_calloc(STR_NUM, sizeof(struct elem), "clm");
  clm2 = (struct elem *)my_calloc(STR_NUM, sizeof(struct elem), "clm2");
  struct gene_exon *gene = *ref_gene;
  gene = (struct gene_exon *)my_calloc(STRUCT_GENE_MAX, sizeof(struct gene_exon), "gene");

  IN = my_fopen_r(filename);
  while((fgets(str, STR_LEN, IN))!=NULL){
    if(str[0]=='\n') continue;
    chomp(str, STR_LEN);
    ParseLine(str, clm, STR_LEN);

    strcpy(gene[num].chr, clm[5].str);
    strcpy(gene[num].name, clm[0].str);
    if(!strcmp(clm[1].str, "protein_coding")) gene[num].genetype = CODINGGENE;
    else if(!strcmp(clm[1].str, "pseudogene")) gene[num].genetype = PSEUDO;
    else if(!strstr(clm[1].str, "RNA")) gene[num].genetype = RNA;
    else gene[num].genetype = OTHERS;
    gene[num].dir = atoi(clm[2].str);
    gene[num].start = atoi(clm[3].str);
    gene[num].end   = atoi(clm[4].str);
    gene[num].exonnum = atoi(clm[6].str);
    gene[num].exon = (struct exon *)my_calloc(gene[num].exonnum, sizeof(struct exon), "exon");
    ParseLine_arbit(clm[7].str, clm2, strlen(clm[7].str), ',');
    for(i=0; i<gene[num].exonnum; i++) gene[num].exon[i].start = atoi(clm2[i].str);
    ParseLine_arbit(clm[8].str, clm2, strlen(clm[8].str), ',');
    for(i=0; i<gene[num].exonnum; i++) gene[num].exon[i].end = atoi(clm2[i].str);
    
    num++;
    if(num>=STRUCT_GENE_MAX){fprintf(stderr,"STRUCT_GENE_MAX over.\n"); exit(1);}
  }
  fclose(IN);
  free(str);
  free(clm);
  free(clm2);
  *ref_gene = gene;
  return num;
}


int ParseLine(char *str, struct elem *str_array, int len){
  char strtemp[len];
  int i, j=0, num=0;
  for(i=0; i<len; i++){
    if(str[i]=='\0'){
      strtemp[j]='\0';
      strcpy(str_array[num].str, strtemp);
      return ++num;
    }
    if(str[i]==DEFTOKEN){
      strtemp[j]='\0';
      strcpy(str_array[num].str, strtemp);
      num++; 
      j=0;
    }else{
      strtemp[j]=str[i];
      j++;
    }
  }
  return num;
}

int ParseLine_arbit(char *str, struct elem clm[STR_NUM], int len, char token){
  char *strtemp;
  strtemp = (char *)my_calloc(len, sizeof(char), "strtemp");

  //  printf("%s\n", str);
  int i, j=0, num=0;
  for(i=0; i<len; i++){
    if(str[i]=='\0'){
      strtemp[j]='\0';
      strcpy(clm[num].str, strtemp);
      free(strtemp);
      return ++num;
    }
    if(str[i]==token){
      strtemp[j]='\0';
      strcpy(clm[num].str, strtemp);
      num++; 
      j=0;
    }else{
      strtemp[j]=str[i];
      j++;
    }
  }
  free(strtemp);
  return num;
}

void chomp(char *str, int len){
  int i;
  for(i=0; i<len; i++){
    if(str[i]=='\n'){
      str[i]='\0';
      return;
    }
  }
}
