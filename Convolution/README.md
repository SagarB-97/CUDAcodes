## Convolution
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
