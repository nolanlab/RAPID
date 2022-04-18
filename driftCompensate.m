% =========================================================================
% Guolan Lu, 9/3/21
% Pre-processing of codex data
% Input: raw codex images - selected from two multicycles
% Output: imagej hyperstack: x,y,zbest,channel, cycle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3:
% Per reg, drift compensation:
% - co-register all DAPI channels to the DAPI  of the first Cycle;
% - then apply the transformation to other channels
% =========================================================================

function driftCompensate_par(reg_range,cyc_range,path_input,nCh,nTil,gpu_id)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nCyc = 26;
% nReg = 43;
%path_input = 'X:\Guolan\test_deconvolution\multicycle_2020_09_preprocess\';

gpuDevice(gpu_id);

if nTil > 1
    filename_end = '_cycle1_montage.tif';
else
    filename_end = '_tile_1.tif';
end

%% load stitched image stack - dapi
% register all the cycles to the first cycle
% parpool(nCPU)

for ii = 1:length(reg_range)
    reg = reg_range(ii);

    disp(['Drift compensation: reg',num2str(reg),'...']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % load reference image: cycle 1 - dapi channel

    filename_ref = [path_input,'reg',num2str(reg),'\1_deconv_stitch\cycle1\reg',num2str(reg),filename_end];

    info = imfinfo(filename_ref);
    %     nCh = size(info,1);
    nx = info(1).Height;
    ny = info(1).Width;
    im_ref = imread(filename_ref,1);
    Rfixed = imref2d(size(im_ref));
    %     im_ch_ref = zeros(nx,ny,length(nCh)-1);
    %
    %     for iii = 2:length(nCh)
    %         ch = nCh(iii);
    %         im_ch_ref(:,:,iii-1) = imread(filename_ref,ch);
    %     end

    % creat a new folder for drift compensation
    if ~exist([path_input,'reg',num2str(reg),'\2_drift_compensate'], 'dir')
        mkdir([path_input,'reg',num2str(reg),'\2_drift_compensate'])
    end

    % copy cycle 1 data into the registered folder
    newfile = [path_input,'reg',num2str(reg),'\2_drift_compensate\reg',num2str(reg),'_cycle1_registered.tif'];

   % only one process can hold the lock on this copy operation
    % therefore if error, repeat with backoff

    % deal with bug where matlab does not handle file locks correctly across cores, processes when copying

    err_count = 0;
    while ~isfile(newfile)
        try
            copyfile(filename_ref, newfile);
        catch ME
            % if error due to held lock, wait and try again
            err_count = err_count + 10;
            pause(err_count)
            disp('file lock held by parallel process, re-trying...');
            ME = addCause(ME,causeException);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %============ co-registration using phase correlation ======================
    for jj = 1:length(cyc_range) % bugfix: allow cyc_range length == 1
        cyc = cyc_range(jj);

        % bugfix: allow cyc_range length == 1
        if cyc == 1
            continue
        end

        filename_reg = [path_input,'reg',num2str(reg),'\2_drift_compensate','\reg',num2str(reg),'_cycle',num2str(cyc),'_registered.tif'];
        if isfile(filename_reg)
            disp([filename_reg,' exists, skipping...']);
            continue
        end


        im_reg_stack = zeros(nx,ny,length(nCh));

        % --------------- estimate transform using dapi channel----------------
        % this file name needs to be changed to not include cycle info
        filename = [path_input,'reg',num2str(reg),'\1_deconv_stitch\cycle',num2str(cyc),'\reg',num2str(reg),'_cycle',num2str(cyc),'_montage.tif'];
        %         info = imfinfo(filename);
        %         nCh   = size(info,1);
        im_dapi = imread(filename,1);
        %     figure,imshowpair(im_ref,im_dapi,'falsecolor');
        tform = imregcorr(im2single(im_dapi),im2single(im_ref));

        % ---------------------co-register all channels----------------------
        im_reg_stack(:,:,1) = imwarp(gpuArray(im_dapi),tform,'OutputView',Rfixed);

        for jjj = 2:length(nCh)
            ch = jjj;
            im_ch = imread(filename,ch);
            im_reg_stack(:,:,jjj) = imwarp(gpuArray(im_ch),tform,'OutputView',Rfixed);
            %     figure,imshowpair(im_ref,im_dapi_reg,'falsecolor');title('phase correlation');
        end
        
        BitsPerSample = 32;

        WriteTifStack(gather(im_reg_stack), filename_reg, BitsPerSample);
    end

end
% shut down the parallel pool.
% delete(gcp('nocreate'));

end
