% =========================================================================
% Guolan Lu, 9/3/21
% Pre-processing of codex data
% Input: raw codex images - selected from two multicycles
% Output: imagej hyperstack: x,y,zbest,channel, cycle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1:
% per region, per cycle, generate individual tiles (4 channels/tile)
%  - decovolution
%  - identify the best focus plane
% rename tiles for stitching
% =========================================================================
function genHyperstack(reg_range, cyc_range, path_input_matlab,cyc_last,nCh,rowFinal,colFinal)

% setup path
javaaddpath 'C:\Program Files\MATLAB\R2021b\java\jar\mij.jar'
javaaddpath 'C:\Program Files\MATLAB\R2021b\java\jar\ij.jar'

% start
MIJ.start('C:\Program Files\fiji-win64\Fiji.app\plugins\')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% path_input_matlab = ['X:\Guolan\test_deconvolution\multicycle_2020_09_preprocess\'];
path_input_matlab1 = split(path_input_matlab,"\");
path_input_imagej = join(path_input_matlab1,"/");
path_input = path_input_imagej{1};


for ii = 1:length(reg_range)
    reg = reg_range(ii);

    disp(['Final hyperstack: reg',num2str(reg),'...']);

    outputFileNameFullSize = [path_input,'bestFocus/fullSizeMontage/reg',num2str(reg,'%03.f'),'_montage.tif'];
    outputFileNameBestFocus = [path_input,'bestFocus/reg',num2str(reg,'%03.f'),'_montage.tif'];

    if isfile(outputFileNameFullSize) && isfile(outputFileNameBestFocus)
        disp(['Reg ',num2str(reg,'%03.f'), ' exists, skipping...'])
        continue
    end

    for jj = 1:length(cyc_range)
        cyc = cyc_range(jj);

        filename = [path_input,'reg',num2str(reg),'/3_bg_subtract_concat/reg',num2str(reg),'_cycle',num2str(cyc),'_reg_bgsub.tif'];
        imp = ij.IJ.openImage(filename);
        %         imStack = ReadTifStack(filename);
        %imp = ij.IJ.copytoImagePlus(imStack);
        imp.show();
        MIJ.run('Make Composite', 'display=Composite');
        MIJ.run("Split Channels");

        for kk = 1:length(nCh)
            ch = kk;
            window_name = strcat("C",num2str(ch),"-reg",num2str(reg),"_cycle",num2str(cyc),"_reg_bgsub.tif");
            ij.IJ.selectWindow(window_name);
            %             MIJ.run("Brightness/Contrast...");
            if ch == 1 || (ch == 4 && cyc == cyc_last)
                ij.IJ.resetMinAndMax();
                MIJ.run("Conversions...", "scale");
            else
                ij.IJ.setMinAndMax(0, 65535);
                MIJ.run("Conversions...", " ");
            end
            MIJ.run("16-bit");
        end

        if length(nCh) == 4
            channel_names = strcat("c1=C1-reg",num2str(reg),"_cycle",num2str(cyc),"_reg_bgsub.tif c2=C2-reg",num2str(reg),"_cycle",num2str(cyc),"_reg_bgsub.tif c3=C3-reg",num2str(reg),"_cycle",num2str(cyc),"_reg_bgsub.tif c4=C4-reg",num2str(reg),"_cycle",num2str(cyc),"_reg_bgsub.tif create");
            orderPara = strcat("order=xyczt(default) channels=4 slices=",num2str(length(cyc_range))," frames=1 display=Grayscale");
        elseif length(nCh) == 2
            channel_names = strcat("c1=C1-reg",num2str(reg),"_cycle",num2str(cyc),"_reg_bgsub.tif c2=C2-reg",num2str(reg),"_cycle",num2str(cyc),"_reg_bgsub.tif create");
            orderPara = strcat("order=xyczt(default) channels=2 slices=",num2str(length(cyc_range))," frames=1 display=Grayscale");
        end

        MIJ.run("Merge Channels...", channel_names);
    end
    MIJ.run("Concatenate...", "all_open open");
    %     orderPara = strcat("order=xyczt(default) channels=4 slices=",num2str(length(cyc_range))," frames=1 display=Grayscale");
    MIJ.run("Stack to Hyperstack...", orderPara);

    % save the final montage
    if ~exist([path_input,'bestFocus\'], 'dir')
        mkdir([path_input,'bestFocus\'])
    end

     % save the final montage
    if ~exist([path_input,'bestFocus\fullSizeMontage\'], 'dir')
        mkdir([path_input,'bestFocus\fullSizeMontage\'])
    end

    imStack = ij.IJ.getImage(); % need to get anew
    ij.IJ.saveAsTiff(imStack, outputFileNameFullSize);


    % downsize the stack
    window_name = strcat("reg",num2str(reg,'%03.f'),"_montage.tif");
    ij.IJ.selectWindow(window_name);
    para = strcat("width=",num2str(colFinal/2)," height=",num2str(rowFinal/2),"  depth=",num2str(length(cyc_range))," constrain average interpolation=Bilinear");
    
    MIJ.run("Size...", para);

    imStack = ij.IJ.getImage(); % need to get anew
    ij.IJ.saveAsTiff(imStack, outputFileNameBestFocus);


    MIJ.closeAllWindows; % Close all MIJ windows
end
% close imageJ when finished
MIJ.exit();
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
