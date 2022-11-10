% =========================================================================
% Guolan Lu, 9/3/21
% Pre-processing of codex data
% Input: raw codex images - selected from two multicycles
% Output: imagej hyperstack: x,y,zbest,channel, cycle
% per region, per cycle, generate individual tiles (4 channels/tile)
%  - decovolution
%  - identify the best focus plane
% rename tiles for stitching
% =========================================================================
function deconv_par(reg_range,cyc_range,til_range,nZ,path_input,path_output,path_psf,im_row,im_col,nCh,mode,gpu_id)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nCh = 4;
PSF = cell(4,1);
% path_psf = ['E:\GL Projects\4. Codex\Preprocessing\PSF',num2str(nZ),'\'];
PSF{1} = ReadTifStack([path_psf,'PSF_BW_DAPI.tif']);
PSF{2} = ReadTifStack([path_psf,'PSF_BW_GFP.tif']);
PSF{3} = ReadTifStack([path_psf,'PSF_BW_Cy3.tif']);
PSF{4} = ReadTifStack([path_psf,'PSF_BW_Cy5.tif']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1:length(reg_range)
    reg = reg_range(ii);
    disp(['Deconvolution: reg',num2str(reg),'...']);

    if ~exist([path_output,'reg',num2str(reg)], 'dir')
        mkdir([path_output,'reg',num2str(reg)])
        mkdir([path_output,'reg',num2str(reg)],'\1_deconv_stitch')
    end

    for jj = 1:length(cyc_range)
        cyc = cyc_range(jj);

        % check for existence of output directory
        % and continue if none exists
        if strcmp(mode,'memopoint')
            im_folder_name = [path_input,'Cyc',num2str(cyc,'%03.f'),'_reg',num2str(reg,'%03.f')];
            im_folder_name_alt = [path_input,'Cyc',num2str(cyc,'%01.f'),'_reg',num2str(reg,'%01.f')];
        elseif strcmp(mode,'multipoint')
            im_folder_name = [path_input,'Cyc',num2str(cyc,'%03.f'),'_reg',num2str(1,'%03.f')];
            im_folder_name_alt = [path_input,'Cyc',num2str(cyc,'%01.f'),'_reg',num2str(1,'%01.f')];
        end 
            
        if ~isdir(im_folder_name) && ~isdir(im_folder_name_alt)
            disp([path_input, ' cycle ',num2str(cyc,'%03.f'),' reg ',num2str(reg,'%03.f'), ' does not exist, skipping...'])
            continue
        end

        % suppress meaningless warning about uninitialized temporary variables under parlor
        warning('off')
        % check for existence of .bcf file
        % and continue if none exists
        if strcmp(mode,'memopoint')
            im_file_bcf = [path_input,'Cyc',num2str(cyc,'%03.f'),'_reg',num2str(reg,'%03.f'),'\',num2str(reg),'.bcf'];
            im_file_bcf_alt = [path_input,'Cyc',num2str(cyc),'_reg',num2str(reg),'\',num2str(reg),'.bcf'];
        elseif strcmp(mode,'multipoint')
            im_file_bcf = [path_input,'Cyc',num2str(cyc,'%03.f'),'_reg001\XY',num2str(reg,'%02.f'),'\1_XY',num2str(reg,'%02.f'),'.bcf'];
            im_file_bcf_alt = [path_input,'Cyc',num2str(cyc),'_reg1\XY',num2str(reg,'%02.f'),'\1_XY',num2str(reg,'%02.f'),'.bcf'];
        end

        if ~isfile(im_file_bcf) && ~isfile(im_file_bcf_alt)
            disp('bcf file does not exist, skipping...')
            continue
        end
        warning('on')


        if ~exist([path_output,'reg',num2str(reg),'\1_deconv_stitch\cycle',num2str(cyc)], 'dir')
            mkdir([path_output,'reg',num2str(reg),'\1_deconv_stitch\cycle',num2str(cyc)])
        end

        for kk = 1:length(til_range)

            til = til_range(kk);

            filename_bestz = [path_output,'reg',num2str(reg),'\1_deconv_stitch\cycle',num2str(cyc),'\reg',num2str(reg),'_tile_',num2str(til),'.tif'];

            % skip to next iteration of loop if the file already exists
            if isfile(filename_bestz)
              disp([filename_bestz, ' exists, skipping...'])
                disp('Output exists, next...')
                continue
            end

            im_stack_bestz = zeros(im_row,im_col,length(nCh));% define the best z of the current tile for all channels

            for tt = 1:length(nCh)
                ch = nCh(tt);
                im_stack = zeros(im_row,im_col,nZ); % define a z stack for current tile & channel
                im_name = [];
                im_name_alt = [];
                for z = 1:nZ
                    %----------------------- load image--------------------
                    if strcmp(mode,'memopoint')
                        im_name = [path_input,'Cyc',num2str(cyc),'_reg',num2str(reg),'\',num2str(reg),'_',num2str(til,'%05.f'),'_Z',num2str(z,'%03.f'),'_CH',num2str(ch),'.tif'];
                        im_name_alt = [path_input,'Cyc',num2str(cyc,'%03.f'),'_reg',num2str(reg,'%03.f'),'\',num2str(reg),'_',num2str(til,'%05.f'),'_Z',num2str(z,'%03.f'),'_CH',num2str(ch),'.tif'];

                        if ~isfile(im_name) && ~isfile(im_name_alt)
                            disp(['input image file ', im_name, ' or ', im_name_alt, ' does not exist, skipping...'])
                            continue
                        end

                        if ~isfile(im_name) && isfile(im_name_alt)
                          im_name = im_name_alt;
                        end

                    elseif strcmp(mode,'multipoint')
                        im_name = [path_input,'Cyc',num2str(cyc),'_reg1\XY',num2str(reg,'%02.f'),'\1_XY',num2str(reg,'%02.f'),'_0000',num2str(til),'_Z',num2str(z,'%03.f'),'_CH',num2str(ch),'.tif'];
                    end
                    im_stack(:,:,z) = imread(im_name);
                end

                stackIn = single(im_stack);
                [Sx, Sy, Sz] = size(stackIn);

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %         disp('Preprocessing forward and back projectors ...');
                proMode = 1; % 0 for CPU; 1 for GPU
                gpuFlag = 0;
                if(proMode==1)
                    gpuFlag = 1;% 0: CPU; 1: GPU
                    gpuDevice(gpu_id);
                end

                %------------------ forward projector: PSF-------------
                PSFIn = single (PSF{ch});
                PSF1 = PSFIn/sum(PSFIn(:));

                %----------- back projector: PSF_bp--------------------
                % parameters: light sheet microscopy as an example
                bp_type = 'wiener-butterworth';
                alpha = 0.05;
                %             beta = 1;
                beta = 0.1;
                n = 20;
                resFlag = 1;
                iRes = [2.44,2.44,10];
                verboseFlag = 0;
                [PSF2, ~] = BackProjector(PSF1, bp_type, alpha, beta, n, resFlag, iRes, verboseFlag);
                PSF2 = PSF2/sum(PSF2(:));

                % ---------------run deconvolution-----------------
                % set initialization of the deconvolution
                flagConstInitial = 0; % 1: constant mean; 0: input image

                % % % deconvolution
                PSF_fp = align_size(PSF1, Sx,Sy,Sz);
                PSF_bp = align_size(PSF2, Sx,Sy,Sz);
                if(gpuFlag)
                    OTF_fp = fftn(ifftshift(gpuArray(single(PSF_fp))));
                    OTF_bp = fftn(ifftshift(gpuArray(single(PSF_bp))));
                else
                    OTF_fp = fftn(ifftshift(PSF_fp));
                    OTF_bp = fftn(ifftshift(PSF_bp));
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% decovolution
                smallValue = 0.001;

                if(gpuFlag)
                    stack = gpuArray(single(stackIn));
                else
                    stack = stackIn;
                end
                stack = max(stack,smallValue);
                if(flagConstInitial==1)
                    stackEstimate = ones(Sx, Sy, Sz)*mean(stack(:)); % constant initialization
                else
                    stackEstimate = stack; % Measured image as initialization
                end

                itNum = 1; % iteration number
                for it = 1:itNum
                    stackEstimate = stackEstimate.*ConvFFT3_S(stack./...
                        ConvFFT3_S(stackEstimate, OTF_fp),OTF_bp);
                    stackEstimate = max(stackEstimate,smallValue);
                end
                if(gpuFlag)
                    output = gather(stackEstimate);
                else
                    output = stackEstimate;
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% identify the best focus plane using DAPI channel
                %                 if ch == 1
                FM = zeros(1,nZ);
                for z = 1:nZ
                    %--------calculate focus measure of current image------
                    FM(z) = fmeasure(output(:,:,z), 'LAPV');
                end
                [~,idxz] = max(FM);
                %                 end
                im_stack_bestz(:,:,tt) = output(:,:,idxz);% best z plane of the current tile
            end

            %     im_bestz{til} = im_stack_bestz;
            % write each tile as an image stack of 4 channel images; name them
            BitsPerSample = 32;
            WriteTifStack(im_stack_bestz, filename_bestz, BitsPerSample);
        end
    end


end
% delete(gcp('nocreate'));

end
