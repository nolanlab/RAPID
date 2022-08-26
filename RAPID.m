% Example to run RAPID
% Guolan Lu, Aug 2022

clear all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up the following path
% specify the directory of raw data
path_input = 'Z:\admin\Guolan\codex-processing-pipeline-test-data-20211216\';

% specify directory of processed data
path_output = 'X:\Guolan\time_benchmark\new_uploader\codex_processing_pipeline_test_data_20211216_processed\';

% specify directory of PSF
path_psf = 'C:\Users\Guolan\Desktop\Guolan\PSF\PSF6\';

% specify path for using imageJ within matlab
mjipath = 'C:\Program Files\MATLAB\R2021a\java\mij.jar';
ijpath = 'C:\Program Files\MATLAB\R2021a\java\ij.jar';
pluginpath = 'C:\Program Files\fiji-win64_Guolan\Fiji.app\plugins\';

%% Change the following parameters for each experiment
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Don't change the following code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parpool(cpu_num)
% ------------------------------------------------------------------------
%% Module 1:
%  - decovolution
%  - identify the best focus plane
% tic
disp('Start deconvolution...');
deconv_par(reg_range, cyc_range, til_range, nZ, path_input, path_output, path_psf,im_row,im_col,nCh,mode)
disp('Deconvolution done...');
% toc

% ------------------------------------------------------------------------
%% stitch individual tiles: lateral drift compensation
% tic
if nTil >1
    disp('Start stitching...');
   
    MIST_stitch(mjipath,ijpath,pluginpath,path_output,reg_range,cyc_range,nTilCol,nTilRow,overlapRatio);

    makeMosaic(path_output,reg_range,cyc_range);
    
    disp('Stitching done...');
end
% toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Module 2:
% ------------------------------------------------------------------------
%  - axial drift compensation:
% tic
disp('Start drift compensation...');
driftCompensate_par(reg_range,cyc_range,path_output,nCh,nTil);
% driftCompensate(reg_range,cyc_range,path_output,cpu_num,nCh,nTil);
disp('Drift compensation done...');
% toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Module 3:
% -------------------------------------------------------------------------
% subtract background cycle
% tic
disp('Start background subtraction...');
if nTil>1
    margin = 12;
elseif nTil == 1
    margin = 0;
end
rowFinal = im_row*nTilRow - im_row*(overlapRatio/100)*(nTilRow-1) + margin;
colFinal = im_col*nTilCol - im_col*(overlapRatio/100)*(nTilCol-1) + margin;

bgSubtract_par(reg_range,cyc_range,texp,cyc_bg,path_output,neg_flag,rowFinal,colFinal,nCh);
% bgSubtract(reg_range,cyc_range,texp,cyc_bg,path_output,neg_flag,cpu_num,rowFinal,colFinal,nCh); % Elapsed time is 76.505625 seconds.
% bgSubtractRBC(reg_range,cyc_range,texp,cyc_bg,path_output,neg_flag,cpu_num,rowFinal,colFinal,nCh); % remove strong autofluorescence

disp('Background subtraction done...');
% toc


% ------------------------------------------------------------------------
%% concentenate all the stacks into a hyperstack
% tic
disp('Start concatenation...');
genHyperstack(reg_range, cyc_range, path_output,nCyc,nCh)
disp('Concatenation done...');
% toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delete(gcp('nocreate'));


