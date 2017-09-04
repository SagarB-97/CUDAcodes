#include "wb.h"

#include <thrust/adjacent_difference.h>
#include <thrust/binary_search.h>
#include <thrust/copy.h>
#include <thrust/device_vector.h>
#include <thrust/iterator/counting_iterator.h>
#include <thrust/sort.h>

//#define num_bins 4096

int main(int argc, char *argv[]) {
  wbArg_t args;
  int inputLength, num_bins;
  unsigned int *hostInput, *hostBins;

  args = wbArg_read(argc, argv);

  wbTime_start(Generic, "Importing data and creating memory on host");
  hostInput = (unsigned int *)wbImport(wbArg_getInputFile(args, 1),
                                       &inputLength);
  
  wbTime_stop(Generic, "Importing data and creating memory on host");

  wbLog(TRACE, "The input length is ", inputLength);

  // Copy the input to the GPU
  wbTime_start(GPU, "Allocating GPU memory");
  thrust::device_vector<int> deviceInput(hostInput, hostInput + inputLength);


  //@@ Insert code here
  wbTime_stop(GPU, "Allocating GPU memory");

  // Determine the number of bins (num_bins) and create space on the host
  //@@ insert code here
  thrust::sort(deviceInput.begin(), deviceInput.end());
  num_bins = deviceInput.back() + 1;
  hostBins = (unsigned int *)calloc(num_bins , sizeof(unsigned int));


  // Allocate a device vector for the appropriate number of bins
  //@@ insert code here
  thrust::device_vector<int> deviceBins(hostBins, hostBins + num_bins);
  // Create a cumulative histogram. Use thrust::counting_iterator and
  // thrust::upper_bound
  //@@ Insert code here
  thrust::device_vector<int> cumdiff(num_bins+1);

  
  thrust::counting_iterator<int> x(0);

  thrust::upper_bound(deviceInput.begin(), deviceInput.end(), x, x + num_bins, cumdiff.begin());


  // Use thrust::adjacent_difference to turn the culumative histogram
  // into a histogram.
  //@@ insert code here.

  thrust::adjacent_difference( cumdiff.begin(), cumdiff.end(), deviceBins.begin());

  // Copy the histogram to the host
  //@@ insert code here

    thrust::copy(deviceBins.begin(), deviceBins.end(), hostBins);


  // Check the solution is correct
  wbSolution(args, hostBins, num_bins);

  // Free space on the host
  //@@ insert code here
  free(hostBins);

  return 0;
}
