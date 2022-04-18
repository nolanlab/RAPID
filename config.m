% =========================================================================
% Confgiuration file for git-bash Amazon Web Services cloud pipeline; called from 
% - Pre-processing of codex data
% Guolan Lu, 11/24/21
% Andrew J. Rech 1/21/22
% =========================================================================

if ~exist('gpu_id','var') == 1
  gpu_id = 1;
end

% top-level data directory should be mounted to Y: by default if running in AWS
if ~exist('folder','var') == 1
  folder = 'experiment'; 
end
path_input=['Y:\', folder, '\'];
path_output=['Y:\', folder, '_out\'];
exposure_table=['Y:\', folder, '\', 'exposure_times.txt'];

% set commonly changed variables if they do not exist
if ~exist('nZ','var') == 1
  nZ = 9;
end
if ~exist('nTilRow','var') == 1
  nTilRow = 3;
end
if ~exist('nTilCol','var') == 1
  nTilCol = 3;
end
if ~exist('nTil','var') == 1
  nTil = 9;
end
til_range = 1:nTil;
if ~exist('im_row','var') == 1
  im_row = 1440;
end
if ~exist('im_col','var') == 1
  im_col = 1920;
end
if ~exist('nCh','var') == 1
  nCh = 1:4;
end
if ~exist('overlapRatio','var') == 1
  overlapRatio = 30;
end
if ~exist('neg_flag','var') == 1
  neg_flag = 1;
end
if ~exist('cyc_bg','var') == 1
  cyc_bg = 1;
end
if ~exist('mode','var') == 1
  mode = 'memopoint';
end

% set additional cloud image hard-coded paths
path_psf = 'C:\Program Files\codex-preprocess\PSF\PSF9\';
mjipath = 'C:\Program Files\MATLAB\R2021b\java\jar\mij.jar';
ijpath = 'C:\Program Files\MATLAB\R2021b\java\jar\ij.jar';
javaaddpath 'C:\Program Files\MATLAB\R2021b\java\jar\mij.jar'
javaaddpath 'C:\Program Files\MATLAB\R2021b\java\jar\ij.jar'
pluginpath = 'C:\Program Files\fiji-win64\Fiji.app\plugins\';

% detect exposure table
opts = detectImportOptions(exposure_table);
exposureTab = readtable(exposure_table, opts);
texp = table2array(exposureTab);