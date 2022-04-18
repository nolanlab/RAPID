% =========================================================================
% Main Function:
% - Pre-processing of codex data
% Guolan Lu, 11/24/21
% Andrew J. Rech 1/21/22
% =========================================================================

%% stitch individual tiles (if more than 1 tiles are aquired)
if nTil >1
  disp('Start stitching...');
  MIST_stitch(mjipath,ijpath,pluginpath,path_output,reg_range,cyc_range,nTilCol,nTilRow,overlapRatio);
  makeMosaic(path_output,reg_range,cyc_range);
  disp('Stitching done...');
end
