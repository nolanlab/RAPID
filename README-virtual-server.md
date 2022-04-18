# Steps to reproduce Windows AMI 635198895848/codex-preprocess-1.0.0, [ami-xxx](link)

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
* AWS comand line interface
* Google Chrome
* VS Code

### Download latest stable copy of source code

Finally, [download](https://github.com/andrewrech/codex-preprocess/releases) this repository and extract to `\C:\Program Files\codex-preprocess`. Then move the two `*.jar` files in the source code top level directory to the Matlab jar folder as described in the README.
