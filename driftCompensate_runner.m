% =========================================================================
% Main Function:
% - Pre-processing of codex data
% Guolan Lu, 11/24/21
% Andrew J. Rech 1/21/22
% =========================================================================

% drift compensation: co-register all the cycles to the first cycle
disp('Start drift compensation...');
driftCompensate(reg_range,cyc_range,path_output,nCh,nTil,gpu_id);
disp('Drift compensation done...');
