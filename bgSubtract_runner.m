% =========================================================================
% Main Function:
% - Pre-processing of codex data
% Guolan Lu, 11/24/21
% Andrew J. Rech 1/21/22
% =========================================================================

% subtract background cycle
disp('Start background subtraction...');
margin = 12;
rowFinal = im_row*nTilRow - im_row*overlapRatio/100*(nTilRow-1) + margin;
colFinal = im_col*nTilCol - im_col*overlapRatio/100*(nTilCol-1) + margin;
bgSubtract(reg_range,cyc_range,texp,cyc_bg,path_output,neg_flag,rowFinal,colFinal,nCh);
disp('Background subtraction done...');
