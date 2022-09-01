% test remove erythrocyte background
clear all
clc

addpath(genpath('C:\Users\Guolan\matlab_code\altmany-export_fig-e4117f8'));

filefolder = 'Y:\HNSCC\RAPID\';
nReg = 10; % number of regions
ch = 3;

for i = 1:length(nReg)
    for reg = 1:nReg(i)
        filename = [filefolder,'reg',num2str(reg),'\1_deconv_stitch\cycle1\reg',num2str(reg),'_tile_1.tif'];
        
        im = imread(filename,ch);
        imnorm =(im-min(im(:)))/(max(im(:))-min(im(:)));
        %             figure,imshow(imnorm,[])
        
        % ----------------------------------------------------------------
        %% image enhancement
        I_eq = adapthisteq(imnorm);
        %             figure,imshow(I_eq,[]);
        
        % ----------------------------------------------------------------
        %% Otsu's thresholding
        bw0 = imbinarize(I_eq, graythresh(I_eq));
        
        % ----------------------------------------------------------------
        %% Remove noise
        bw = bwareaopen(bw0, 10);
        
        se = strel('disk',1);
        bw = imdilate(bw,se);
        
        % ----------------------------------------------------------------
        %% identify regions with mean intensity >= 65535*0.3
        % raw_name = [filefolder,'reg',num2str(reg),'\1_deconv_stitch\cycle1\reg',num2str(reg),'_tile_1.tif'];
        % im = imread(raw_name,ch);
        
        stats = regionprops(bw,im,'MeanIntensity','PixelIdxList');
        av_int = [stats.MeanIntensity];
        idx = find(av_int < 65535*0.25);
        
        pixel_idx = cat(1,stats(idx).PixelIdxList);
        mask = bw;
        mask(pixel_idx) = 0;
        
        %% remove fluorescent myeloid cells by nuclear staining
        im_hchst = imread(filename,1);
        %     figure,imshow(im_hchst,[])
        %     figure,histogram(im_hchst(:))
        stats1 = regionprops(bw,im_hchst,'MeanIntensity','PixelIdxList');
        av_int1 = [stats1.MeanIntensity];
        
        %     [min(av_int1),max(av_int1),mean(av_int1)]
        
        idx1 = find(av_int1 > 20000);
        
        pixel_idx1 = cat(1,stats1(idx1).PixelIdxList);
        mask_final = mask;
        mask_final(pixel_idx1) = 0;
        
        %             figure,imshow(bw)
        
        %----- save the binary mask for erythrocytes-----
        % creat a new folder for drift compensation
        if ~exist([filefolder,'RBC mask'], 'dir')
            mkdir([filefolder,'RBC mask'])
        end
        
        maskname = [filefolder,'RBC mask\reg',num2str(reg),'_cycle1_ch',num2str(ch),'_rbc_mask.tif'];
        imwrite(mask_final,maskname);
        
        
        %------save the overlay ----------------
        [B,L] = bwboundaries(mask_final);
        %     [B,L] = bwboundaries(bw);
        fig = figure;imshow(I_eq,[])
        hold on
        for k = 1:length(B)
            boundary = B{k};
            plot(boundary(:,2), boundary(:,1), 'g')
        end
        title(['reg',num2str(reg)]);
        maskoverlayname = [filefolder,'RBC mask\reg',num2str(reg),'_cycle1_ch',num2str(ch),'_rbc_overlay.tif'];
        export_fig(maskoverlayname);
        close(fig)
    end
end
