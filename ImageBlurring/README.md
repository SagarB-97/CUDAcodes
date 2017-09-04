## Image Blur
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
