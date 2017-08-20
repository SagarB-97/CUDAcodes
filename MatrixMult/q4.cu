#include <stdio.h>
#include <iostream>
#include <stdlib.h>

using namespace std;

__global__ void MM(int m, int k, int n, int *A, int *B, int *C)
{

	int Row = blockIdx.y * blockDim.y + threadIdx.y;
	int Col = blockIdx.x * blockDim.x + threadIdx.x;

	if((Row < m) && (Col < k))
	{
		int Cvalue = 0;
		for(int i = 0; i < n; i++)
			Cvalue += A[Row*n+i] * B[Col +i*k];

		C[Row*k+Col] = Cvalue; 
	}
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

  //cout<<m<<" "<<n<<" "<<k<<endl;

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


  	dim3 dimBlock(32, 32);
    dim3 dimGrid(max(m,max(n,k))/dimBlock.x+1, max(m,max(k,n))/dimBlock.y+1);
    //cout<<dimGrid.x<<" "<<dimGrid.y<<endl;
	
	MM<<<dimGrid,dimBlock>>>(m,n,k,pA,pB,pC);  

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
		//if(!flag)
			//break;
	}

	if(flag)
		cout<<"Answer verified\n";


	cudaFree(pA); 
	cudaFree(pB); 
	cudaFree(pC);



  
}