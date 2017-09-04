// Execute order ./a./a.out 0output.raw 0input.raw 
.out 0output.raw 0input.raw 


#include "wb.h"

using namespace std;
#define BIN_CAP 127

#define NUM_BINS 4096

#define N 128

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

__global__ void Histo (unsigned int *buffer , unsigned int *histo, int inputLength)
{
       int id_x = blockIdx.x * blockDim.x + threadIdx.x ;
       //int id_y = blockIdx.y * blockDim.y + threadIdx.y ;
       //int absoulteId = id_y*N + id_x ;
	   //int id_x = blockIdx.x;
      if(id_x < inputLength && buffer[id_x] < NUM_BINS)
      //if(absoulteId < inputLength && buffer[absoulteId] <NUM_BINS )
        atomicAdd(&histo[buffer[id_x]],1);
}

__global__ void reduc(unsigned int * histo)
{
	int id_x = blockIdx.x * blockDim.x + threadIdx.x ;

	if(histo[id_x] > BIN_CAP)
		histo[id_x] = BIN_CAP;
}


int main(int argc, char *argv[]) {

  int inputLength;
  unsigned int *hostInput;
  unsigned int *hostBins;
  unsigned int *deviceInput;
  unsigned int *deviceBins;

  /* Read input arguments here */
  wbArg_t args = wbArg_read(argc,argv);

  wbTime_start(Generic, "Importing data and creating memory on host");
  hostInput = (unsigned int *)wbImport(wbArg_getInputFile(args, 1),
                                       &inputLength);
  hostBins = (unsigned int *)calloc(NUM_BINS , sizeof(unsigned int));
  wbTime_stop(Generic, "Importing data and creating memory on host");

  wbLog(TRACE, "The input length is ", inputLength);
  wbLog(TRACE, "The number of bins is ", NUM_BINS);

  wbTime_start(GPU, "Allocating GPU memory.");
  //@@ Allocate GPU memory here
  CUDA_CHECK(cudaDeviceSynchronize());
  wbTime_stop(GPU, "Allocating GPU memory.");
  cudaMalloc((void **)&deviceInput,inputLength * sizeof(unsigned int));
  cudaMalloc((void **)&deviceBins,NUM_BINS * sizeof(unsigned int));

  wbTime_start(GPU, "Copying input memory to the GPU.");
  //@@ Copy memory to the GPU here
  cudaMemcpy(deviceInput, hostInput, inputLength * sizeof(unsigned int), cudaMemcpyHostToDevice);
  cudaMemcpy(deviceBins, hostBins, NUM_BINS * sizeof(unsigned int), cudaMemcpyHostToDevice);


  CUDA_CHECK(cudaDeviceSynchronize());
  wbTime_stop(GPU, "Copying input memory to the GPU.");

  // Launch kernel
  // ----------------------------------------------------------
  wbLog(TRACE, "Launching kernel");
  wbTime_start(Compute, "Performing CUDA computation");
  //@@ Perform kernel computation here


	//dim3 blocks (N,N);
	//dim3 grid(inputLength / N + 1, inputLength/N +1) ; 
  	//Histo <<< grid, blocks>>> (deviceInput , deviceBins,inputLength ) ;
	Histo <<< (inputLength-1)/N + 1, N>>> (deviceInput , deviceBins,inputLength ) ;
	reduc <<<NUM_BINS/N, N>>> (deviceBins);
	//Histo <<< inputLength, 1>>> (deviceInput , deviceBins,inputLength ) ;
	
  wbTime_stop(Compute, "Performing CUDA computation");

  wbTime_start(Copy, "Copying output memory to the CPU");
  //@@ Copy the GPU memory back to the CPU here
  cudaMemcpy(hostBins, deviceBins, NUM_BINS * sizeof(unsigned int), cudaMemcpyDeviceToHost);
  CUDA_CHECK(cudaDeviceSynchronize());
  wbTime_stop(Copy, "Copying output memory to the CPU");

  wbTime_start(GPU, "Freeing GPU Memory");
  //@@ Free the GPU memory here
     cudaFree(deviceInput);
    cudaFree(deviceBins);
  wbTime_stop(GPU, "Freeing GPU Memory");

  // Verify correctness
  // -----------------------------------------------------
  wbSolution(args, hostBins, NUM_BINS);

  free(hostBins);
  free(hostInput);
  return 0;
}
