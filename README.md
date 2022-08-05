
# RAPID: a Real-time, GPU-Accelerated Parallelized Image processing software for large-scale multiplexed fluorescence microscopy Data

RAPID deconvolves large-scale, high-dimensional fluorescence imaging data, stitches and registers images with axial and lateral drift correction, and minimizes tissue autofluorescence such as that introduced by erythrocytes.


## Step 1: Generate PSF for four filter channels following the ppt or use existing PSF file from PSF folder

Steps to create PSF.pptx\

- Use imageJ plugin PSF generator to generate 4 PSF for each filter:
http://bigwww.epfl.ch/algorithms/psfgenerator/ \
- Parameters:\
  - Keyence microscope: \
  - 20x objective, NA 0.75, Working distance = 350 um\
  - XY resolution(pixel size) = 377.442 nm; Z-step = 1500 nm\
  - Wavelength (nm; emission): input emission wavelength \
  - DAPI: 425; GFP: 525; Cy3: 595; Cy5: 670\
  - Image size/tile: 1920 x 1440\
  - Number of z planes\
  - Display: grays\
- Save the PSF to a path (path_psf) using the following names:\
  - PSF_BW_DAPI.tif\
  - PSF_BW_GFP.tif\
  - PSF_BW_Cy3.tif\
  - PSF_BW_Cy5.tif\


## Step 2: Install Matlab 2020a or newer version (include Image Processing Toolbox, Parallel Computing Toolbox, Signal Processing Toolbox, etc.)


## Step 3: Download  Fiji (https://imagej.net/software/fiji/) and install the "MIST" plugin

pluginpath = 'C:\Program Files\fiji-win64\Fiji.app\plugins\';\


## Step 4: Download and copy ij.jar and mij.jar to the following paths:

mjipath = 'C:\Program Files\MATLAB\R2021a\java\mij.jar';\
ijpath = 'C:\Program Files\MATLAB\R2021a\java\ij.jar';\


## Step 5: In time_benchmark.m file, change the following parameters:

 1. specify the directory of raw data: path_input\
 2. specify directory of processed data: path_output\
 3. specify directory of PSF: path_psf\
 4. specify path for using imageJ within matlab: mjipath, ijpath, pluginpath
 5. 



# codex-preprocess

Current dev AMI with latest dev version installed: [ami-0eed9af897571b732](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#ImageDetails:imageId=ami-0eed9af897571b732)
