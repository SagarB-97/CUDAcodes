## Vector Addition - Thrust Library
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

