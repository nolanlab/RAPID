% =========================================================================
% Main Function:
% - Pre-processing of codex data
% Guolan Lu, 11/24/21
% Andrew J. Rech 12/04/21
% =========================================================================

disp('Start deconvolution...');
deconv(reg_range, cyc_range, til_range, nZ, path_input, path_output,path_psf,im_row,im_col,nCh,mode,gpu_id);
disp('Deconvolution done...');
