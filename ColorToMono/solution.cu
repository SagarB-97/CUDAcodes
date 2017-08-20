#include "ppmHelper.h"
#include "wb.h"
#define THREADS_PER_BLOCK 512
#define BLUR_SIZE 3

__global__ void blur(PPMpixel *inData,PPMpixelM *outData,int width,int height)
{
    int x = blockDim.y*blockIdx.y+threadIdx.y;
    int y = blockDim.x*blockIdx.x+threadIdx.x;

    if(x<height && y<width){
        int red=inData[x*width+y].r;
        int green=inData[x*width+y].g;
        int blue=inData[x*width+y].b;

        outData[x*width+y].i = red*0.21+green*0.71+blue*0.07;
    }
}
int main(int argc,char **argv)
{

    wbArg_t args = wbArg_read(argc, argv);

    //Get input image
    char *inputImageFile = wbArg_getInputFile(args, 0);
    PPMimg *inpImg = readPPM(inputImageFile);
    int width = inpImg->width;
    int height = inpImg->height;
    int totPixels = width*height;

    PPMpixel *inData = inpImg->data;
    PPMpixelM *outData = (PPMpixelM*)malloc(sizeof(PPMpixelM)*totPixels);
    
    PPMpixel *d_inData;
    PPMpixelM *d_outData;
    cudaMalloc((void**)&d_inData,sizeof(PPMpixel)*totPixels);
    cudaMalloc((void**)&d_outData,sizeof(PPMpixelM)*totPixels);

    cudaMemcpy(d_inData,inData,sizeof(PPMpixel)*totPixels,cudaMemcpyHostToDevice);

    dim3 blockDim(32,32);
    dim3 gridDim(width/32+1,height/32+1);
    blur<<<gridDim,blockDim>>>(d_inData,d_outData,width,height);

    cudaMemcpy(outData,d_outData,sizeof(PPMpixelM)*totPixels,cudaMemcpyDeviceToHost);

    
    char *outputImageFile = wbArg_getInputFile(args, 1);
    writePPM(outputImageFile,ppmTocharM(outData,width,height),inpImg->width,inpImg->height,1);
}
