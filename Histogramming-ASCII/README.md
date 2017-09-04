## Histogram - ASCII
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
