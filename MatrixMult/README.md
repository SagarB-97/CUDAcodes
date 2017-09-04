## Matrix Multiplication
*Perform Matrix multiplication*
<br><br>

10 datasets were generated. Each dataset contains two input files and one expected output file.<br>
<br>
Input file  : `input-0-dataset_number.raw` and `input-1-dataset_number.raw`<br>
Output file : `output-dataset_number.raw`<br>

**Running the Program**
```
g++ dataset_gen.cpp
./a.out
nvcc q4.cu
./a.out output-dataset_number.raw input-0-dataset_number.raw input-1-dataset_number.raw
```
Replace *dataset_number* by an integer from 0-9

