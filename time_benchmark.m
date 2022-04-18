% =========================================================================
% Main Function:
% - Pre-processing of codex data
% =========================================================================

function time = time_benchmark(reg_range)


tStart = tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up the following path
% specify the directory of raw data
path_input = 'C:\Users\Administrator\Desktop\codex-processing-pipeline-test-data-20211216\';

% specify directory of processed data
path_output = 'C:\Users\Administrator\Desktop\codex_processing_pipeline_test_data_20211216_processed\';

% specify directory of PSF
path_psf = 'C:\Users\Administrator\Desktop\Administrator\PSF\PSF6\';

% specify path for using imageJ within matlab
mjipath = 'C:\Program Files\MATLAB\R2021b\java\jar\mij.jar';
ijpath = 'C:\Program Files\MATLAB\R2021b\java\jar\ij.jar';
pluginpath = 'C:\Program Files\fiji-win64_Guolan\Fiji.app\plugins\';

%% Change the following parameters for each experiment
im_row = 1440; im_col = 1920; % define the image size of each tile; 20x

nCyc = 9; % number of cycles
% nReg = 4; % number of regions
nTil = 9; % number of tiles
nZ = 6; % number of z stacks
nCh = 1:4; % filter channels
nTilRow = 3; % number of row tiles
nTilCol = 3; % number of column tiles
overlapRatio = 30; % microscope overlapping ratio in precentage

% reg_range = 2; % the range of regions to process
cyc_range = 1:nCyc; % the range of cycles to process
til_range = 1:nTil; % the range of titles to process

nCPU = nCyc; % number of CPU workers to use for parallel computing
neg_flag = 1; % set to 1 means: make negative values after bg subtraction zeros
% gpu_id = 2;  % set the id of GPU as 1 or 2 (two GPUs in this computer)

% specify background cycle to subtract
cyc_bg = 1;

% detect exposure table
exposure_table=[path_input, '\', 'exposure_times.txt'];
opts = detectImportOptions(exposure_table);
exposureTab = readtable(exposure_table, opts);
texp = table2array(exposureTab);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Don't change the following code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parpool(nCPU)
%% Step 1:
%  - decovolution
%  - identify the best focus plane
% iter = 1
% without parallel GPU, elapsed time is 1769.505868 seconds.
% Elapsed time is 390.18458 seconds.
% Elapsed time is 136.085164 seconds.
% tic
disp('Start deconvolution...');
deconv_par(reg_range,cyc_range,til_range,nZ,path_input,path_output,path_psf,im_row,im_col,nCh,mode,1)
disp('Deconvolution done...');
% toc

%% stitch individual tiles
% Elapsed time is 627.905592 seconds.
% Elapsed time is 95.709612 seconds.
% Elapsed time is 102.968336 seconds.
% tic
if nTil >1
    disp('Start stitching...');
    MIST_stitch(mjipath,ijpath,pluginpath,path_output,reg_range,cyc_range,nTilCol,nTilRow,overlapRatio);
    makeMosaic(path_output,reg_range,cyc_range);
    disp('Stitching done...');
end
% toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 2:
% Elapsed time is 345.373967 seconds.
% Elapsed time is 272.271862 seconds.
% Elapsed time is 174.027829 seconds.
%  - drift compensation:
% tic
disp('Start drift compensation...');
driftCompensate_par(reg_range,cyc_range,path_output,nCh,nTil);
% driftCompensate(reg_range,cyc_range,path_output,nCPU,nCh,nTil);
% driftCompensateTest(reg_range,cyc_range,path_output,nCh,nTil);
% driftCompensateSingleTile(reg_range,cyc_range,path_output,nCPU,nCh,nTil);
disp('Drift compensation done...');
% toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Step 3:
% Elapsed time is 49.290314 seconds.
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
% bgSubtract(reg_range,cyc_range,texp,cyc_bg,path_output,neg_flag,nCPU,rowFinal,colFinal,nCh); % Elapsed time is 76.505625 seconds.
disp('Background subtraction done...');
% toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 4:
% concentenate all the stacks into a hyperstack
% tic
disp('Start concatenation...');
genHyperstack(reg_range, cyc_range, path_output,nCyc,nCh)
disp('Concatenation done...');
% toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delete(gcp('nocreate'));

time = toc(tStart);
