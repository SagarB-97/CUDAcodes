#include "wb.h"
#include <stdio.h>

#define THREAD_PER_DIM 3
#define MAX_VAL 255
#define Max(a, b) ((a) < (b) ? (b) : (a))
#define Min(a, b) ((a) > (b) ? (b) : (a))
#define Clamp(a, start, end) Max(Min(a, end), start)
#define value(arry, i, j, k) arry[((i)*width + (j)) * depth + (k)]

__device__ __host__ int linearize(int i,int j,int k,int width,int depth)
{
  return (i*width+j)*depth+k;
}
void printAscii(unsigned char* a,int n);
#define wbCheck(stmt)                                                     \
  do {                                                                    \
    cudaError_t err = stmt;                                               \
    if (err != cudaSuccess) {                                             \
      wbLog(ERROR, "Failed to run stmt ", #stmt);                         \
      wbLog(ERROR, "Got CUDA error ...  ", cudaGetErrorString(err));      \
      return -1;                                                          \
    }                                                                     \
  } while (0)

__global__ void stencil(unsigned char *output, unsigned char *input, int width, int height,
                        int depth) {
  __shared__ int cache[(THREAD_PER_DIM+2)*(THREAD_PER_DIM+2)*(THREAD_PER_DIM+2)];
  int gx = threadIdx.x + blockDim.x*blockIdx.x;
  int gy = threadIdx.y + blockDim.y*blockIdx.y;
  int gz = threadIdx.z + blockDim.z*blockIdx.z;

  int lx = threadIdx.x+1;
  int ly = threadIdx.y+1;
  int lz = threadIdx.z+1;

  cache[linearize(lx,ly,lz,THREAD_PER_DIM+2,THREAD_PER_DIM+2)] =
      input[linearize(gx,gy,gz,width,depth)];

  if(threadIdx.x==0){
    if(gx>0){
      cache[linearize(0,ly,lz,THREAD_PER_DIM+2,THREAD_PER_DIM+2)] =
        input[linearize(gx-1,gy,gz,width,depth)];
    }
    if(gx+THREAD_PER_DIM<height){
      cache[linearize(THREAD_PER_DIM+1,ly,lz,THREAD_PER_DIM+2,THREAD_PER_DIM+2)] =
        input[linearize(gx+THREAD_PER_DIM,gy,gz,width,depth)];
    }
  }
  if(threadIdx.y==0){
    if(gy>0){
      cache[linearize(lx,0,lz,THREAD_PER_DIM+2,THREAD_PER_DIM+2)] =
        input[linearize(gx,gy-1,gz,width,depth)];
    }
    if(gy+THREAD_PER_DIM<width){
      cache[linearize(lx,THREAD_PER_DIM+1,lz,THREAD_PER_DIM+2,THREAD_PER_DIM+2)] =
        input[linearize(gx,gy+THREAD_PER_DIM,gz,width,depth)];
    }
  }
  if(threadIdx.z==0){
    if(gz>0){
      cache[linearize(lx,ly,0,THREAD_PER_DIM+2,THREAD_PER_DIM+2)] =
        input[linearize(gx,gy,gz-1,width,depth)];
    }
    if(gz+THREAD_PER_DIM<depth){
      cache[linearize(lx,ly,THREAD_PER_DIM+1,THREAD_PER_DIM+2,THREAD_PER_DIM+2)] =
        input[linearize(gx,gy,gz+THREAD_PER_DIM,width,depth)];
    }
  }
  __syncthreads();

  if(gx>0 && gy>0 && gz>0 && gx<height-1 && gz<depth-1 && gy<width-1){
    unsigned char cur = cache[linearize(lx,ly,lz,THREAD_PER_DIM+2,THREAD_PER_DIM+2)];
    unsigned char down = cache[linearize(lx,ly+1,lz,THREAD_PER_DIM+2,THREAD_PER_DIM+2)];
    unsigned char up = cache[linearize(lx,ly-1,lz,THREAD_PER_DIM+2,THREAD_PER_DIM+2)];
    unsigned char left = cache[linearize(lx,ly,lz-1,THREAD_PER_DIM+2,THREAD_PER_DIM+2)];
    unsigned char right = cache[linearize(lx,ly,lz+1,THREAD_PER_DIM+2,THREAD_PER_DIM+2)];
    unsigned char front = cache[linearize(lx-1,ly,lz,THREAD_PER_DIM+2,THREAD_PER_DIM+2)];
    unsigned char back = cache[linearize(lx+1,ly,lz,THREAD_PER_DIM+2,THREAD_PER_DIM+2)];

    int res= right + left + up + down + front + back - 6*cur;
    res = Clamp(res,0,255);

    output[linearize(gx,gy,gz,width,depth)] = res;
  }
}

static void launch_stencil(unsigned char *deviceOutputData, unsigned char *deviceInputData,
                           int width, int height, int depth) {
  dim3 blockDim(THREAD_PER_DIM,THREAD_PER_DIM,THREAD_PER_DIM);
  dim3 gridDim((height-1)/THREAD_PER_DIM+1,(width-1)/THREAD_PER_DIM+1,(depth-1)/THREAD_PER_DIM+1);

  stencil<<<gridDim,blockDim>>>(deviceOutputData,deviceInputData,
                            width, height, depth);
}
void getWHD(char *fileName,int *w,int *h,int *d)
{
  FILE *fp = fopen(fileName,"r");
  fscanf(fp,"%d %d %d",w,h,d);
  fclose(fp);
}
void getData(char *fileName,unsigned char *data)
{
  FILE *fp = fopen(fileName,"r");
  int width,height,depth;
  fscanf(fp,"%d %d %d",&width,&height,&depth);

  char* tmp = (char*)malloc(500);
  fgets(tmp,500,fp);

  fread(data,width*height*depth,1,fp);

  fclose(fp);
  free(tmp);
}
bool checkSoln(unsigned char* a,unsigned char* b,int n)
{
  for(int i=0;i<n;i++){
    if(a[i]!=b[i]) return false;
  }
  return true;
}
int main(int argc, char *argv[]) {
  wbArg_t arg;
  int width;
  int height;
  int depth;
  char *inputFile;
  char *expFile;
  unsigned char *hostExpectedOutput;
  unsigned char *hostInputData;
  unsigned char *hostOutputData;
  unsigned char *deviceInputData;
  unsigned char *deviceOutputData;

  arg = wbArg_read(argc, argv);

  inputFile = wbArg_getInputFile(arg, 0);
  expFile = wbArg_getInputFile(arg,1);

  getWHD(inputFile,&width,&height,&depth);
  printf("Input file dimensions : %d %d %d\n",width,height,depth);
  hostInputData = (unsigned char*)malloc(height*width*depth);
  getData(inputFile,hostInputData);

  hostOutputData = (unsigned char*)malloc(height*width*depth);

  int eWidth,eHeight,eDepth;
  getWHD(expFile,&eWidth,&eHeight,&eDepth);
  hostExpectedOutput = (unsigned char*)malloc(eHeight*eWidth*eDepth);
  memset(hostExpectedOutput,0,width*height*depth);
  getData(expFile,hostExpectedOutput);

  wbTime_start(GPU, "Doing GPU memory allocation");
  cudaMalloc((void **)&deviceInputData,
             width * height * depth * sizeof(char));
  cudaMalloc((void **)&deviceOutputData,
             width * height * depth * sizeof(char));
  cudaMemset(deviceOutputData,0,sizeof(char)*width*height*depth);
  wbTime_stop(GPU, "Doing GPU memory allocation");

  wbTime_start(Copy, "Copying data to the GPU");
  cudaMemcpy(deviceInputData, hostInputData,
             width * height * depth * sizeof(char),
             cudaMemcpyHostToDevice);
  wbTime_stop(Copy, "Copying data to the GPU");

  wbTime_start(Compute, "Doing the computation on the GPU");
  launch_stencil(deviceOutputData, deviceInputData, width, height, depth);
  wbTime_stop(Compute, "Doing the computation on the GPU");

  wbTime_start(Copy, "Copying data from the GPU");
  cudaMemcpy(hostOutputData, deviceOutputData,
             width * height * depth * sizeof(char),
             cudaMemcpyDeviceToHost);
  wbTime_stop(Copy, "Copying data from the GPU");

  if(width!=eWidth || height!=eHeight || depth!=eDepth)
    std::cout<<"Dimensions don't match";
  else if(checkSoln(hostExpectedOutput,hostOutputData,width*height*depth))
    std::cout<<"Solution verified\n";
  else
    std::cout<<"Wrong Solution\n";

  cudaFree(deviceInputData);
  cudaFree(deviceOutputData);

  return 0;
}
