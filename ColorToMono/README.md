## Color to Mono
*RGB image to **grayscale** image*.<br><br>
Header file `ppmHelper.h` was used for reading and writing into a .ppm image file.<br>
Some new structures namely `PPMpixel`, `PPMimg`, `PPMpixelM` and `PPMimgM` are created. The purpose of each structure is mentioned as a comment.<br>
<br>
Input file  : `texture.ppm`<br>
Output file : `mono.ppm`<br><br>
**Running the Program**
```
nvcc solution.cu
./a.out texture.ppm mono.ppm
```
