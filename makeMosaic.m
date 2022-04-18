function makeMosaic(path_output,reg_range,cyc_range)

disp('Making mosaics...');
% parpool(nCPU)
for ii = 1:length(reg_range)
    reg = reg_range(ii);
    disp(['Region ', num2str(reg),' mosaics']);

    for jj = 1:length(cyc_range)
        cyc = cyc_range(jj);

            disp(['Cycle ', num2str(cyc),' mosaic']);

        tif_path = [path_output,'reg',num2str(reg),'\1_deconv_stitch\cycle',num2str(cyc),'\reg',num2str(reg),'_cycle',num2str(cyc),'_montage.tif'];
        if isfile(tif_path)
            disp([tif_path,' exists, skipping...']);
            continue
        end
        global_pos_path = [path_output,'reg',num2str(reg),'\1_deconv_stitch\cycle',num2str(cyc),'\reg',num2str(reg),'_cycle',num2str(cyc),'_global-positions-0.txt'];
        % convert txt to cell array
        cell_array = load_csv_file_into_cell_array(global_pos_path);
        % extract x,y coordinate from cell array
        x_cell = extractAfter(cell_array(:,1),'(');
        y_cell = extractBefore(cell_array(:,2),')');
        
        global_x_img_pos = cellfun(@str2num,x_cell);
        global_y_img_pos = cellfun(@str2num,y_cell);
        
        % make a montage
%         addpath(genpath('C:\Users\Guolan\Desktop\Guolan\preprocessing\MIST-mist-matlab\MIST-mist-matlab\src\subfunctions'));
        img_name = extractBetween(cell_array(:,1),' ',';');
        img_name_grid = img_name(:,1);
        nCh = 4;
        fusion_method = 'linear';
        source_directory = [path_output,'reg',num2str(reg),'\1_deconv_stitch\cycle',num2str(cyc),'\'];
        im_stack_montage = assemble_stitched_image_stack(source_directory, img_name_grid, global_y_img_pos, global_x_img_pos, nCh, fusion_method);

        % save the image stack
        % write each montage as an image stack of 4 channel images; name them
        BitsPerSample = 32;
        WriteTifStack(im_stack_montage, tif_path, BitsPerSample);
    end
end
% delete(gcp('nocreate'));
end
