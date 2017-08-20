### CO332 - Heterogenous Parallel Computing
# Assignment 2
```
Sagar Bharadwaj - 15CO141
Aneesh Aithal   - 15CO107
```
       
       
### Q1
*Performing vector addition using the **Thrust** library*     
<br>
10 datasets were generated on a single pair of input files called `input0.raw` and `input1.raw`.         
The expected output was stored in `output.raw`.         


**Running the program**
```
g++ dataset_generator.cpp
./a.out
nvcc q1.cu
./a.out output.raw input0.raw input1.raw
```

The final result can be stored in a separate file.            
To do so : `./a.out output.raw input0.raw input1.raw result.raw`

<br><br>
### Q2
*Blurring an image*<br><br>
A header file called `ppmHelper.h` was written for the purpose of reading and writing into .ppm files.        
Some new structures namely `PPMpixel`, `PPMimg`, `PPMpixelM` and `PPMimgM` are created. The purpose of each structure is mentioned as a comment.<br><br>
`wb.h` file was only used for reading Command line arguments.
<br><br>
Input File : `texture.ppm`<br>
Many sample outputs named `blur(X).ppm` are included in the archive. The number suffix indicates the value of the `BLUR_SIZE` used to 
generate the output. Higher the `BLUR_SIZE` more blurred is the imagex.<br>

**Running the program**
```
nvcc solution.cu
./a.out texture.ppm blurx.ppm
```

<br><br>
### Q3
*RGB image to **grayscale** image*.<br><br>
The same header file `ppmHelper.h` was used for reading and writing into a .ppm image file.
<br>
Input file  : `texture.ppm`<br>
Output file : `mono.ppm`<br><br>
**Running the Program**
```
nvcc solution.cu
./a.out texture.ppm mono.ppm
```

<br><br>
### Q4
*Matrix multiplication*
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

<br><br>
### Q5
*Tiled matrix multiplication*
<br><br>

The same dataset generator that was used in the previous question is used here.<br>
10 datasets were generated. Each dataset contains two input files and one expected output file.<br>
<br>
Input file  : `input-0-dataset_number.raw` and `input-1-dataset_number.raw`<br>
Output file : `output-dataset_number.raw`<br>
<br><br><br><br>
**Running the Program**
```
g++ dataset_gen.cpp
./a.out
nvcc q5.cu
./a.out output-dataset_number.raw input-0-dataset_number.raw input-1-dataset_number.raw
```
Replace *dataset_number* by an integer from 0-9




