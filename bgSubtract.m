function bgSubtract_par(reg_range,cyc_range,texp,cyc_bg,path_input,neg_flag,rowFinal,colFinal,nCh)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Guolan Lu, 9/3/21
% background subtraction
% texp = exposure time matrix: cycle x 3channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parpool(nCPU)
for ii = 1:length(reg_range)
    % for ii = 1:length(reg_range)
    reg = reg_range(ii);

    disp(['Background subtraction: reg',num2str(reg),'...']);

    if ~exist([path_input,'reg',num2str(reg),'\3_bg_subtract_concat'], 'dir')
        mkdir([path_input,'reg',num2str(reg),'\3_bg_subtract_concat'])
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % background subtraction
    % subtract background from channel 2-4
    % im - (bg/exp_bg)*exp_im
    %     nx = 3458; ny = 4612;
    %     nCh = 4;

    for jj = 1:length(cyc_range)

        cyc = cyc_range(jj);

        imname = [path_input,'reg',num2str(reg),'\2_drift_compensate\reg',num2str(reg),'_cycle',num2str(cyc),'_registered.tif'];

        % skip, disp if no input exists
        if ~isfile(imname)
            disp([imname, ' does not exist, skipping...'])
            continue
        end
        imname_bg = [path_input,'reg',num2str(reg),'\2_drift_compensate\reg',num2str(reg),'_cycle',num2str(cyc_bg),'_registered.tif'];

        % skip if output already exists
        filename_sb = [path_input,'reg',num2str(reg),'\3_bg_subtract_concat\reg',num2str(reg),'_cycle',num2str(cyc),'_reg_bgsub.tif'];
        if isfile(filename_sb)
            disp([filename_sb, ' exists, skipping...'])
            continue
        end

        im_ch1 = imread(imname,1);

        %% pad images to make the image size uniform
        %         rowFinal = 3460; colFinal = 4620;
        rowCurr = size(im_ch1,1);
        colCurr = size(im_ch1,2);

        % =================================================================
        % if rowFinal < rowCurr, no need to pad, but to cut extra rows and
        % columns
        r = rowFinal - rowCurr;
        c = colFinal - colCurr;
        im_stack = zeros(rowFinal,colFinal,length(nCh));

        if r>=0 && c>=0
            im_stack(:,:,1) = padarray(im_ch1,[r c],0,'post');
            for kk = 2:length(nCh)
                ch = nCh(kk);
                im_bg = imread(imname_bg,kk);
                im = imread(imname,kk);
                im_sb = double(im) - double(im_bg)/texp(cyc_bg,ch+1)*texp(cyc,ch+1);

                %% pad images to make the image size uniform
                im_stack(:,:,kk) = padarray(im_sb,[r c],0,'post');
            end

        elseif r<0 && c<0
            rbeg = floor(abs(r)/2)+1;
            rend = rowFinal + floor(abs(r)/2);
            cbeg = floor(abs(c)/2)+1;
            cend = colFinal + floor(abs(c)/2);

            im_stack(:,:,1) = im_ch1(rbeg:rend,cbeg:cend);
            for kk = 2:length(nCh)
                ch = nCh(kk);
                im_bg = imread(imname_bg,kk);
                im = imread(imname,kk);
                im_sb = double(im) - double(im_bg)/texp(cyc_bg,ch+1)*texp(cyc,ch+1);

                %% pad images to make the image size uniform
                im_stack(:,:,kk) = im_sb(rbeg:rend,cbeg:cend);
            end

        elseif r>=0 && c<0
            cbeg = floor(abs(c)/2)+1;
            cend = colFinal + floor(abs(c)/2)-1;
            im_ch1_new = im_ch1(:,cbeg:cend);
            im_stack(:,:,1) = padarray(im_ch1_new,[r 1],0,'post');
            for kk = 2:length(nCh)
                ch = nCh(kk);
                im_bg = imread(imname_bg,kk);
                im = imread(imname,kk);
                im_sb = double(im) - double(im_bg)/texp(cyc_bg,ch+1)*texp(cyc,ch+1);
                im_sb_new = im_sb(:,cbeg:cend);
                %% pad images to make the image size uniform
                im_stack(:,:,kk) = padarray(im_sb_new,[r 1],0,'post');
            end

        elseif r<0 && c>=0
            rbeg = floor(abs(r)/2)+1;
            rend = rowFinal + floor(abs(r)/2)-1;
            im_ch1_new = im_ch1(rbeg:rend,:);
            im_stack(:,:,1) = padarray(im_ch1_new,[1 c],0,'post');
            for kk = 2:length(nCh)
                ch = nCh(kk);
                im_bg = imread(imname_bg,kk);
                im = imread(imname,kk);
                im_sb = double(im) - double(im_bg)/texp(cyc_bg,ch+1)*texp(cyc,ch+1);
                im_sb_new = im_sb(rbeg:rend,:);
                %% pad images to make the image size uniform
                im_stack(:,:,kk) = padarray(im_sb_new,[1 c],0,'post');
            end
        end

        if neg_flag == 1
            im_stack(im_stack<0) = 0;
        end
        BitsPerSample = 32;
        filename_sb = [path_input,'reg',num2str(reg),'\3_bg_subtract_concat\reg',num2str(reg),'_cycle',num2str(cyc),'_reg_bgsub.tif']
        WriteTifStack(im_stack, filename_sb, BitsPerSample);

    end

end

% shut down the parallel pool.
% delete(gcp('nocreate'));

end
