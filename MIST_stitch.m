function MIST_stitch(mjipath,ijpath,pluginpath,path_input_matlab,reg_range,cyc_range,grid_size_x,grid_size_y,overlapRatio)
% % setup path
% % start
% MIJ.start('C:\Program Files\fiji-win64_Guolan\Fiji.app\plugins\')
disp('Generating positions...');

% setup path
javaaddpath(mjipath)
javaaddpath(ijpath)

% start
MIJ.start(pluginpath)

pluginpath1 = split(pluginpath(1:end-8),"\");
pluginpath2 = join(pluginpath1,"\\");
planpath=[pluginpath2{1},'lib\\fftw\\fftPlans'];
fftwlibrarypath=[pluginpath2{1},'lib\\fftw'] ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_input_matlab1 = split(path_input_matlab,"\");
path_input_imagej = join(path_input_matlab1,"/");
path_input = path_input_imagej{1};


blendMethod = 'LINEAR';
alpha = 1.5;

for ii = 1:length(reg_range)

    reg = reg_range(ii);
     disp(['generating stitching positions: reg',num2str(reg),'...']);

    for jj = 1:length(cyc_range)
        cyc = cyc_range(jj);
        disp(['generating stitching positions: cyc',num2str(cyc),'...']);

        inputfolderName = [path_input,'reg',num2str(reg),'/1_deconv_stitch/cycle',num2str(cyc),'/'];
        inputFileName = ['reg',num2str(reg),'_tile_{p}.tif'];
        outfileprefix = ['reg',num2str(reg),'_cycle',num2str(cyc),'_'];

        % skip if output already exists
        MISToutputMontage = [inputfolderName, '/', outfileprefix, 'montage.tif'];
        if isfile(MISToutputMontage)
          disp([MISToutputMontage, ' exists, skipping...']);
          continue
        end

        MIJ.run('MIST', ['gridwidth=',num2str(grid_size_x),' gridheight=',num2str(grid_size_y),' starttile=1 imagedir=',inputfolderName,' filenamepattern=', inputFileName,' filenamepatterntype=SEQUENTIAL gridorigin=UL assemblefrommetadata=false assemblenooverlap=false globalpositionsfile=[] numberingpattern=HORIZONTALCONTINUOUS startrow=0 startcol=0 ','extentwidth=',num2str(grid_size_x),' extentheight=',num2str(grid_size_y),' timeslices=0 istimeslicesenabled=false outputpath=',inputfolderName,' displaystitching=false outputfullimage=false outputmeta=true outputimgpyramid=false blendingmode=',blendMethod,' blendingalpha=',num2str(alpha),' outfileprefix=',outfileprefix,' programtype=AUTO numcputhreads=32 loadfftwplan=true savefftwplan=true fftwplantype=MEASURE fftwlibraryname=libfftw3 fftwlibraryfilename=libfftw3.dll planpath=[',planpath,'] fftwlibrarypath=[',fftwlibrarypath,'] stagerepeatability=0 horizontaloverlap=',num2str(overlapRatio),' verticaloverlap=',num2str(overlapRatio),' numfftpeaks=0 overlapuncertainty=NaN isusedoubleprecision=false isusebioformats=false issuppressmodelwarningdialog=false isenablecudaexceptions=false translationrefinementmethod=SINGLE_HILL_CLIMB numtranslationrefinementstartpoints=16 headless=false loglevel=MANDATORY debuglevel=NONE']);

        MIJ.closeAllWindows; % Close all MIJ windows
    end
end

% close imageJ when finished
MIJ.exit()

end
