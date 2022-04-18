% =========================================================================
% Main Function:
% - Pre-processing of codex data
% Guolan Lu, 11/24/21
% =========================================================================

% concentenate all the stacks into a hyperstack
% both the half size and full size montages will be saved
disp('Start concatenation...');
genHyperstack(reg_range, cyc_range, path_output, cyc_last, nCh,rowFinal,colFinal)
disp('Concatenation done...');
