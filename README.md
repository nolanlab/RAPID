
## RAPID: a Real-time, GPU-Accelerated Parallelized Image processing software for large-scale multiplexed fluorescence microscopy Data

### Reference:
Lu G, Baertsch MA, Hickey JW, Goltsev Y, Rech AJ, Mani L, Forgó E, Kong C, Jiang S, Nolan GP, Rosenthal EL. A real-time GPU-accelerated parallelized image processor for large-scale multiplexed fluorescence microscopy data. Front Immunol. 2022 Sep 23;13:981825. doi: 10.3389/fimmu.2022.981825. PMID: 36211386; PMCID: PMC9539451.

### Overview:
RAPID deconvolves large-scale, high-dimensional fluorescence imaging data, stitches and registers images with axial and lateral drift correction, and minimizes tissue autofluorescence such as that introduced by erythrocytes.
<br/>

### Prerequisites
- Processing computer
- Matlab
- Fiji
- Download RAPID

<br/>

### Installation & Running the Programs:

### Step 1: Install Matlab 2020a or newer version 

#### 1. During installation during, include Image Processing Toolbox, Parallel Computing Toolbox, Signal Processing Toolbox, etc. 

#### 2. After installation, increase java heap memory as shown below:

![java heap memory](https://user-images.githubusercontent.com/57729689/186957714-362bf4af-e3bc-4ee3-835b-caa0772cdb76.png)

<br/>


### Step 2: Download  Fiji (https://imagej.net/software/fiji/) and install the "MIST" plugin

![MIST](https://user-images.githubusercontent.com/57729689/186963300-81cd3657-0c40-4d8c-96f8-240fe1ca5419.JPG)

<br/>


### Step 3: Generate point-spread functions (PSF) 
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
<br/>

### Step 4: Running ImageJ and Fiji within Matlab
(Reference: https://www.mathworks.com/matlabcentral/fileexchange/47545-mij-running-imagej-and-fiji-within-matlab)
#### Download ij.jar and mij.jar from this github site and copy them to the following paths:

- mjipath = 'C:\Program Files\MATLAB\R2021a\java\mij.jar';
- ijpath = 'C:\Program Files\MATLAB\R2021a\java\ij.jar';
<br/>

### Step 5: In RAPID.m file, change the following parameters:

 1. specify the directory of raw data: path_input
 2. specify directory of processed data: path_output
 3. specify directory of PSF: path_psf
 4. specify path for using imageJ within matlab: mjipath, ijpath, pluginpath
 5. Specify image size, number of cycles, regions, tiles, z stacks, filter channels, number of row and column tiles, overlapratio, region range, cycle range, tile range, etc.
 7. Define exposure time
 8. Define image acquisition mode: memopoint or multipoint

See examples below:
```
%% set up the following path
% -------------------------------------------------------------------
% specify the directory of raw data
path_input = 'Z:\Guolan\codex_test_data_raw\';

% specify directory of processed data
path_output = 'Z:\Guolan\codex_test_data__processed\';

% specify directory of PSF
path_psf = 'C:\Guolan\PSF\PSF6\';

% specify path for using imageJ within matlab
mjipath = 'C:\Program Files\MATLAB\R2021a\java\mij.jar';
ijpath = 'C:\Program Files\MATLAB\R2021a\java\ij.jar';
pluginpath = 'C:\Program Files\fiji-win64_Guolan\Fiji.app\plugins\';

%% Change the following parameters for each experiment
% -------------------------------------------------------------------
im_row = 1440; im_col = 1920; % define the image size of each tile; 20x

nCyc = 9; % number of cycles
nReg = 4; % number of regions
nTil = 9; % number of tiles
nZ = 6; % number of z stacks
nCh = 1:4; % filter channels
nTilRow = 3; % number of row tiles
nTilCol = 3; % number of column tiles
overlapRatio = 30; % microscope overlapping ratio in precentage

reg_range = 2; % the range of regions to process
cyc_range = 1:nCyc; % the range of cycles to process

til_range = 1:nTil; % the range of titles to process

cpu_num = nCyc; % number of CPU workers to use for parallel computing
neg_flag = 1; % set to 1 means: make negative values after bg subtraction zeros
% gpu_id = 2;  % set the id of GPU as 1 or 2 (two GPUs in this computer)

% specify background cycle to subtract
cyc_bg = 1;

% exposure time table
texp = [1,6.667,500.000,500.000,500.000
    2,6.667,200.000,333.333,250.000
    3,6.667,117.647,500.000,200.000
    4,6.667,66.667,250.000,500.000
    5,6.667,1.667,500.000,500.000
    6,6.667,1.667,250.000,250.000
    7,6.667,1.667,117.647,166.667
    8,6.667,1.667,117.647,200.000
    9,6.667,1.667,500.000,133.333];

% image acquisition mode: multipoint or memopoint
mode = 'memopoint';

```
<br/>

### Step 6: Hit "Run" to process CODEX data using RAPID
#### 1. RAPID consists of 3 main modules: 
(1) 3D deconvolution and axial drift compensation

(2) within-cycle and betwee-cycle lateral drift compensation

(3) Background subtraction and concatenation of all the images into a hyperstack
- Note: imageJ will be running for image stitching and concatenation step. Do not interrupt it while it is running.


#### 2. The input file format for Keyence experiment contains the following format:
(1) For Keyence - memopoint mode, the input format and structure is:
- cyc001_reg001
  - 1.bcf
  - 1_00001_Z001_CH1.tif
  - 1_00001_Z001_CH2.tif
  - 1_00001_Z001_CH3.tif
  - 1_00001_Z001_CH4.tif
  - .....
  - 1_00009_Z006_CH1.tif
  - 1_00009_Z006_CH2.tif
  - 1_00009_Z006_CH3.tif
  - 1_00009_Z006_CH4.tif

<img width="283" alt="input-memo" src="https://user-images.githubusercontent.com/57729689/187006381-9b6ef337-849d-4277-be88-bebde8718680.PNG">

(2) For Keyence - multipoint mode, the input format and structure is:
- cyc001_reg001
  - XY01
    - 1_XY01.bcf
    - 1_XY01_00001_Z001_CH1.tif
    - 1_XY01_00001_Z001_CH2.tif
    - 1_XY01_00001_Z001_CH3.tif
    - 1_XY01_00001_Z001_CH4.tif

<img width="353" alt="input-multipoint" src="https://user-images.githubusercontent.com/57729689/187006384-780a8c07-a5ee-4529-9e13-78372c837185.PNG">


#### 3. The output images of each module are saved in three seperate folders for each tissue region. This allows user to check the quality of output images after each step.

![folders](https://user-images.githubusercontent.com/57729689/186965845-d3ce3eb9-4b81-480b-b56b-a9bef14c4200.JPG)

<br/>

### Step 7: Additional module to improve marker detection by reducing intense tissue autofluorescence from images such as those from red blood cells (RBC)
#### 1. Run RBCRemoval.m to generate binary masks for RBC contaminated pixels
#### 2. In RAPID.m, run bgSubtractRBC instead of bgSubtract to set the intensity of RBC contaminated pixels to zero
<br/><br/>

## Instructions for Making Modifications:
1. For CODEX users, if you are using a different microscope than Keyence BZX-700, please change the image directory and name accordingly
2. For different imaging settings (image size, NA, wavelength, z-step, etc.), you need to generate new PSF images following the above instructions.
3. For other multiplexed imaging technologies, if there is no z-stack, you can skip the deconvolution and start from image stitching step.

<br/><br/><br/>

# Instructions for Cloud Deployment

## Steps to reproduce Windows AMI 635198895848/codex-preprocess-1.0.0, [ami-xxx](link)

Following this guide is only required to re-create a CODEX analysis server from a base Windows 2019 server image. The Amazon Machine image described in the README is preconfigured for CODEX processing.

### Base Amazon Machine Image

The base Amazon Machine Image used is the latest official `Microsoft Windows Server 2019 with NVIDIA Tesla Driver` image, described [here](https://aws.amazon.com/marketplace/pp/prodview-jrxucanuabmfm).

### Security

For security, we rely on incoming connection restriction at the AWS Security Group level. Under `Server Management`, disable for all regions:

* Windows Defender Firewall
* IE Enhanced Security Configuration
* Windows Defender Antivirus

### Install tools and dependencies

* install pipeline dependencies
  * (_NVIDIA Tesla drivers compatible with G5 instances are pre-installed_)
  * [CUDA (latest 11.x)](https://developer.nvidia.com/cuda-downloads)
  * [Matlab 2021b](https://www.mathworks.com/downloads)
    * _additional toolboxes_
      * Simulink
      * Bioinformatics
      * Computer Vision
      * Databse
      * Deep learning
      * GPU Coder
      * Image Aquisition
      * Image Processing
      * Matlab Coder
      * Matlab Compiler
      * Optimization
      * Parallel Computing
      * Spreadsheet link
      * Statistics and Machine learning
  * [ImageJ (pinned, custom version)](https://s3.amazonaws.com/get.rech.io/fiji-win64.zip), extracted to `\C:\Program Files`.
* install dependencies for parallelization and mounting remote file storage
  * [git bash (latest)](https://gitforwindows.org/), used to run Unix pipeline tools on Windows
  * [GNU Parallel](https://www.gnu.org/software/parallel/) via git bash
  * [rclone (latest)](https://github.com/rclone/rclone), used to mount remote storage to the instance `Y:\` drive to avoid copying files over the network in bulk
  * [WinFSP (latest)](https://github.com/billziss-gh/winfsp), an `rclone` dependency

You will be required to activate Matlab using your own license and configure access via rclone to input data.

### Install optional tools

* [mysys2](https://www.msys2.org/), used for Unix shell emulation
* AWS command line interface
* Google Chrome
* VS Code

#### Download latest stable copy of source code

Finally, [download](https://github.com/andrewrech/codex-preprocess/releases) this repository and extract to `\C:\Program Files\codex-preprocess`. Then move the two `*.jar` files in the source code top level directory to the Matlab jar folder as described in the README.

Current dev AMI with latest dev version installed: [ami-0eed9af897571b732](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#ImageDetails:imageId=ami-0eed9af897571b732)
