## Optimized Matrix Multiplication
*Tiled matrix multiplication*
<br><br>

The same dataset generator that was used in the previous question is used here.<br>
10 datasets were generated. Each dataset contains two input files and one expected output file.<br>
<br>
Input file  : `input-0-dataset_number.raw` and `input-1-dataset_number.raw`<br>
Output file : `output-dataset_number.raw`<br>
<br><br>
**Running the Program**
```
g++ dataset_gen.cpp
./a.out
nvcc q5.cu
./a.out output-dataset_number.raw input-0-dataset_number.raw input-1-dataset_number.raw
```
Replace *dataset_number* by an integer from 0-9

