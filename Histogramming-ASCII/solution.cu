#include "wb.h"
#include <stdlib.h>
#include <stdio.h>

#define NUM_BINS 128
#define THREADS_PER_BLOCK 128

__global__ void computeHistogram(char* input, int len, unsigned int *output)
{
  int index = threadIdx.x + blockDim.x*blockIdx.x;
  __shared__ unsigned int tempHist[NUM_BINS];
  tempHist[threadIdx.x]=0;
  __syncthreads();

  if(index<len) atomicAdd(&tempHist[input[index]],1);
  __syncthreads();

  atomicAdd(&output[threadIdx.x],tempHist[threadIdx.x]);
}
#define CUDA_CHECK(ans)                                                   \
  { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line,
                      bool abort = true) {
  if (code != cudaSuccess) {
    fprintf(stderr, "GPUassert: %s %s %d\n", cudaGetErrorString(code),
            file, line);
    if (abort)
      exit(code);
  }
}
char* readFromFile(char* fileName,int *len)
{
  FILE *fp = fopen(fileName,"rb");
  fseek(fp,0L,SEEK_END);
  *len = ftell(fp);
  rewind(fp);

  char *buffer = (char*)malloc(*len+1);
  fread(buffer,*len,1,fp);
  fclose(fp);
  buffer[*len]='\0';
  return buffer;
}
bool isCorrectSolution(char* expectedOutputfileName, unsigned int *output)
{
  unsigned int *expOut = (unsigned int*)malloc(sizeof(unsigned int)*NUM_BINS);
  FILE *fp = fopen(expectedOutputfileName,"rb");

  for(int i=0;i<NUM_BINS;i++) fscanf(fp,"%d",&expOut[i]);

  for(int i=0;i<NUM_BINS;i++){
    if(output[i]!=expOut[i]) return false;
  }
  return true;
}
void writeIntoFile(char *fileName,unsigned int *data)
{
  FILE *fp = fopen(fileName,"w");
  for(int i=0;i<NUM_BINS;i++) fprintf(fp,"%d\n",data[i]);
  fclose(fp);
}
int main(int argc, char *argv[]) {
  wbArg_t args;
  int inputLength;
  char *hostInput;
  unsigned int *hostBins;
  char *deviceInput;
  unsigned int *deviceBins;

  args = wbArg_read(argc, argv);

  wbTime_start(Generic, "Importing data and creating memory on host");
  hostInput = (char *)readFromFile(wbArg_getInputFile(args, 1),&inputLength);
  //std::cout<<"Input = "<<hostInput<<"\n";
  hostBins = (unsigned int *)malloc(NUM_BINS * sizeof(unsigned int));
  memset(hostBins,0,sizeof(hostBins));
  wbTime_stop(Generic, "Importing data and creating memory on host");

  wbLog(TRACE, "The input length is ", inputLength);
  wbLog(TRACE, "The number of bins is ", NUM_BINS);

  wbTime_start(GPU, "Allocating GPU memory.");
  cudaMalloc((void**)&deviceInput,inputLength);
  cudaMalloc((void**)&deviceBins,sizeof(unsigned int)*NUM_BINS);
  cudaMemset(deviceBins,0,sizeof(unsigned int)*NUM_BINS);
  CUDA_CHECK(cudaDeviceSynchronize());
  wbTime_stop(GPU, "Allocating GPU memory.");

  wbTime_start(GPU, "Copying input memory to the GPU.");
  cudaMemcpy(deviceInput,hostInput,inputLength,cudaMemcpyHostToDevice);
  CUDA_CHECK(cudaDeviceSynchronize());
  wbTime_stop(GPU, "Copying input memory to the GPU.");

  // Launch kernel
  // ----------------------------------------------------------
  wbLog(TRACE, "Launching kernel");
  wbTime_start(Compute, "Performing CUDA computation");
  int noOfBlocks = (inputLength/THREADS_PER_BLOCK)+1;
  computeHistogram<<<noOfBlocks,THREADS_PER_BLOCK>>>(deviceInput,inputLength,deviceBins);
  wbTime_stop(Compute, "Performing CUDA computation");

  wbTime_start(Copy, "Copying output memory to the CPU");
  cudaMemcpy(hostBins,deviceBins,sizeof(unsigned int)*NUM_BINS,cudaMemcpyDeviceToHost);
  CUDA_CHECK(cudaDeviceSynchronize());
  wbTime_stop(Copy, "Copying output memory to the CPU");

  wbTime_start(GPU, "Freeing GPU Memory");
  cudaFree(deviceBins);
  cudaFree(deviceInput);
  wbTime_stop(GPU, "Freeing GPU Memory");

  // Verify correctness
  // -----------------------------------------------------
  if(isCorrectSolution(wbArg_getInputFile(args, 0),hostBins))
    std::cout<<"Solution Verified\n";
  else
    std::cout<<"Wrong Solution\n";

  if(argc>3)
    writeIntoFile(wbArg_getInputFile(args,2),hostBins);


  free(hostBins);
  free(hostInput);
  return 0;
}
