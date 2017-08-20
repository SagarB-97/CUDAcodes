// The dataset generator generates all the datasets into one single pair of input files.

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <thrust/transform.h>
#include <thrust/fill.h>
#include <math.h>

using namespace std;

float truncs(float n)
{
  float nearest = roundf(n * 100) / 100;
  return nearest;
}


int main(int argc, char *argv[]) {

  if(argc < 4)
  {
    cout<<"Ensure that an output file and 2 input files are passed in as arguments when running this program\n";
    exit(0);
  }

  /* parse the input arguments */
  //@@ Insert code here

  char file1[100], file2[100], file3[100],file4[100];
  strcpy(file3,argv[1]);
  strcpy(file1,argv[2]);
  strcpy(file2,argv[3]);
  if(argc > 4)
    strcpy(file4,argv[4]);

  
  FILE *handle1 = fopen(file1, "r");
  FILE *handle2 = fopen(file2, "r");
  FILE *handle3 = fopen(file3,"r");
  FILE *handle4;

  if(argc > 4) //To write into optional output file
  {
     handle4 = fopen(file4, "w");
  }

  for(int i = 0;i < 10; i++)
{
  float *hostInput1 = NULL;
  float *hostInput2 = NULL;
  float *hostOutput = NULL;
  int inputLength;

  //Read size of vector
  fscanf(handle1, "%d", &inputLength);
  fscanf(handle2, "%d", &inputLength);
  fscanf(handle3, "%d", &inputLength);

  hostInput1 = (float*) malloc(inputLength*sizeof(float));
  hostInput2 = (float*) malloc(inputLength*sizeof(float));

  
  // Import host input data
  //@@ Read data from the raw files here
  //@@ Insert code here
  for (int ii = 0; ii < inputLength; ii++) {
      fscanf(handle1, "%f", &hostInput1[ii]);
      fscanf(handle2, "%f",&hostInput2[ii]);
  }

  // Declare and allocate host output
  //@@ Insert code here
  hostOutput = (float*) malloc(inputLength*sizeof(float));

  // Declare and allocate thrust device input and output vectors
  //@@ Insert code here
  thrust::device_vector<float> da(hostInput1,hostInput1+inputLength); 
  thrust::device_vector<float> db(hostInput2,hostInput2+inputLength); 
  thrust::device_vector<float> dc(hostOutput,hostOutput+inputLength); 

  // Copy to device
  //@@ Insert code here

  // Execute vector addition
  //@@ Insert Code here
  thrust::transform(da.begin(), da.end(), db.begin(), dc.begin(), thrust::plus<float>());
  /////////////////////////////////////////////////////////

  // Copy data back to host
  //@@ Insert code here
  thrust::copy(dc.begin(), dc.end(), hostOutput);



  // Verifying results
  if(argc>4)
    fprintf(handle4, "%d", inputLength);
  int flag = 1;
  for(int j = 0; j < inputLength; j++)
    {
      float n;
      fscanf(handle3,"%f",&n);
      if(flag)
      {
          if(truncs(n) != truncs(hostOutput[j]))
        {
          cout<<"Dataset "<<i<<" could not be verified\n";
          //cout<<truncs(n)<<" "<<truncs(hostOutput[j])<<" "<<j<<endl;
          flag = 0;
        }
      }
      //hostOutput[j] = truncs(hostOutput[j]);
      if(argc>4)
        fprintf(handle4, "\n%f", hostOutput[j]);
      
    }

    if(flag)
      cout<<"Dataset "<<i<<" verified\n";

  cout<<endl;



  free(hostInput1);
  free(hostInput2);
  free(hostOutput);

  }

  if(argc > 4)
    cout<<"Output written into file: "<<file4<<endl;

  fclose(handle1);
  fclose(handle2);
  
  return 0;
}
