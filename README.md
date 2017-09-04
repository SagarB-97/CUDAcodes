### Heterogenous Parallel Computing
```
Sagar Bharadwaj
Aneesh Aithal
```
       
       
### Vector Addition - Thrust Library
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
### Image Blur
*Blurring an image*<br><br>
A header file called `ppmHelper.h` was written for the purpose of reading and writing into .ppm files.        
Some new structures namely `PPMpixel`, `PPMimg`, `PPMpixelM` and `PPMimgM` are created. The purpose of each structure is mentioned as a comment.<br><br>
`wb.h` file was only used for reading Command line arguments.
<br><br>
Input File : `texture.ppm`<br>
Many sample outputs named `blur(X).ppm` are included in the archive. The number suffix indicates the value of the `BLUR_SIZE` used to 
generate the output. Higher the `BLUR_SIZE` more blurred is the image.<br>

**Running the program**
```
nvcc solution.cu
./a.out texture.ppm blurx.ppm
```

<br><br>
### Color to Mono
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
### Matrix Multiplication
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

<br><br>
### Optimized Matrix Multiplication
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

<br><br>
### Histogram - Numbers
*Histogram - Integers*
<br><br>
`input.raw` and `output.raw` are created using `dataset_generator.cpp`
<br><br>
**Running the program**
```
g++ dataset_generator.cpp
./a.out
nvcc solution.cu
./a.out ouput.raw input.raw
```


<br><br>
### Histogram - ASCII
*Histogram - ASCII characters*
<br><br>
`input.txt` and `expected_out.raw` are created using `dataset_generator.cpp`

**Running the program**
```
g++ dataset_generator.cpp
./a.out
nvcc solution.cu
./a.out expected_output.raw input.txt output.raw
```

The output generated can be stored in a separate file as shown above (`output.raw`); 

<br><br>
### Histogram sort (Thrust)
*Thrust Histogram Sort*
<br><br>
`input.raw` and `output.raw` are created using `dataset_generator.cpp`.
<br><br>
**Running the Program**
```
g++ dataset_generator.cpp
./a.out
nvcc solution.cu
./a.out ouput.raw input.raw
```

<br><br>
### Convolution
*Convoltuion*
<br><br>
`input_0.ppm` contains the input image/matrix and `input_1.raw` is the mask. `output.ppm` is the expected output.
<br><br>
**Running the Program**
```
g++ dataset_generator.cpp
./.a.out
nvcc solution.cu
./a.out output.ppm input_0.ppm input_1.raw
```

<br><br>
### Stencil-Tiling
*7 point stencil*
<br><br>
3D matrices of varying sizes were created by using `dataset_generator.cpp`.

**Running the Program**
```
g++ dataset_gen.cpp
./a.out
nvcc solution.cu
./a.out input.ppm expected_output.ppm
```




