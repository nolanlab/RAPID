
# RAPID: a Real-time, GPU-Accelerated Parallelized Image processing software for large-scale multiplexed fluorescence microscopy Data

RAPID deconvolves large-scale, high-dimensional fluorescence imaging data, stitches and registers images with axial and lateral drift correction, and minimizes tissue autofluorescence such as that introduced by erythrocytes.


Step 1: Generate PSF for four filter channels following the ppt

Use imageJ plugin PSF generator to generate 4 PSF for each filter:
http://bigwww.epfl.ch/algorithms/psfgenerator/ \\
Parameters:
Keyence microscope: 
20x objective, NA 0.75, Working distance = 350 um
XY resolution(pixel size) = 377.442 nm; Z-step = 1500 nm
Wavelength (nm; emission): input emission wavelength 
DAPI: 425; GFP: 525; Cy3: 595; Cy5: 670
Image size/tile: 1920 x 1440
Number of z planes
Display: grays
Save the PSF as the following names:
PSF_BW_DAPI.tif
PSF_BW_GFP.tif
PSF_BW_Cy3.tif
PSF_BW_Cy5.tif

Step 2: 

# codex-preprocess

Current dev AMI with latest dev version installed: [ami-0eed9af897571b732](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#ImageDetails:imageId=ami-0eed9af897571b732)
