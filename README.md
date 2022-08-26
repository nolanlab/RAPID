
## RAPID: a Real-time, GPU-Accelerated Parallelized Image processing software for large-scale multiplexed fluorescence microscopy Data

RAPID deconvolves large-scale, high-dimensional fluorescence imaging data, stitches and registers images with axial and lateral drift correction, and minimizes tissue autofluorescence such as that introduced by erythrocytes.


### Step 1: Generate point-spread functions (PSF) 
#### 1. Download ImageJ plugin PSF generator (http://bigwww.epfl.ch/algorithms/psfgenerator/) and save it to your Fiji plugin path:

- Example: pluginpath = 'C:\Program Files\fiji-win64\Fiji.app\plugins\';

<img width="573" alt="PSFdownload" src="https://user-images.githubusercontent.com/57729689/186963592-2096e0ed-58cd-4482-93e9-54e2e005b945.PNG">


#### 2. Run PSF generator in ImageJ generate 4 PSF images for the 4 filters:

![PSF1](https://user-images.githubusercontent.com/57729689/186960115-27356994-f256-4923-88e6-3ef0543180e5.JPG)

* Examples of parameter settings using Keyence microscope for CODEX imaging:
  - 20x objective, NA 0.75, Working distance = 350 um
  - XY resolution(pixel size) = 377.442 nm; Z-step = 1500 nm
  - Wavelength (nm; emission): input emission wavelength: DAPI: 425; GFP: 525; Cy3: 595; Cy5: 670 
  - Image size per tile: 1920 x 1440
  - Number of z planes
  - Display: grays
  - Save the PSF to a path (path_psf) using the following names: \
  &nbsp;- PSF_BW_DAPI.tif\
  &nbsp;- PSF_BW_GFP.tif\
  &nbsp;- PSF_BW_Cy3.tif\
  &nbsp;- PSF_BW_Cy5.tif


### Step 2: Install Matlab 2020a or newer version 

#### 1. During installation during, include Image Processing Toolbox, Parallel Computing Toolbox, Signal Processing Toolbox, etc. 

#### 2. After installation, increase java heap memory as shown below:

![java heap memory](https://user-images.githubusercontent.com/57729689/186957714-362bf4af-e3bc-4ee3-835b-caa0772cdb76.png)


### Step 3: Download  Fiji (https://imagej.net/software/fiji/) and install the "MIST" plugin

![MIST](https://user-images.githubusercontent.com/57729689/186963300-81cd3657-0c40-4d8c-96f8-240fe1ca5419.JPG)


### Step 4: Running ImageJ and Fiji within Matlab
(Reference: https://www.mathworks.com/matlabcentral/fileexchange/47545-mij-running-imagej-and-fiji-within-matlab)
#### Download ij.jar and mij.jar from this github site and copy them to the following paths:

- mjipath = 'C:\Program Files\MATLAB\R2021a\java\mij.jar';
- ijpath = 'C:\Program Files\MATLAB\R2021a\java\ij.jar';


### Step 5: In RAPID.m file, change the following parameters:

 1. specify the directory of raw data: path_input
 2. specify directory of processed data: path_output
 3. specify directory of PSF: path_psf
 4. specify path for using imageJ within matlab: mjipath, ijpath, pluginpath
 5. Specify image size, number of cycles, regions, tiles, z stacks, filter channels, number of row and column tiles, overlapratio, region range, cycle range, tile range, etc.
 7. Define exposure time
 8. Define image acquisition mode: memopoint or multipoint

### Step 6: Hit "Run" to process CODEX data using RAPID
#### 1. RAPID consists of 3 main modules: 
1. 3D deconvolution and tile stitching (lateral drift correction)
2. Axial drift correction
3. Background subtraction and concatenation of all the images into a hyperstack
- Note: imageJ will be running for image stitching and concatenation step. Do not interrupt it while it is running.

#### 2. The output images of each module are saved in three seperate folders for each tissue region. This allows user to check the quality of output images after each step.

![folders](https://user-images.githubusercontent.com/57729689/186965845-d3ce3eb9-4b81-480b-b56b-a9bef14c4200.JPG)



# codex-preprocess

Current dev AMI with latest dev version installed: [ami-0eed9af897571b732](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#ImageDetails:imageId=ami-0eed9af897571b732)
