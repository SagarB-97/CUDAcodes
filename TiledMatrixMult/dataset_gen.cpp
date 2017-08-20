#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string.h>

using namespace std;

static void write_data(char *file_name, int data[][500], int m, int n) {
  FILE *handle = fopen(file_name, "w");
  fprintf(handle, "%d", m);
  fprintf(handle, "\n%d", n);
  for (int i = 0; i < m; i++) 
  	for(int j = 0; j < n; j++)
  {
    fprintf(handle, "\n%d", data[i][j]);
  }
  fflush(handle);
  fclose(handle);
}

void create_dataset(int datasetNum, int m, int n, int k) {

  string input0_file_name = "input0-";
  string input1_file_name = "input1-";
  string output_file_name = "output-";
  input0_file_name.push_back(char(datasetNum+'0'));
  input1_file_name.push_back(char(datasetNum+'0'));
  output_file_name.push_back(char(datasetNum+'0'));
  input1_file_name.append(".raw");
  output_file_name.append(".raw");
  input0_file_name.append(".raw");


  int input0_data[500][500], input1_data[500][500],output_data[500][500];

  for (int i = 0; i < m; i++)
  	for (int j = 0; j < k; ++j)
	  {
	    input0_data[i][j] = rand()%100;
	    input1_data[i][j] = rand()%100;
	    output_data[i][j] = 0;
	  }

	  for (int i = 0; i < k; i++)
  	for (int j = 0; j < n; ++j)
	  {
	    input0_data[i][j] = rand()%100;
	    input1_data[i][j] = rand()%100;
	    output_data[i][j] = 0;
	  }




	int i,j,l;
	for(i  = 0; i < m; i++)
	{
		for(j = 0; j < n; j++)
		{
			output_data[i][j] = 0;
			for(l = 0; l < k; l++)
			{
				output_data[i][j] += input0_data[i][l] * input1_data[l][j];
			}
		}
	}	  

  
  char ip0[100],ip1[100],out[100];
  strcpy(ip0,input0_file_name.c_str());
  strcpy(ip1,input1_file_name.c_str());
  strcpy(out,output_file_name.c_str());

  
  write_data(ip0, input0_data, m, k);
  write_data(ip1, input1_data, k, n);
  write_data(out, output_data, m, n);

}


int main() {

  create_dataset(0, 16, 16, 16);
  create_dataset(1, 64, 48, 24);
  create_dataset(2, 93, 56, 120);
  create_dataset(3, 112, 32, 42);
  create_dataset(4, 48, 48, 94);
  create_dataset(5, 400, 300, 256);
  create_dataset(6, 256, 200, 128);
  create_dataset(7, 300, 100, 120);
  create_dataset(8, 32, 32, 32);
  create_dataset(9, 50, 35, 64);
  return 0;
}