#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <cuda.h>

using namespace std;

#define TILE 10


__global__ void multiplys(int m, int k, int n, int *A, int *B, int *C)
{

	__shared__ int dA[TILE][TILE];
	__shared__ int dB[TILE][TILE];

	int bx = blockIdx.x;
	int by = blockIdx.y;
	int tx = threadIdx.x;
	int ty = threadIdx.y;

	int Row = by * blockDim.y + ty;
	int Col = bx * blockDim.x + tx;


	int Cvalue = 0;


			for(int t = 0; t < (n-1)/TILE + 1; t++)
		{
			if(Row <m && (t * TILE + tx)< n)
				dA[ty][tx] = A[Row*n + t*TILE+tx];
				else
					dA[ty][tx] = 0;
			if((t*TILE +ty)<n && Col < k)
				dB[ty][tx] = B[(t*TILE+ty)*k + Col];
				else
					dB[ty][tx] = 0;
			__syncthreads();
			for(int i = 0; i < TILE; i++)
				Cvalue += dA[ty][i] * dB[i][tx];
			__syncthreads();
		}
		
		if(Row <m && Col <k)
		C[Row*k+Col] = Cvalue;
	
}





int main(int argc, char* argv[])
{
	
  char file1[100], file2[100], file3[100];
  strcpy(file3,argv[1]);
  strcpy(file1,argv[2]);
  strcpy(file2,argv[3]);

  FILE *handle1 = fopen(file1, "r");
  FILE *handle2 = fopen(file2, "r");
  FILE *handle3 = fopen(file3,"r");

  int m,n,k;

  fscanf(handle1, "%d", &m);
  fscanf(handle1, "%d", &k);
  fscanf(handle2, "%d", &k);
  fscanf(handle2, "%d", &n);
  fscanf(handle3, "%d", &m);  
  fscanf(handle3, "%d", &n);

  int (*pA), (*pB), (*pC);

  int i,j;
  int a[500*500], b[500*500], c[500*500], c_ans[500*500];

  for(i=0;i<m;i++)
  	for(j=0;j<k;j++)
  	{
  		fscanf(handle1, "%d", &a[i*k + j]);
  	}

  for(i=0;i<k;i++)
  	for(j=0;j<n;j++)
  	{
  		fscanf(handle2, "%d", &b[i*n + j]);
  	}

  for(i=0;i<m;i++)
  	for(j=0;j<n;j++)
  	{
  		fscanf(handle3, "%d", &c_ans[i*n + j]);
  	}


  	cudaMalloc((void**)&pA, (m*k)*sizeof(int));
	cudaMalloc((void**)&pB, (k*n)*sizeof(int));
	cudaMalloc((void**)&pC, (m*n)*sizeof(int));

	cudaMemcpy(pA, a, (m*k)*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(pB, b, (k*n)*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(pC, c, (m*n)*sizeof(int), cudaMemcpyHostToDevice);


  	dim3 dimBlock(TILE, TILE);
    dim3 dimGrid(max(m,max(n,k))/dimBlock.x+1, max(m,max(k,n))/dimBlock.y+1);
    //cout<<dimGrid.x<<" "<<dimGrid.y<<endl;
	
	multiplys<<<dimGrid,dimBlock>>>(m,n,k,pA,pB,pC);  

	cudaMemcpy(c, pC, (m*n)*sizeof(int), cudaMemcpyDeviceToHost);

	cout<<"Verifying results: \n";

	int flag = 1;
	for(i=0;i<m;i++)
		{
			for(j=0;j<n;j++)
		{
			if(c[i*n + j] != c_ans[i*n+ j])
			{
				flag = 0;
				cout<<"Wrong answer\n" << c[i*n + j]<<" "<<c_ans[i*n + j]<<endl<<i<<" "<<j<<endl;
				break;
			}
		}
		if(!flag)
			break;
	}

	if(flag)
		cout<<"Answer verified\n";


	cudaFree(pA); 
	cudaFree(pB); 
	cudaFree(pC);



  
}