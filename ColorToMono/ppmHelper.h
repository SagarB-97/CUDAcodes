#include <stdio.h>
#include <stdlib.h>

typedef struct{
    unsigned char r,g,b;
} PPMpixel;


typedef struct{
    int width,height;
    PPMpixel *data;
} PPMimg;

typedef struct{
    unsigned char i;
} PPMpixelM;

typedef struct{
    int width,height;
    PPMpixelM *data;
} PPMimgM;


PPMimg* readPPM(const char *filename)
{
    FILE *fp = fopen(filename,"rb");
    char buf[16];
    
    fgets(buf,sizeof(buf),fp); //Get file format : P5,P6 etc

    char c = getc(fp);
    while (c == '#') {
    while (getc(fp) != '\n') ;
         c = getc(fp);
    }
    ungetc(c,fp);


    unsigned int width,height,rgb_comp_color;
    fscanf(fp,"%d %d",&width,&height);
    fscanf(fp,"%d",&rgb_comp_color);

    while (fgetc(fp) != '\n');

    PPMpixel *data = (PPMpixel*)malloc(width*height*sizeof(PPMpixel));

    fread(data,sizeof(PPMpixel),width*height,fp);

    PPMimg *img = (PPMimg*)malloc(sizeof(PPMimg));
    img->width = width;
    img->height = height;
    img->data = data;

    return img;
}

void writePPM(char *file_name, unsigned char *data,
                       unsigned int width, unsigned int height,
                       unsigned int channels) {
  FILE *handle = fopen(file_name, "w");
  if (channels == 1) {
    fprintf(handle, "P5\n");
  } else {
    fprintf(handle, "P6\n");
  }
  fprintf(handle, "#Created by %s\n", __FILE__);
  fprintf(handle, "%d %d\n", width, height);
  fprintf(handle, "255\n");

  fwrite(data, width * channels * sizeof(unsigned char), height, handle);

  fflush(handle);
  fclose(handle);
}

unsigned char* ppmTochar(PPMpixel* img,int width,int height)
{
    unsigned char* image = (unsigned char*)malloc(width*height*3);

    int i,n=width*height,k=0;
    for(i=0;i<n;i++){
        image[k++]=img[i].r;
        image[k++]=img[i].g;
        image[k++]=img[i].b;
    }
    return image;
}

unsigned char* ppmTocharM(PPMpixelM* img,int width,int height)
{
    unsigned char *image = (unsigned char*)malloc(width*height);

    int i,n=width*height,k=0;
    for(i=0;i<n;i++){
        image[k++]=img[i].i;
    }
    return image;
}
    
