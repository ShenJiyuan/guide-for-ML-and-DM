//  change.c
//  Change the sample label to +1/-1

#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[])
{
    char buffer[100000];
    char tag;
    char *tmp;
    char outfile_name[1000];
    int label;
    
    FILE *infile=fopen(argv[1],"r");
    sprintf(outfile_name,"reg%s",argv[1]);
    FILE *outfile=fopen(outfile_name,"w");

    while (fgets(buffer,100001,infile)) {
        tag=buffer[0];
        label=-1;
        if (tag=='A') label=1;
        strtok(buffer," ");
        fprintf(outfile,"%d",label);
        while (tmp=strtok(NULL," ")) {
            fprintf(outfile," %s",tmp);
        }
    }
    fclose(outfile);
    fclose(infile);
    return 0;
}
