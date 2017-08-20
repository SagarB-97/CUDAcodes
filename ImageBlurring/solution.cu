#include "ppmHelper.h"
#include "wb.h"
#define THREADS_PER_BLOCK 512
#define BLUR_SIZE 2

__global__ void blur(PPMpixel *inData,PPMpixel *outData,int width,int height)
{
    int x = blockDim.y*blockIdx.y+threadIdx.y;
    int y = blockDim.x*blockIdx.x+threadIdx.x;

    if(x<height && y<width){
        int red=inData[x*width+y].r;
        int green=inData[x*width+y].g;
        int blue=inData[x*width+y].b;
        int i,j,considered=1;
       
        for(i=x-BLUR_SIZE;i<=x+BLUR_SIZE;i++){
            for(j=y-BLUR_SIZE;j<=y+BLUR_SIZE;j++){
                if(i>0 && j>0 && i<width && j<height){
                    red+=inData[i*width+j].r;
                    blue+=inData[i*width+j].b;
                    green+=inData[i*width+j].g;
                    considered++;
                }
            }
        }
        red/=considered;
        green/=considered;
        blue/=considered;

        outData[x*width+y].r=red;
        outData[x*width+y].g=green;
        outData[x*width+y].b=blue;
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
    PPMpixel *outData = (PPMpixel*)malloc(sizeof(PPMpixel)*totPixels);
    
    PPMpixel *d_inData,*d_outData;
    cudaMalloc((void**)&d_inData,sizeof(PPMpixel)*totPixels);
    cudaMalloc((void**)&d_outData,sizeof(PPMpixel)*totPixels);

    cudaMemcpy(d_inData,inData,sizeof(PPMpixel)*totPixels,cudaMemcpyHostToDevice);

    dim3 blockDim(32,32);
    dim3 gridDim(width/32+1,height/32+1);
    blur<<<gridDim,blockDim>>>(d_inData,d_outData,width,height);

    cudaMemcpy(outData,d_outData,sizeof(PPMpixel)*totPixels,cudaMemcpyDeviceToHost);

    
    char *outputImageFile = wbArg_getInputFile(args, 1);
    writePPM(outputImageFile,ppmTochar(outData,width,height),inpImg->width,inpImg->height,3);
}
