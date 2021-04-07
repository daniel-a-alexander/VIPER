classdef VIPER_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        VIPERUIFigure                  matlab.ui.Figure
        TabGroup                       matlab.ui.container.TabGroup
        XZAlignmentTab                 matlab.ui.container.Tab
        BrowsetoFolderButton_1         matlab.ui.control.Button
        PositionROILabel               matlab.ui.control.Label
        AnalyzeStarshotLabel           matlab.ui.control.Label
        PositionROIButton              matlab.ui.control.Button
        FindPhantomCenterLabel         matlab.ui.control.Label
        ClickCrosshairButton           matlab.ui.control.Button
        AnalyzeStarshotButton          matlab.ui.control.Button
        AnalyzeMessage                 matlab.ui.control.Label
        MinimumCircleRadiusLabel       matlab.ui.control.Label
        MinimumCircleRadiusValue       matlab.ui.control.Label
        ofbeamsEditFieldLabel          matlab.ui.control.Label
        NofbeamsEditField              matlab.ui.control.NumericEditField
        ResetCherenkovImageButton      matlab.ui.control.Button
        ResetBackgroundImageButton     matlab.ui.control.Button
        FFStatusLabel                  matlab.ui.control.Label
        LoadImagesLabel                matlab.ui.control.Label
        CenterCoordlabel               matlab.ui.control.Label
        UIAxes_prof                    matlab.ui.control.UIAxes
        UIAxes_bkg                     matlab.ui.control.UIAxes
        UIAxes_ch                      matlab.ui.control.UIAxes
        YAlignmentTab                  matlab.ui.container.Tab
        BrowsetoFolderButton_2         matlab.ui.control.Button
        FFStatusLabel_2                matlab.ui.control.Label
        LoadImagesLabel_2              matlab.ui.control.Label
        YAlignmentWarning              matlab.ui.control.Label
        LoadImagesLabel_3              matlab.ui.control.Label
        PositionROIButton_2            matlab.ui.control.Button
        CenterCoordlabel_2             matlab.ui.control.Label
        CalcOpticalDiamLabel           matlab.ui.control.Label
        CalcOpticalDiamButton          matlab.ui.control.Button
        OpticalDiamLabel               matlab.ui.control.Label
        ResetCherenkovImageButton_2    matlab.ui.control.Button
        ResetBackgroundImageButton_2   matlab.ui.control.Button
        UIAxes_bkg_2                   matlab.ui.control.UIAxes
        UIAxes_ch_2                    matlab.ui.control.UIAxes
        ResultsTab                     matlab.ui.container.Tab
        ResultsLabel                   matlab.ui.control.Label
        dxmmLabel                      matlab.ui.control.Label
        dymmLabel                      matlab.ui.control.Label
        dzmmLabel                      matlab.ui.control.Label
        drmmLabel                      matlab.ui.control.Label
        RTtoMRLabel                    matlab.ui.control.Label
        DifferencesLabel               matlab.ui.control.Label
        CalculateResultsButton         matlab.ui.control.Button
        RT_MR_dx_Label                 matlab.ui.control.Label
        RT_MR_dy_Label                 matlab.ui.control.Label
        RT_MR_dz_Label                 matlab.ui.control.Label
        RT_MR_dr_Label                 matlab.ui.control.Label
        PhantOffsetMissingLabel        matlab.ui.control.Label
        CalibrationTab                 matlab.ui.container.Tab
        BrowsetoFolderButton_4         matlab.ui.control.Button
        LoadNewFlatfieldLabel          matlab.ui.control.Label
        DefinePixelSizeLabel           matlab.ui.control.Label
        PixelSizeSpinner               matlab.ui.control.Spinner
        SavePixelSizeButton            matlab.ui.control.Button
        mmLabel_1                      matlab.ui.control.Label
        DoyouwanttosavethisvalueThiswillimpactresultsLabel  matlab.ui.control.Label
        SavePixelSizeCheck             matlab.ui.control.DropDown
        SavePixelSizeStatusLabel       matlab.ui.control.Label
        RingDiameterCalibLabel         matlab.ui.control.Label
        BackgroundRingDiametermmLabel  matlab.ui.control.Label
        BkgRingDiameter                matlab.ui.control.NumericEditField
        CalibYShifts                   matlab.ui.control.Label
        SaveYCalibButton               matlab.ui.control.Button
        DoyouwanttosavethesevaluesThiswillimpactresultsLabel  matlab.ui.control.Label
        SaveYCalibCheck                matlab.ui.control.DropDown
        SaveYCalibStatusLabel          matlab.ui.control.Label
        SaveYCalibStatusLabelEditFieldLabel  matlab.ui.control.Label
        RingDiameterCalib              matlab.ui.control.EditField
        OpticalDiamsFormatWarning      matlab.ui.control.Label
        DefaultDataPathLabel           matlab.ui.control.Label
        DefaultDataPathField           matlab.ui.control.EditField
        SavePathButton                 matlab.ui.control.Button
        SavePathStatusLabel            matlab.ui.control.Label
    end


    properties (Access = public)
        bkg_im_xz; % background image of VRICP
        ch_im_xz; % cherenkov image of starshot for x/z-measurement
        ff; % flatfield
        isff = 0; % is there a flatfield
        imcent = [nan nan]; % center of crosshair
        star_profile; % circular profile over starshot
        circ_vertices; % vertices of circle roi
        isLoaded_xz = 0;
        isLoaded_y = 0;
        isCrosshair = 0;
        isRing = 0;
        isROI = 0;
        sort_idx;
        pixelsize;
        ispx = 0;
        RT_MR_dx = NaN;
        RT_MR_dy = NaN;
        RT_MR_dz = NaN;
        RT_MR_dr = NaN;
        min_circ_c = [nan nan];
        min_circ_r;
        ch_im_y;
        bkg_im_y; 
        isXZdone = 0; 
        isYDone = 0;
        bkg_ring_center = [nan nan];
        bkg_ring_diam;
        isRingCalib = 0;
        y_vals_calib;
        optical_diams_calib;
        background_ring_diam_calib; 
        optical_diam;
        defaultpath = 0;
        ss_circ_center;
        ss_circ_radius; % Description
    end
    
    
    methods (Access = private)

        function plotStarProf_fcn(app, im, px_array) % updates plot of circular profile
            
            ring_delta_mm = 2; % in each direction
            ring_delta_px = round(ring_delta_mm/app.pixelsize);
            
            radii = app.ss_circ_radius + (-ring_delta_px:ring_delta_px);
            CircVerts_default = px_array;
            len_default = numel(CircVerts_default(:,1));
            
            CircVerts = zeros(len_default, 2, numel(radii)); % index, then x or y (1 or 2), then radius
            
            for r = 1:numel(radii)
                temp = circlepoints(app.ss_circ_center(1), app.ss_circ_center(2), round(radii(r)));
                len = numel(temp(:,1));
                CircVerts(:,1,r) = inpaint_nans(interp1(1:len, temp(:,1), 1:len_default)); % interpolate x
                CircVerts(:,2,r) = inpaint_nans(interp1(1:len, temp(:,2), 1:len_default)); % interpolate y
            end
            
            star_profs = zeros(numel(radii), len_default);

            for i = 1:len_default
                temp = zeros(numel(radii), 1);
                for r = 1:numel(radii)
                    temp(r,1) = app.ch_im_xz(CircVerts(i,2,r), CircVerts(i,1,r));
                end
                star_profs(:, i) = temp;
            end
            
            app.star_profile = mean(star_profs, 1);
                        
         
            temp = zeros(size(px_array,1),1); % initiates pixel intensity array around circular profile
            for i=1:size(px_array,1)
                temp(i) = im(round(px_array(i,2)), round(px_array(i,1))); %getting individual pixel values along circular profile
            end

            app.star_profile = medfilt1(smooth(mean(temp, 2)),9);
            
            if size(app.star_profile, 1) < size(app.star_profile, 2)
                app.star_profile = app.star_profile';
            end
%             app.star_profile = zeros(size(px_array,1),1); % initiates pixel intensity array around circular profile
%             for i=1:size(px_array,1)
%                 app.star_profile(i) = im(round(px_array(i,2)), round(px_array(i,1))); %getting individual pixel values along circular profile
%             end
%             app.star_profile = smooth(app.star_profile);
            
            % get angles from center to each point acquired on profile ------
            vectors = double(px_array);
            vectors(:,1) = double(px_array(:,1) - app.imcent(1));
            vectors(:,2) = double(px_array(:,2) - app.imcent(2));   
            angles = atan2d(vectors(:,2), vectors(:,1));
            angles_mapped = map_angles_fcn(app,angles); % map angles to viewray
            
            % sort data for peak finding -----------------
            [angles_mapped, app.sort_idx] = sort(angles_mapped); % sort data by angle from 0 to 360
            app.circ_vertices = app.circ_vertices(app.sort_idx,:); % sort vertices by the same indeces
            app.star_profile = app.star_profile(app.sort_idx); % sort profile by the same indeces
            app.star_profile = smooth(app.star_profile, 7);
            % append data to end of circular arrays, to allow for peak finding at
            % endpoints -------------
            len = length(app.star_profile);
            pct = 0.05; % percent extenion of array
            
            angles_mapped = interp1(1:len, angles_mapped, 1:round((1+pct)*len), 'linear', 'extrap')';

            star_profile_extension = app.star_profile(1:round(pct*len));
            app.star_profile = [app.star_profile; star_profile_extension];
            
            circ_vertices_extension = app.circ_vertices(1:round(pct*len), :);
            app.circ_vertices = [app.circ_vertices; circ_vertices_extension];
            
            % Plot
            plot(app.UIAxes_prof, angles_mapped, app.star_profile, 'b-', 'Linewidth', 2)
            set(app.UIAxes_prof, 'xlim', [0,360]) % extended plot to see end point
            temp_star_prof = app.star_profile;
        end
        
        function angles_mapped = map_angles_fcn(app, angles) % maps angles from atan2 range to viewray coordinate system
            angles_mapped = zeros(size(angles));
            for a = 1:numel(angles)
                if angles(a) >= -180 && angles(a) <= 90
                    angles_mapped(a) = -1*angles(a)+90;
                elseif angles(a) > 90
                    angles_mapped(a) = -1*angles(a)+450;
                end
            end
            
        end
        
        function h = drawMinCircle(app,x,y,r)
            hold(app.UIAxes_ch, 'on')
            th = 0:pi/50:2*pi;
            xunit = r * cos(th) + x;
            yunit = r * sin(th) + y;
            h = plot(app.UIAxes_ch, xunit, yunit, 'r-', 'Linewidth', 2);
            hold(app.UIAxes_ch, 'off')
        end
        
        function h = drawRingCircle(app,x,y,r)
            hold(app.UIAxes_ch_2, 'on')
            th = 0:pi/50:2*pi;
            xunit = r * cos(th) + x;
            yunit = r * sin(th) + y;
            h = plot(app.UIAxes_ch_2, xunit, yunit, 'r-', 'Linewidth', 2);
            hold(app.UIAxes_ch_2, 'off')
        end
    end
    
    methods (Access = public)

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Check that
            
            % prevent resizing ----------------
            app.VIPERUIFigure.Position = [100 100 1201 901];
            app.VIPERUIFigure.Resize = 'off';
            
            % Make titles white -------------------
            app.UIAxes_ch.Title.Color = 'w';
            app.UIAxes_bkg.Title.Color = 'w';
            app.UIAxes_prof.Title.Color = 'w';
            
            app.UIAxes_ch_2.Title.Color = 'w';
            app.UIAxes_bkg_2.Title.Color = 'w';
            
            % Load calib files -------------------
            % Check that calib folder exists
            if ~isfolder(fullfile(userpath, 'VIPER', 'calib_files'))
                [status] = mkdir(fullfile(userpath, 'VIPER', 'calib_files'));
            end
           
            
            % Pixel Size ----------------------------
            if isfile(fullfile(userpath, 'VIPER', 'calib_files','PixelSize.mat'))
                loaded_px_data = load(fullfile(userpath, 'VIPER', 'calib_files', 'PixelSize.mat'), 'PixelSize'); 
                app.pixelsize = loaded_px_data.PixelSize;
                app.PixelSizeSpinner.Value = app.pixelsize;
                app.ispx = 1;
            else
                app.ispx = 0;
            end
            
            % Ring Calibration --------------------------
            if isfile(fullfile(userpath, 'VIPER', 'calib_files','RingCalibration.mat'))
                loaded_ring_data = load(fullfile(userpath, 'VIPER', 'calib_files', 'RingCalibration.mat')); 
                app.y_vals_calib = loaded_ring_data.YVals;
                app.optical_diams_calib = loaded_ring_data.OpticalDiams;
                app.background_ring_diam_calib = loaded_ring_data.BackgroundRingDiam; 
                
                temp = sprintf('%.2f,' , app.optical_diams_calib);
                temp = temp(1:end-1);
                app.RingDiameterCalib.Value = temp;
                
                app.BkgRingDiameter.Value = app.background_ring_diam_calib;
                
                app.isRingCalib = 1;
            else
                app.isRingCalib = 0;
            end
            
            % Default Path ---------------------------------
            if isfile(fullfile(userpath, 'VIPER', 'calib_files','DefaultPath.mat'))
                loaded_path = load(fullfile(userpath, 'VIPER', 'calib_files','DefaultPath.mat'));
                app.defaultpath = loaded_path.DefaultPath;
                app.DefaultDataPathField.Value = app.defaultpath;
            end
            
            % Flatfield-----------------------
            if isfile(fullfile(userpath, 'VIPER', 'calib_files', 'FF.mat'))
                loaded_ff_data = load(fullfile(userpath, 'VIPER', 'calib_files', 'FF.mat')); 
                temp = loaded_ff_data.FF;
                temp(1,:) = temp(2,:); % Get rid of readout pixels
                temp(isnan(temp)|isinf(temp)) = mean(temp(:));
                
                app.ff = temp;
                app.isff = 1;
            else
                app.isff = 0;
            end
        end

        % Button pushed function: BrowsetoFolderButton_1
        function BrowsetoFolderButton_1Pushed(app, event)
            app.BrowsetoFolderButton_1.Text = 'Loading...';
%             set(app.VIPERUIFigure, 'Pointer','watch');
%             drawnow;
            
%             app.VIPERUIFigure.Visible = 'off';
            if app.defaultpath ~= 0
                path = uigetdir(app.defaultpath, 'Select Data Folder');
            else
                path = uigetdir(pwd, 'Select Data Folder');
            end
%             app.VIPERUIFigure.Visible = 'on';
            if path ~= 0
                dirContents = dir(path);
                
                % Check for dovi files
                hasDovi = 0;
                hasMat = 0;
                hasPNG = 0;
                matFile = '';
                for i=1:numel(dirContents)
                    if contains(dirContents(i).name, '.dovi')
                        hasDovi = hasDovi +1;
                    end
                    if contains(dirContents(i).name, '.mat')
                        matFile = dirContents(i).name;
                        hasMat = hasMat+1;
                    end
                    if contains(dirContents(i).name, 'meas') && contains(dirContents(i).name, '.png')
                        hasPNG = hasPNG+1;
                    end
                end
                
                % load images
                if (hasDovi + hasMat + hasPNG >= 1) 
                    
                    % Check for png files, then mat files, then dovi files
                    if hasPNG > 0
                        app.ch_im_xz = flip(double(imread(fullfile(path,'meas_s1_cam0.png'))),1);
                        app.bkg_im_xz = flip(double(imread(fullfile(path,'meas_s0_cam0.png'))),1);
                    elseif hasMat > 0
                        matVars = load(fullfile(path,matFile));
                        app.ch_im_xz = matVars.im1;
                        app.bkg_im_xz = matVars.im0;
                    else
                        app.ch_im_xz = sum(read_dovi(fullfile(path,'meas_s1_cam0.dovi')),3);
                        app.bkg_im_xz = sum(read_dovi(fullfile(path,'meas_s0_cam0.dovi')),3);
                        % save mat file for next time
                        im1 = app.ch_im_xz;
                        im0 = app.bkg_im_xz;
                        save(fullfile(path,'summed_images.mat'), 'im1', 'im0');
                    end
                    
                    % Get rid of readout pixels
                    app.ch_im_xz(1,:) = app.ch_im_xz(2,:);
                    app.bkg_im_xz(1,:) = app.bkg_im_xz(2,:);
                            
                    if app.isff
                        if size(app.ff, 2) == size(app.ch_im_xz, 2)
                            app.ch_im_xz = app.ch_im_xz./app.ff;
                            app.bkg_im_xz = app.bkg_im_xz./app.ff;
                            app.FFStatusLabel.Text = '';
                        else
                            app.FFStatusLabel.Text = ['Warning: Flatfield dimension mismatch.' newline, 'Flatfield correction is disabled.'];
                        end
                    else
                        app.FFStatusLabel.Text = ['Warning: No flatfield found.' newline, 'Flatfield correction is disabled.'];
                    end
                    
                    imagesc(app.UIAxes_bkg, app.bkg_im_xz)
                    colormap(app.UIAxes_bkg, gray)
%                     if strcmp(app.DropDown.Value,'4x3')
%                         set(app.UIAxes_bkg, 'PlotBoxAspectRatio', [4 3 1])
%                     elseif strcmp(app.DropDown.Value,'16x10')
%                         set(app.UIAxes_bkg, 'PlotBoxAspectRatio', [16 10 1])
%                     end
                    set(app.UIAxes_bkg, 'PlotBoxAspectRatio', [size(app.bkg_im_xz, 2), size(app.bkg_im_xz, 1), 1])
                    
                    
                    imagesc(app.UIAxes_ch, app.ch_im_xz);
    %                 colormap(app.UIAxes_ch, jet)
%                     if strcmp(app.DropDown.Value,'4x3')
%                         set(app.UIAxes_ch, 'PlotBoxAspectRatio', [4 3 1])
%                     elseif strcmp(app.DropDown.Value,'16x10')
%                         set(app.UIAxes_ch, 'PlotBoxAspectRatio', [16 10 1])
%                     end
                    
    %                 max_window_width = max(app.ch_im_xz(:))-min(app.ch_im_xz(:));
%                     curr_lims = app.UIAxes_ch.CLim;
                    set(app.UIAxes_ch, 'PlotBoxAspectRatio', [size(app.ch_im_xz, 2), size(app.ch_im_xz, 1), 1])
                    
                    
%                     app.WindowSlider_ch.Limits = [0, 1];
%                     app.WindowSlider_ch.Value = 0.5;
%                     app.LevelSlider_ch.Limits = [0, 1];
%                     app.LevelSlider_ch.Value = 0.5;
                    
                    app.isLoaded_xz = 1;
    %                 set(app.VIPERUIFigure, 'Pointer','arrow');
                    app.BrowsetoFolderButton_1.Text = 'Browse to Folder';
                    
                elseif hasDovi == 0
                    app.BrowsetoFolderButton_1.Text = 'No Files Found';
                    app.isLoaded_xz = 0;
                    pause(2)
    %                 set(app.VIPERUIFigure, 'Pointer','arrow');
                    app.BrowsetoFolderButton_1.Text = 'Browse to Folder';
                    
                elseif hasDovi == 1
                    app.BrowsetoFolderButton_1.Text = 'Missing Files';
                    app.isLoaded_xz = 0;
                    pause(2)
    %                 set(app.VIPERUIFigure, 'Pointer','arrow');
                    app.BrowsetoFolderButton_1.Text = 'Browse to Folder';
                end
            else
                app.BrowsetoFolderButton_1.Text = 'Cancelled';
                app.isLoaded_xz = 0;
                pause(2)
%                 set(app.VIPERUIFigure, 'Pointer','arrow');
                app.BrowsetoFolderButton_1.Text = 'Browse to Folder';
            end
        end

        % Callback function
        function DropDownValueChanged(app, event)
            
        end

        % Callback function
        function WindowSlider_chValueChanged(app, event)
            w = app.WindowSlider_ch.Value;
            l = app.LevelSlider_ch.Value;
            set(app.UIAxes_ch, 'CLim', [l-(w/2), l+(w/2)])
        end

        % Callback function
        function LevelSlider_chValueChanged(app, event)
            w = app.WindowSlider_ch.Value;
            l = app.LevelSlider_ch.Value;
            set(app.UIAxes_ch, 'CLim', [l-(w/2), l+(w/2)])
        end

        % Callback function
        function WindowSlider_chValueChanging(app, event)
            w = event.Value;
            l = app.LevelSlider_ch.Value;
            set(app.UIAxes_ch, 'CLim', [l-(w/2), l+(w/2)])
        end

        % Callback function
        function LevelSlider_chValueChanging(app, event)
            l = event.Value;
            w = app.WindowSlider_ch.Value;
            set(app.UIAxes_ch, 'CLim', [l-(w/2), l+(w/2)])
        end

        % Button pushed function: PositionROIButton
        function PositionROIButtonPushed(app, event)
            if app.isROI > 0
                
            end
            
            if app.isLoaded_xz == 0
                app.PositionROIButton.Text = 'No Images Loaded';
                pause(2)
                app.PositionROIButton.Text = 'Position ROI';
            elseif app.isCrosshair == 0
                app.PositionROIButton.Text = 'Crosshair Not Clicked';
                pause(2)
                app.PositionROIButton.Text = 'Position ROI';
            else
                circ = drawcircle(app.UIAxes_ch,'LineWidth', 1); 
                app.circ_vertices = circlepoints(round(circ.Center(1)), round(circ.Center(2)), round(circ.Radius));
                app.ss_circ_center = round(circ.Center);
                app.ss_circ_radius = round(circ.Radius);
                px_array = app.circ_vertices;
                plotStarProf_fcn(app, app.ch_im_xz, px_array)
                delete(circ)
                app.PositionROIButton.Text = 'Position ROI';
                app.isROI = 1;
            end
        end

        % Button pushed function: ClickCrosshairButton
        function ClickCrosshairButtonPushed(app, event)
            if app.isLoaded_xz == 0
                app.ClickCrosshairButton.Text = 'No Images Loaded';
                pause(2)
                app.ClickCrosshairButton.Text = 'Click Crosshair';
            else
                point = drawpoint(app.UIAxes_bkg);
                temp_cent = round(point.Position);
                delete(point)
                
                % Auto calculate crosshair center ----------------
                r_mm = 8; % px 
                r_px = r_mm/app.pixelsize; % convert to px
                circ_vertices_bkg = circlepoints(round(temp_cent(1)), round(temp_cent(2)), round(r_px));
                bkg_circ_profile = zeros(size(circ_vertices_bkg, 1),1);
                for i=1:size(circ_vertices_bkg, 1)
                    bkg_circ_profile(i) = app.bkg_im_xz(round(circ_vertices_bkg(i,2)), round(circ_vertices_bkg(i,1)));
                end
                
                vectors = double(circ_vertices_bkg);
                vectors(:,1) = double(circ_vertices_bkg(:,1) - temp_cent(1));
                vectors(:,2) = double(circ_vertices_bkg(:,2) - temp_cent(2));   
                angles = atan2d(vectors(:,2), vectors(:,1)); 
                for a=1:numel(angles)
                    if angles(a) <= -135
                        angles(a) = 360+angles(a);
                    end
                end
                [angles, sort_idx_bkg] = sort(angles);
                circ_vertices_bkg = circ_vertices_bkg(sort_idx_bkg,:);
                bkg_circ_profile = bkg_circ_profile(sort_idx_bkg,:);
                
                %%
                
                bkg_circ_profile = mat2gray(-bkg_circ_profile);
%                 plot(angles, bkg_circ_profile)
                
                %%
                
                [~, array_idx, ~, proms] = findpeaks(bkg_circ_profile); % values, indeces, widths, promineces
                peak_idx = proms > 0.30*max(proms(:)); % greater than 10% of max prominence
                array_idx = array_idx(peak_idx)';
                peak_coords = circ_vertices_bkg(array_idx, :);
                L1(1,:) = [peak_coords(1, 1), peak_coords(3, 1)];
                L1(2,:) = [peak_coords(1, 2), peak_coords(3, 2)];
                
                L2(1,:) = [peak_coords(2, 1), peak_coords(4, 1)];
                L2(2,:) = [peak_coords(2, 2), peak_coords(4, 2)];
                
                app.imcent = round(InterX(L1,L2)');
                
                % Update UI --------------
                app.CenterCoordlabel.Text = '';
                pause(0.4)
                app.CenterCoordlabel.Text = ['Center = ',num2str(app.imcent)];
%                 app.ClickCrosshairButton.Text = 'Re-click Crosshair';
                app.isCrosshair = 1;
            end
        end

        % Button pushed function: AnalyzeStarshotButton
        function AnalyzeStarshotButtonPushed(app, event)
            if app.isROI == 0
                app.AnalyzeStarshotButton.Text = 'No ROI Selected';
                pause(2)
                app.AnalyzeStarshotButton.Text = 'Analyze Starshot';
            elseif app.ispx == 0
                app.AnalyzeMessage.Text = 'Error: No pixel size defined';
            else
                n_beams = app.NofbeamsEditField.Value;
                n_peaks = n_beams*2;
                
                % Get coordinates of peaks on image -----------
                
%                 [~, array_idx, ~, proms] = findpeaks(app.star_profile); % values, indeces, widths, promineces
%                 peak_idx = proms > 0.50*max(proms(:)); % greater than 50% of max prominence
% %                 [~, peak_idx] = maxk(proms, n_peaks);
%                 array_idx = array_idx(peak_idx)';
% %                 proms = proms(peak_idx)'; 
%                 peak_coords = app.circ_vertices(array_idx, :);

                temp = rescale(app.star_profile,-1,1);
                zero_line = zeros(size(temp));
                xinds = 1:numel(temp);
                crossings = InterX([xinds; temp'], [xinds; zero_line']);
                crossing_inds = crossings(1,:);
                peaks_and_troughs = 0.5 * (crossing_inds(1:end-1) + crossing_inds(2:end));
                temp_interp = interp1(xinds, temp, peaks_and_troughs);
                peak_idx = peaks_and_troughs(temp_interp>0);
                disp(peak_idx)
                peak_coords = app.circ_vertices(round(peak_idx),:);
%                 proms = proms(peak_idx)'; 

                % Update prof plot with vert lines at peak angles
                peak_vectors = double(peak_coords);
                peak_vectors(:,1) = double(peak_coords(:,1) - app.imcent(1));
                peak_vectors(:,2) = double(peak_coords(:,2) - app.imcent(2));   
                
                peak_angles = atan2d(peak_vectors(:,2), peak_vectors(:,1));
                peak_angles_mapped = map_angles_fcn(app, peak_angles);
                
                hold(app.UIAxes_prof, 'on')
                angs=gobjects(size(peak_angles_mapped)); % initialize graphics handle array
                for a = 1:numel(peak_angles_mapped)
                    angs(a) = xline(app.UIAxes_prof, peak_angles_mapped(a), 'r-', 'Linewidth', 2);
                end
                hold(app.UIAxes_prof, 'off')
                
                % Messages --------------
                if numel(peak_angles_mapped) == n_peaks
                    app.AnalyzeMessage.Text = '';
%                     app.AnalyzeMessage.Text = ['Success! ', num2str(app.NofbeamsEditField.Value), ' beams detected.'];
                elseif mod(numel(peak_angles_mapped), 2) ~= 0
                    app.AnalyzeMessage.Text = 'Error: Odd number of peaks detected';
                else
                    app.AnalyzeMessage.Text = ['Error: Number of beams detected does not',newline,'match number specified'];
               
                end
                
                % Connect peaks with lines --------------
                
                lines(n_beams) = struct(); % initialze struct for line segments
                
                hold(app.UIAxes_ch, 'on')
                l=gobjects(size(peak_coords, 1)); % initialize graphics handle array
                for a = 1:n_beams
                    lines(a).xcoords = [peak_coords(a,1), peak_coords(a+n_beams,1)]; % get x vertices
                    lines(a).ycoords = [peak_coords(a,2), peak_coords(a+n_beams,2)]; % get y vertices
                    l(a) = plot(app.UIAxes_ch, lines(a).xcoords, lines(a).ycoords,'r-', 'Linewidth', 2);
                end
                hold(app.UIAxes_ch, 'off')
                
                % Find intersection points of lines ----------------
                n_interx = (n_beams^2 - n_beams)/2; % maximum number of intersection points
                interx_idxs = nchoosek(1:n_beams, 2); % gets all combinations of beams intersecting
                p_interx = zeros(n_interx, 2); % init array of intersection points
                for i = 1:n_interx
                    ind1 = interx_idxs(i, 1);
                    ind2 = interx_idxs(i, 2);
                    
                    temp = InterX([lines(ind1).xcoords; lines(ind1).ycoords], ...
                        [lines(ind2).xcoords; lines(ind2).ycoords]);
                    p_interx(i,:) = temp';
                end
                
                % Plot lines on Cherenkov image ------------------
                hold(app.UIAxes_ch, 'on')
                p=gobjects(size(peak_coords, 1)); % initialize graphics handle array
                for a = 1:n_interx
                    p(a) = plot(app.UIAxes_ch, p_interx(a,1), p_interx(a,2),'b*');
                end
                hold(app.UIAxes_ch, 'off')
                
                % Search for min circle w/ 1 px steps------------------

                avg_interx = median(p_interx, 1); % find median of all intersection points
            
                [X,Y] = meshgrid(avg_interx(1)-25:avg_interx(1)+25, avg_interx(2)-25:avg_interx(2)+25);
                grid_n = size(X,1)^2;
                dists = zeros(grid_n, n_beams); % distance for every grid point to each line
                max_dists = zeros(grid_n, 1); % maximum distance for each grid point
                for i = 1:grid_n
                    for j = 1:n_beams
                        dists(i, j) = point_to_line_distance([X(i), Y(i)], ...
                            [lines(j).xcoords(1), lines(j).ycoords(1)], ...
                            [lines(j).xcoords(2), lines(j).ycoords(2)]); % calculate distance to each line
                    end
                    max_dists(i) = max(dists(i,:)); % find max for that point
                end
                
                [~, center_idx] = min(max_dists);
                app.min_circ_c = [X(center_idx), Y(center_idx)];
                
                % Search for min circle w/ 0.01 px steps------------------
                
                [X,Y] = meshgrid(app.min_circ_c(1)-0.25:0.01:app.min_circ_c(1)+0.25, app.min_circ_c(2)-0.25:0.01:app.min_circ_c(2)+0.25);
                grid_n = size(X,1)^2;
                dists = zeros(grid_n, n_beams); % distance for every grid point to each line
                max_dists = zeros(grid_n, 1); % maximum distance for each grid point
                for i = 1:grid_n
                    for j = 1:n_beams
                        dists(i, j) = point_to_line_distance([X(i), Y(i)], ...
                            [lines(j).xcoords(1), lines(j).ycoords(1)], ...
                            [lines(j).xcoords(2), lines(j).ycoords(2)]); % calculate distance to each line
                    end
                    max_dists(i) = max(dists(i,:)); % find max for that point
                end
                
                [app.min_circ_r, center_idx] = min(max_dists);
                app.min_circ_c = [X(center_idx), Y(center_idx)];
                
                % Plot min circle -----------------
                h = drawMinCircle(app, app.min_circ_c(1), app.min_circ_c(2), app.min_circ_r);

                % Display min circle radius
                app.MinimumCircleRadiusValue.Text = [num2str(app.min_circ_r*app.pixelsize, 2), ' mm'];
                disp(num2str(app.min_circ_c))
                % Allow Y-alignment
                app.isXZdone = 1;
                app.YAlignmentWarning.Text = '';
            end
            
            
        end

        % Button pushed function: CalculateResultsButton
        function CalculateResultsButtonPushed(app, event)
            if app.isXZdone == 1
                % Calculate x,z RT to phant diffs ---------------
                app.RT_MR_dx = app.pixelsize*(app.min_circ_c(1) - app.imcent(1));
                app.RT_MR_dz = app.pixelsize*(app.min_circ_c(2) - app.imcent(2));
            end
            % Calculate y RT to phantom diff ----------------
            if app.isYDone == 1
                diam_diffs_calib = app.optical_diams_calib - app.background_ring_diam_calib;
                    % prepare fit
                [xData, yData] = prepareCurveData( diam_diffs_calib, app.y_vals_calib );
                ft = fittype( 'poly1' );
                    % Fit model to data
                [fitresult, gof] = fit( xData, yData, ft );
                coefs = coeffvalues(fitresult);
                p1 = coefs(1);
                p2 = coefs(2);
                    % get diam diff
                diam_diff = app.optical_diam - app.bkg_ring_diam;
                app.RT_MR_dy = -(p1*diam_diff+p2); % negative because of paradigm
            end

            % Calculate 3D RT to MR diffs -----------------
            app.RT_MR_dr = sqrt(sum([app.RT_MR_dx, app.RT_MR_dy, app.RT_MR_dz].^2));
            
            
            % Update text displays
            app.RT_MR_dx_Label.Text = num2str(app.RT_MR_dx,'%2.2f');
            if abs(app.RT_MR_dx) < 2;
                app.RT_MR_dx_Label.FontColor = 'g';
            else
                app.RT_MR_dx_Label.FontColor = 'r';
            end
            app.RT_MR_dy_Label.Text = num2str(app.RT_MR_dy,'%2.2f');
            if abs(app.RT_MR_dy) < 2;
                app.RT_MR_dy_Label.FontColor = 'g';
            else
                app.RT_MR_dy_Label.FontColor = 'r';
            end
            app.RT_MR_dz_Label.Text = num2str(app.RT_MR_dz,'%2.2f');
            if abs(app.RT_MR_dz) < 2;
                app.RT_MR_dz_Label.FontColor = 'g';
            else
                app.RT_MR_dz_Label.FontColor = 'r';
            end
            app.RT_MR_dr_Label.Text = num2str(app.RT_MR_dr,'%2.2f');
            if abs(app.RT_MR_dr) < 2;
                app.RT_MR_dr_Label.FontColor = 'g';
            else
                app.RT_MR_dr_Label.FontColor = 'r';
            end
            
            
            
        end

        % Callback function
        function UpdateMRShiftsButtonPushed(app, event)
            app.MR_shifts(1) = app.MRShift_x_EditField.Value*-10; % convert from cm to mm, and change sign
            app.MR_shifts(2) = app.MRShift_y_EditField.Value*-10;
            app.MR_shifts(3) = app.MRShift_z_EditField.Value*-10; 
            app.UpdateMRShiftsButton.Text = 'Updated!';
            app.MRShiftWarningLabel.Text = '';
            app.areShiftsUpdated = 1;
            pause(2)
            app.UpdateMRShiftsButton.Text = 'Update';
        end

        % Button pushed function: ResetCherenkovImageButton
        function ResetCherenkovImageButtonPushed(app, event)
            if app.isLoaded_xz
                % Reset Cherenkov Figure (must update if changed in UI!
                delete(app.UIAxes_ch)
                app.UIAxes_ch = uiaxes(app.XZAlignmentTab);
                title(app.UIAxes_ch, 'Cherenkov Image')
                xlabel(app.UIAxes_ch, '')
                ylabel(app.UIAxes_ch, '')
                app.UIAxes_ch.DataAspectRatio = [1 1 1];
                app.UIAxes_ch.PlotBoxAspectRatio = [4 3 1];
                set(app.UIAxes_ch, 'PlotBoxAspectRatio', [size(app.ch_im_xz, 2), size(app.ch_im_xz, 1), 1])
                app.UIAxes_ch.FontSize = 16;
                app.UIAxes_ch.Box = 'on';
                app.UIAxes_ch.XTick = [];
                app.UIAxes_ch.YTick = [];
                app.UIAxes_ch.Color = [0 0 0];
                app.UIAxes_ch.Title.Color = 'w';
                app.UIAxes_ch.BackgroundColor = [0.149 0.149 0.149];
                app.UIAxes_ch.Position = [563 66 662 395];
                imagesc(app.UIAxes_ch, app.ch_im_xz)
                
                
                % Reset Profile figure
                delete(app.UIAxes_prof)
                app.UIAxes_prof = uiaxes(app.XZAlignmentTab);
                title(app.UIAxes_prof, 'Circular Starshot Profile')
                xlabel(app.UIAxes_prof, 'Angle (degrees)')
                ylabel(app.UIAxes_prof, 'Intensity')
                app.UIAxes_prof.PlotBoxAspectRatio = [3.22480620155039 1 1];
                app.UIAxes_prof.FontSize = 16;
                app.UIAxes_prof.XLim = [0 360];
                app.UIAxes_prof.GridColor = [1 1 1];
                app.UIAxes_prof.MinorGridColor = [1 1 1];
                app.UIAxes_prof.XColor = [1 1 1];
                app.UIAxes_prof.XTick = [0 60 120 180 240 300 360];
                app.UIAxes_prof.XTickLabel = {'0'; '60'; '120'; '180'; '240'; '300'; '360'};
                app.UIAxes_prof.YColor = [1 1 1];
                app.UIAxes_prof.Color = [0 0 0];
                app.UIAxes_prof.Title.Color = 'w';
                app.UIAxes_prof.XGrid = 'on';
                app.UIAxes_prof.YGrid = 'on';
                app.UIAxes_prof.BackgroundColor = [0.149 0.149 0.149];
                app.UIAxes_prof.Position = [32 127 465 205];
            end
        end

        % Button pushed function: BrowsetoFolderButton_4
        function BrowsetoFolderButton_4Pushed(app, event)
            app.BrowsetoFolderButton_4.Text = 'Loading...';
            if app.defaultpath ~= 0
                path = uigetdir(app.defaultpath, 'Select Data Folder');
            else
                path = uigetdir(pwd, 'Select Data Folder');
            end
            dirContents = dir(path);
            
            % Check for dovi files
            hasDovi = 0;
            for i=1:numel(dirContents)
                if contains(dirContents(i).name, '.dovi')
                    hasDovi = hasDovi + 1;
                end
            end
            
            % load images
            if hasDovi > 0
                temp = sum(read_dovi(fullfile(path,'meas_s0_cam0.dovi')),3);
                app.ff = temp./(max(temp(:)));
                FF = app.ff;
                save(fullfile(userpath, 'VIPER', 'calib_files', 'FF.mat'), 'FF');
                app.FFStatusLabel.Text = 'Restart Program to Apply FF Correction';
                app.FFStatusLabel_2.Text = 'Restart Program to Apply FF Correction';
                app.isff = 1;
                app.BrowsetoFolderButton_4.Text = 'Loaded Successfully';
                pause(2)
                app.BrowsetoFolderButton_4.Text = 'Browse to Folder';
            else
                app.BrowsetoFolderButton_4.Text = 'No Files Found';
                pause(2)
                app.BrowsetoFolderButton_4.Text = 'Browse to Folder';
            end
            
        end

        % Button pushed function: ResetBackgroundImageButton
        function ResetBackgroundImageButtonPushed(app, event)
            if app.isLoaded_xz
                delete(app.UIAxes_bkg)
                app.UIAxes_bkg = uiaxes(app.XZAlignmentTab);
                title(app.UIAxes_bkg, 'Background Image')
                xlabel(app.UIAxes_bkg, '')
                ylabel(app.UIAxes_bkg, '')
                app.UIAxes_bkg.DataAspectRatio = [1 1 1];
                set(app.UIAxes_bkg, 'PlotBoxAspectRatio', [size(app.bkg_im_xz, 2), size(app.bkg_im_xz, 1), 1])
                app.UIAxes_bkg.FontSize = 16;
                app.UIAxes_bkg.Box = 'on';
                app.UIAxes_bkg.XTick = [];
                app.UIAxes_bkg.YTick = [];
                app.UIAxes_bkg.Color = [0 0 0];
                app.UIAxes_bkg.Title.Color = 'w';
                app.UIAxes_bkg.BackgroundColor = [0.149 0.149 0.149];
                app.UIAxes_bkg.Position = [563 468 662 395];
                imagesc(app.UIAxes_bkg, app.bkg_im_xz)
                colormap(app.UIAxes_bkg, gray)
            end
        end

        % Button pushed function: SavePixelSizeButton
        function SavePixelSizeButtonPushed(app, event)
            if strcmp(app.SavePixelSizeCheck.Value,'Yes')
                PixelSize = app.PixelSizeSpinner.Value;
                app.pixelsize = PixelSize;
                save(fullfile(userpath, 'VIPER', 'calib_files','PixelSize.mat'), 'PixelSize');
                app.SavePixelSizeStatusLabel.FontColor = 'g';
                app.SavePixelSizeStatusLabel.Text = 'Saved';
                pause(5)
                app.SavePixelSizeStatusLabel.Text = '';
                app.ispx = 1;
                app.AnalyzeMessage.Text = '';
            else
                app.SavePixelSizeStatusLabel.FontColor = 'r';
                app.SavePixelSizeStatusLabel.Text = 'Not saved';
            end
        end

        % Callback function
        function HelpButtonXZPushed(app, event)
            msg = ['Load Images: In the box that opens, browse to the folder that contains the desired starshot dataset, and click select.', ...
                char(10),char(10),'Find Phantom Center: On the background image window, you can hover near the top right of the image and click the ', ...
                'zoom magnifying glass, and then select a region around the visible crosshair at the center of the phantom. Next, unclick the the ',...
                'zoom magnifying glass, and click the ''Click Crosshair button''. You''ll notice a new cursor over the background image; simply click ',...
                'at the center of the crosshair, and coordinates will display on the screen.',...
                char(10),char(10), 'Position ROI:', ...
                newline,char(10), 'Analyze Starshot:', ...
                char(10),char(10), 'Minimum Circle Radius', ...
                char(10),char(10), 'Reset Images:'];
            helpdlg(msg,'XZ Calibration pane: Help')
        end

        % Button pushed function: BrowsetoFolderButton_2
        function BrowsetoFolderButton_2Pushed(app, event)
            app.BrowsetoFolderButton_2.Text = 'Loading...';
%             set(app.VIPERUIFigure, 'Pointer','watch');
%             drawnow;
            
%             app.VIPERUIFigure.Visible = 'off';
            if app.defaultpath ~= 0
                path = uigetdir(app.defaultpath, 'Select Data Folder');
            else
                path = uigetdir(pwd, 'Select Data Folder');
            end
%             app.VIPERUIFigure.Visible = 'on';
            if path ~= 0
                dirContents = dir(path);
                
                % Check for dovi files
                hasDovi = 0;
                hasMat = 0;
                hasPNG = 0;
                matFile = '';
                for i=1:numel(dirContents)
                    if contains(dirContents(i).name, '.dovi')
                        hasDovi = hasDovi +1;
                    end
                    if contains(dirContents(i).name, '.mat')
                        matFile = dirContents(i).name;
                        hasMat = hasMat+1;
                    end
                    if contains(dirContents(i).name, 'meas') && contains(dirContents(i).name, '.png')
                        hasPNG = hasPNG+1;
                    end
                end
                
                % load images
                if (hasDovi+hasMat+hasPNG > 0) 
                    
                    % Check for png files, then mat files, then dovi files
                    if hasPNG > 0
                        app.ch_im_y = flip(double(imread(fullfile(path,'meas_s1_cam0.png'))),1);
                        app.bkg_im_y = flip(double(imread(fullfile(path,'meas_s0_cam0.png'))),1);
                    elseif hasMat > 0
                        matVars = load(fullfile(path,matFile));
                        app.ch_im_y = matVars.im1;
                        app.bkg_im_y = matVars.im0;
                    else
                        app.ch_im_y = sum(read_dovi(fullfile(path,'meas_s1_cam0.dovi')),3);
                        app.bkg_im_y = sum(read_dovi(fullfile(path,'meas_s0_cam0.dovi')),3);
                        % save mat file for next time
                        im1 = app.ch_im_y;
                        im0 = app.bkg_im_y;
                        save(fullfile(path,'summed_images.mat'), 'im1', 'im0');
                    end
                    
                    % Get rid of readout pixels
                    app.ch_im_y(1,:) = app.ch_im_y(2,:);
                    app.bkg_im_y(1,:) = app.bkg_im_y(2,:);
                            
                    if app.isff
                        if size(app.ff, 2) == size(app.ch_im_y, 2)
                            app.ch_im_y = app.ch_im_y./app.ff;
                            app.bkg_im_y = app.bkg_im_y./app.ff;
                            app.FFStatusLabel_2.Text = '';
                        else
                            app.FFStatusLabel_2.Text = ['Warning: Flatfield dimension mismatch.' newline, 'Flatfield correction is disabled.'];
                        end
                    else
                        app.FFStatusLabel_2.Text = ['Warning: No flatfield found.' newline, 'Flatfield correction is disabled.'];
                    end
                    
                    imagesc(app.UIAxes_bkg_2, app.bkg_im_y)
                    colormap(app.UIAxes_bkg_2, gray)
                    set(app.UIAxes_bkg_2, 'PlotBoxAspectRatio', [size(app.bkg_im_y, 2), size(app.bkg_im_y, 1), 1])
                    
                    
                    imagesc(app.UIAxes_ch_2, app.ch_im_y);
    %                 colormap(app.UIAxes_ch, jet)
%                     if strcmp(app.DropDown.Value,'4x3')
%                         set(app.UIAxes_ch, 'PlotBoxAspectRatio', [4 3 1])
%                     elseif strcmp(app.DropDown.Value,'16x10')
%                         set(app.UIAxes_ch, 'PlotBoxAspectRatio', [16 10 1])
%                     end
                    
    %                 max_window_width = max(app.ch_im_xz(:))-min(app.ch_im_xz(:));
%                     curr_lims = app.UIAxes_ch.CLim;
                    set(app.UIAxes_ch_2, 'PlotBoxAspectRatio', [size(app.ch_im_y, 2), size(app.ch_im_y, 1), 1])
                    
                    
%                     app.WindowSlider_ch.Limits = [0, 1];
%                     app.WindowSlider_ch.Value = 0.5;
%                     app.LevelSlider_ch.Limits = [0, 1];
%                     app.LevelSlider_ch.Value = 0.5;
                    
                    app.isLoaded_y = 1;
    %                 set(app.VIPERUIFigure, 'Pointer','arrow');
                    app.BrowsetoFolderButton_2.Text = 'Browse to Folder';
                    
                elseif hasDovi == 0
                    app.BrowsetoFolderButton_2.Text = 'No Files Found';
                    app.isLoaded_y = 0;
                    pause(2)
    %                 set(app.VIPERUIFigure, 'Pointer','arrow');
                    app.BrowsetoFolderButton_2.Text = 'Browse to Folder';
                    
                elseif hasDovi == 1
                    app.BrowsetoFolderButton_2.Text = 'Missing Files';
                    app.isLoaded_y = 0;
                    pause(2)
    %                 set(app.VIPERUIFigure, 'Pointer','arrow');
                    app.BrowsetoFolderButton_2.Text = 'Browse to Folder';
                end
            else
                app.BrowsetoFolderButton_2.Text = 'Cancelled';
                app.isLoaded_y = 0;
                pause(2)
%                 set(app.VIPERUIFigure, 'Pointer','arrow');
                app.BrowsetoFolderButton_2.Text = 'Browse to Folder';
            end
        end

        % Callback function
        function SaveOffsetValuesButtonPushed(app, event)
            if strcmp(app.SaveOffsetValuesCheck.Value,'Yes')
                x = app.PhantOffset_x.Value*10; % convert to mm
                y = app.PhantOffset_y.Value*10;
                z = app.PhantOffset_z.Value*10;
                PhantomOffsets = [x,y,z];
                app.phantomoffsets = PhantomOffsets;
                save(fullfile(userpath, 'VIPER', 'calib_files','PhantomOffsets.mat'), 'PhantomOffsets');
                app.SaveOffsetValuesStatusLabel.FontColor = 'g';
                app.SaveOffsetValuesStatusLabel.Text = 'Saved';
                pause(5)
                app.SaveOffsetValuesStatusLabel.Text = '';
                app.isOffset = 1;
                app.PhantOffsetMissingLabel.Text = '';
            else
                app.SaveOffsetValuesStatusLabel.FontColor = 'r';
                app.SaveOffsetValuesStatusLabel.Text = 'Not saved';
            end
        end

        % Button pushed function: PositionROIButton_2
        function PositionROIButton_2Pushed(app, event)
            if app.isXZdone > 0
                if app.isLoaded_y == 0
                    app.PositionROIButton_2.Text = 'No Images Loaded';
                    pause(2)
                    app.PositionROIButton_2.Text = 'Position ROI';
                else
                    
                    circ = drawcircle(app.UIAxes_bkg_2,'LineWidth', 1); 
                    app.bkg_ring_center = [round(circ.Center(1)), round(circ.Center(2))];
                    bkg_ring_radius = circ.Radius;
                    delete(circ)
                    % Find the actual ring based on dark circle
                    p = app.imcent;
                    ring_delta_mm = 10; % in each direction
                    ring_delta_px = round(ring_delta_mm/app.pixelsize);
                    
                    radii = bkg_ring_radius + (-ring_delta_px:ring_delta_px);
                    CircVerts_default = circlepoints(round(p(1)), round(p(2)), round(bkg_ring_radius));
                    len_default = numel(CircVerts_default(:,1));
                    
                    CircVerts = zeros(len_default, 2, numel(radii)); % index, then x or y (1 or 2), then radius
                    
                    for r = 1:numel(radii)
                        temp = circlepoints(round(p(1)), round(p(2)), round(radii(r)));
                        len = numel(temp(:,1));
                        CircVerts(:,1,r) = inpaint_nans(interp1(1:len, temp(:,1), 1:len_default)); % interpolate x
                        CircVerts(:,2,r) = inpaint_nans(interp1(1:len, temp(:,2), 1:len_default)); % interpolate y
                    end
                    
                    % Circverts = inpaint_nans(CircVerts);
                    
                    profs = zeros(numel(radii), len_default);
                    
                    for i = 1:len_default
                        temp = zeros(numel(radii), 1);
                        for r = 1:numel(radii)
                            temp(r,1) = app.bkg_im_y(CircVerts(i,2,r), CircVerts(i,1,r));
                        end
                        profs(:, i) = temp;
                    end
                    
                    mean_prof = mean(profs, 2);
                    mean_prof = mat2gray(-mean_prof);
                    [~, array_idx, ~, proms] = findpeaks(mean_prof); % values, indeces, widths, promineces
                    peak_idx = proms >= max(proms(:)); % find max prominent peak
                    array_idx = array_idx(peak_idx)';
                    peak_rad = radii(array_idx);
                    
                    
                    app.bkg_ring_diam = 2*peak_rad*app.pixelsize;
                    
                    app.CenterCoordlabel_2.Text = ['Center = ',num2str(app.bkg_ring_center), char(10), 'Diameter = ',num2str(app.bkg_ring_diam, '%2.2f'), ' mm'];
                    app.PositionROIButton.Text = 'Position ROI';
                    app.isRing = 1;
                end
            else
                app.PositionROIButton_2.Text = 'Finish X-Z';
                pause(2)
                app.PositionROIButton_2.Text = 'Position ROI';
            end
        end

        % Callback function
        function HelpButtonCalib_2Pushed(app, event)
            msg = ['Coming soon'];
            helpdlg(msg,'Ring Daiameter Calibration: Help')
        end

        % Button pushed function: SaveYCalibButton
        function SaveYCalibButtonPushed(app, event)
            if strcmp(app.SaveYCalibCheck.Value,'Yes')
                YVals = [-5, -2.5, -1, 0, 1, 2.5, 5];
                OpticalDiams = str2num(app.RingDiameterCalib.Value);
                BackgroundRingDiam = app.BkgRingDiameter.Value;
                if isempty(OpticalDiams) || (numel(OpticalDiams) ~= numel(YVals))
                    app.OpticalDiamsFormatWarning.Text = 'Warning: Incorrect format';
                else
                    save(fullfile(userpath, 'VIPER', 'calib_files','RingCalibration.mat'), 'YVals', 'OpticalDiams', 'BackgroundRingDiam');
                    app.y_vals_calib = YVals;
                    app.optical_diams_calib = OpticalDiams;
                    app.background_ring_diam_calib = BackgroundRingDiam; 
                    app.SaveYCalibStatusLabel.FontColor = 'g';
                    app.SaveYCalibStatusLabel.Text = 'Saved';
                    pause(5)
                    app.SaveYCalibStatusLabel.Text = '';
                    app.isRingCalib = 1;
    %                 app.PhantOffsetMissingLabel.Text = '';
                    app.OpticalDiamsFormatWarning.Text = '';
                end
            else
                app.SaveYCalibStatusLabel.FontColor = 'r';
                app.SaveYCalibStatusLabel.Text = 'Not saved';
            end
        end

        % Value changed function: RingDiameterCalib
        function RingDiameterCalibValueChanged(app, event)
            value = str2num(app.RingDiameterCalib.Value);
            if isempty(value) || (numel(value) ~= 7)
                app.OpticalDiamsFormatWarning.Text = 'Warning: Incorrect format';
            else
                app.OpticalDiamsFormatWarning.Text = '';
            end
        end

        % Button pushed function: CalcOpticalDiamButton
        function CalcOpticalDiamButtonPushed(app, event)
            if app.isRing ==1
                rad_mm = 70; % 70 mm profile
                rad = round(rad_mm/app.pixelsize); % convert to pixels
                divs = 100;
                
                [xends,yends] = pol2cart(linspace(0, 2*pi, divs), rad);
                xends = xends + app.imcent(1);
                yends = yends + app.imcent(2);
                
                profs_raw = zeros(divs, rad);
                
                for i = 1:divs
                    prof = improfile(app.ch_im_y, [app.imcent(1), xends(i)], [app.imcent(2), yends(i)], rad);
                    profs_raw(i,:) = prof;
    
                end
                prof_mean = mean(profs_raw, 1);
                [~, rise, fall] = fwhm(1:rad, prof_mean, 0.40);
                radius = mean([rise,fall]);
                app.optical_diam  = radius*app.pixelsize*2; % get average radius and double for diameter
                h = drawRingCircle(app, app.imcent(1), app.imcent(2), radius);
                app.OpticalDiamLabel.Text = ['Optical Diameter = ', num2str(app.optical_diam, '%2.2f'), ' mm'];
                app.isYDone = 1;
            else
                app.OpticalDiamLabel.Text = 'Complete previous step'
            end
        end

        % Button pushed function: ResetCherenkovImageButton_2
        function ResetCherenkovImageButton_2Pushed(app, event)
            if app.isLoaded_y
                % Reset Cherenkov Figure (must update if changed in UI!
                delete(app.UIAxes_ch_2)
                app.UIAxes_ch_2 = uiaxes(app.YAlignmentTab);
                title(app.UIAxes_ch_2, 'Cherenkov Image')
                xlabel(app.UIAxes_ch_2, '')
                ylabel(app.UIAxes_ch_2, '')
                app.UIAxes_ch_2.DataAspectRatio = [1 1 1];
                set(app.UIAxes_ch_2, 'PlotBoxAspectRatio', [size(app.ch_im_y, 2), size(app.ch_im_y, 1), 1])
                app.UIAxes_ch_2.FontSize = 16;
                app.UIAxes_ch_2.Box = 'on';
                app.UIAxes_ch_2.XTick = [];
                app.UIAxes_ch_2.YTick = [];
                app.UIAxes_ch_2.Color = [0 0 0];
                app.UIAxes_ch_2.Title.Color = 'w';
                app.UIAxes_ch_2.BackgroundColor = [0.149 0.149 0.149];
                app.UIAxes_ch_2.Position = [563 66 662 395];
                imagesc(app.UIAxes_ch_2, app.ch_im_y)
            end
        end

        % Button pushed function: ResetBackgroundImageButton_2
        function ResetBackgroundImageButton_2Pushed(app, event)
            if app.isLoaded_y
                % Reset Cherenkov Figure (must update if changed in UI!
                delete(app.UIAxes_bkg_2)
                app.UIAxes_bkg_2 = uiaxes(app.YAlignmentTab);
                title(app.UIAxes_bkg_2, 'Background Image')
                xlabel(app.UIAxes_bkg_2, '')
                ylabel(app.UIAxes_bkg_2, '')
                app.UIAxes_bkg_2.DataAspectRatio = [1 1 1];
                set(app.UIAxes_bkg_2, 'PlotBoxAspectRatio', [size(app.ch_im_y, 2), size(app.ch_im_y, 1), 1])
                app.UIAxes_bkg_2.FontSize = 16;
                app.UIAxes_bkg_2.Box = 'on';
                app.UIAxes_bkg_2.XTick = [];
                app.UIAxes_bkg_2.YTick = [];
                app.UIAxes_bkg_2.Color = [0 0 0];
                app.UIAxes_bkg_2.Title.Color = 'w';
                app.UIAxes_bkg_2.BackgroundColor = [0.149 0.149 0.149];
                app.UIAxes_bkg_2.Position = [563 468 662 395];
                imagesc(app.UIAxes_bkg_2, app.bkg_im_y)
                colormap(app.UIAxes_bkg_2, gray);
            end
            
        end

        % Button pushed function: SavePathButton
        function SavePathButtonPushed(app, event)
            DefaultPath = app.DefaultDataPathField.Value;
            save(fullfile(userpath, 'VIPER', 'calib_files','DefaultPath.mat'), 'DefaultPath');
            app.defaultpath = DefaultPath;
            app.SavePathStatusLabel.FontColor = 'g';
            app.SavePathStatusLabel.Text = 'Saved';
            pause(5)
            app.SavePathStatusLabel.Text = '';
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create VIPERUIFigure and hide until all components are created
            app.VIPERUIFigure = uifigure('Visible', 'off');
            app.VIPERUIFigure.Color = [0.502 0.502 0.502];
            app.VIPERUIFigure.Position = [100 100 1234 900];
            app.VIPERUIFigure.Name = 'VIPER 1.0';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.VIPERUIFigure);
            app.TabGroup.Position = [1 1 1234 900];

            % Create XZAlignmentTab
            app.XZAlignmentTab = uitab(app.TabGroup);
            app.XZAlignmentTab.Title = 'X-Z Alignment';
            app.XZAlignmentTab.BackgroundColor = [0.149 0.149 0.149];

            % Create BrowsetoFolderButton_1
            app.BrowsetoFolderButton_1 = uibutton(app.XZAlignmentTab, 'push');
            app.BrowsetoFolderButton_1.ButtonPushedFcn = createCallbackFcn(app, @BrowsetoFolderButton_1Pushed, true);
            app.BrowsetoFolderButton_1.BackgroundColor = [0.502 0.502 0.502];
            app.BrowsetoFolderButton_1.FontSize = 16;
            app.BrowsetoFolderButton_1.FontColor = [1 1 1];
            app.BrowsetoFolderButton_1.Position = [215 818 138 27];
            app.BrowsetoFolderButton_1.Text = 'Browse to Folder';

            % Create PositionROILabel
            app.PositionROILabel = uilabel(app.XZAlignmentTab);
            app.PositionROILabel.FontSize = 16;
            app.PositionROILabel.FontColor = [1 1 1];
            app.PositionROILabel.Position = [14 629 131 23];
            app.PositionROILabel.Text = '1.c.) Position ROI';

            % Create AnalyzeStarshotLabel
            app.AnalyzeStarshotLabel = uilabel(app.XZAlignmentTab);
            app.AnalyzeStarshotLabel.FontSize = 16;
            app.AnalyzeStarshotLabel.FontColor = [1 1 1];
            app.AnalyzeStarshotLabel.Position = [14 514 163 23];
            app.AnalyzeStarshotLabel.Text = '1.d.) Analyze Starshot';

            % Create PositionROIButton
            app.PositionROIButton = uibutton(app.XZAlignmentTab, 'push');
            app.PositionROIButton.ButtonPushedFcn = createCallbackFcn(app, @PositionROIButtonPushed, true);
            app.PositionROIButton.BackgroundColor = [0.502 0.502 0.502];
            app.PositionROIButton.FontSize = 16;
            app.PositionROIButton.FontColor = [1 1 1];
            app.PositionROIButton.Position = [215 627 134 27];
            app.PositionROIButton.Text = 'Position ROI';

            % Create FindPhantomCenterLabel
            app.FindPhantomCenterLabel = uilabel(app.XZAlignmentTab);
            app.FindPhantomCenterLabel.FontSize = 16;
            app.FindPhantomCenterLabel.FontColor = [1 1 1];
            app.FindPhantomCenterLabel.Position = [14 732 195 23];
            app.FindPhantomCenterLabel.Text = '1.b.) Find Phantom Center';

            % Create ClickCrosshairButton
            app.ClickCrosshairButton = uibutton(app.XZAlignmentTab, 'push');
            app.ClickCrosshairButton.ButtonPushedFcn = createCallbackFcn(app, @ClickCrosshairButtonPushed, true);
            app.ClickCrosshairButton.BackgroundColor = [0.502 0.502 0.502];
            app.ClickCrosshairButton.FontSize = 16;
            app.ClickCrosshairButton.FontColor = [1 1 1];
            app.ClickCrosshairButton.Position = [215 730 134 27];
            app.ClickCrosshairButton.Text = 'Click Crosshair';

            % Create AnalyzeStarshotButton
            app.AnalyzeStarshotButton = uibutton(app.XZAlignmentTab, 'push');
            app.AnalyzeStarshotButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeStarshotButtonPushed, true);
            app.AnalyzeStarshotButton.BackgroundColor = [0.502 0.502 0.502];
            app.AnalyzeStarshotButton.FontSize = 16;
            app.AnalyzeStarshotButton.FontColor = [1 1 1];
            app.AnalyzeStarshotButton.Position = [215 512 136 27];
            app.AnalyzeStarshotButton.Text = 'Analyze Starshot';

            % Create AnalyzeMessage
            app.AnalyzeMessage = uilabel(app.XZAlignmentTab);
            app.AnalyzeMessage.FontSize = 16;
            app.AnalyzeMessage.FontColor = [1 0.4118 0.1608];
            app.AnalyzeMessage.Position = [164 451 310 51];
            app.AnalyzeMessage.Text = '';

            % Create MinimumCircleRadiusLabel
            app.MinimumCircleRadiusLabel = uilabel(app.XZAlignmentTab);
            app.MinimumCircleRadiusLabel.FontSize = 16;
            app.MinimumCircleRadiusLabel.FontColor = [1 1 1];
            app.MinimumCircleRadiusLabel.Position = [14 398 226 23];
            app.MinimumCircleRadiusLabel.Text = '1.e.) Minimum Circle Radius  =';

            % Create MinimumCircleRadiusValue
            app.MinimumCircleRadiusValue = uilabel(app.XZAlignmentTab);
            app.MinimumCircleRadiusValue.FontSize = 16;
            app.MinimumCircleRadiusValue.FontColor = [1 1 1];
            app.MinimumCircleRadiusValue.Position = [241 397 156 23];
            app.MinimumCircleRadiusValue.Text = '';

            % Create ofbeamsEditFieldLabel
            app.ofbeamsEditFieldLabel = uilabel(app.XZAlignmentTab);
            app.ofbeamsEditFieldLabel.HorizontalAlignment = 'right';
            app.ofbeamsEditFieldLabel.FontSize = 16;
            app.ofbeamsEditFieldLabel.FontColor = [1 1 1];
            app.ofbeamsEditFieldLabel.Position = [30 488 86 23];
            app.ofbeamsEditFieldLabel.Text = '# of beams';

            % Create NofbeamsEditField
            app.NofbeamsEditField = uieditfield(app.XZAlignmentTab, 'numeric');
            app.NofbeamsEditField.FontSize = 16;
            app.NofbeamsEditField.Position = [123 488 30 22];
            app.NofbeamsEditField.Value = 5;

            % Create ResetCherenkovImageButton
            app.ResetCherenkovImageButton = uibutton(app.XZAlignmentTab, 'push');
            app.ResetCherenkovImageButton.ButtonPushedFcn = createCallbackFcn(app, @ResetCherenkovImageButtonPushed, true);
            app.ResetCherenkovImageButton.BackgroundColor = [0.502 0.502 0.502];
            app.ResetCherenkovImageButton.FontSize = 16;
            app.ResetCherenkovImageButton.FontWeight = 'bold';
            app.ResetCherenkovImageButton.FontColor = [1 1 1];
            app.ResetCherenkovImageButton.Position = [59 66 199 28];
            app.ResetCherenkovImageButton.Text = 'Reset Cherenkov Image';

            % Create ResetBackgroundImageButton
            app.ResetBackgroundImageButton = uibutton(app.XZAlignmentTab, 'push');
            app.ResetBackgroundImageButton.ButtonPushedFcn = createCallbackFcn(app, @ResetBackgroundImageButtonPushed, true);
            app.ResetBackgroundImageButton.BackgroundColor = [0.502 0.502 0.502];
            app.ResetBackgroundImageButton.FontSize = 16;
            app.ResetBackgroundImageButton.FontWeight = 'bold';
            app.ResetBackgroundImageButton.FontColor = [1 1 1];
            app.ResetBackgroundImageButton.Position = [282 66 210 28];
            app.ResetBackgroundImageButton.Text = 'Reset Background Image';

            % Create FFStatusLabel
            app.FFStatusLabel = uilabel(app.XZAlignmentTab);
            app.FFStatusLabel.FontColor = [1 0.4118 0.1608];
            app.FFStatusLabel.Position = [56 776 240 36];
            app.FFStatusLabel.Text = '';

            % Create LoadImagesLabel
            app.LoadImagesLabel = uilabel(app.XZAlignmentTab);
            app.LoadImagesLabel.FontSize = 16;
            app.LoadImagesLabel.FontColor = [1 1 1];
            app.LoadImagesLabel.Position = [16 820 133 22];
            app.LoadImagesLabel.Text = '1.a.) Load Images';

            % Create CenterCoordlabel
            app.CenterCoordlabel = uilabel(app.XZAlignmentTab);
            app.CenterCoordlabel.FontColor = [1 1 1];
            app.CenterCoordlabel.Position = [358 732 264 22];
            app.CenterCoordlabel.Text = '';

            % Create UIAxes_prof
            app.UIAxes_prof = uiaxes(app.XZAlignmentTab);
            title(app.UIAxes_prof, 'Circular Starshot Profile')
            xlabel(app.UIAxes_prof, 'Angle (degrees)')
            ylabel(app.UIAxes_prof, 'Intensity')
            app.UIAxes_prof.PlotBoxAspectRatio = [3.22480620155039 1 1];
            app.UIAxes_prof.XLim = [0 360];
            app.UIAxes_prof.XColor = [1 1 1];
            app.UIAxes_prof.XTick = [0 60 120 180 240 300 360];
            app.UIAxes_prof.XTickLabel = {'0'; '60'; '120'; '180'; '240'; '300'; '360'};
            app.UIAxes_prof.YColor = [1 1 1];
            app.UIAxes_prof.Color = [0 0 0];
            app.UIAxes_prof.XGrid = 'on';
            app.UIAxes_prof.YGrid = 'on';
            app.UIAxes_prof.FontSize = 16;
            app.UIAxes_prof.GridColor = [1 1 1];
            app.UIAxes_prof.MinorGridColor = [1 1 1];
            app.UIAxes_prof.Position = [45 144 465 205];

            % Create UIAxes_bkg
            app.UIAxes_bkg = uiaxes(app.XZAlignmentTab);
            title(app.UIAxes_bkg, 'Background Image')
            app.UIAxes_bkg.DataAspectRatio = [1 1 1];
            app.UIAxes_bkg.PlotBoxAspectRatio = [4 3 1];
            app.UIAxes_bkg.XTick = [];
            app.UIAxes_bkg.YTick = [];
            app.UIAxes_bkg.Color = [0 0 0];
            app.UIAxes_bkg.FontSize = 16;
            app.UIAxes_bkg.Box = 'on';
            app.UIAxes_bkg.Position = [563 468 662 395];

            % Create UIAxes_ch
            app.UIAxes_ch = uiaxes(app.XZAlignmentTab);
            title(app.UIAxes_ch, 'Cherenkov Image')
            app.UIAxes_ch.DataAspectRatio = [1 1 1];
            app.UIAxes_ch.PlotBoxAspectRatio = [4 3 1];
            app.UIAxes_ch.XTick = [];
            app.UIAxes_ch.YTick = [];
            app.UIAxes_ch.Color = [0 0 0];
            app.UIAxes_ch.FontSize = 16;
            app.UIAxes_ch.Box = 'on';
            app.UIAxes_ch.Position = [563 66 662 395];

            % Create YAlignmentTab
            app.YAlignmentTab = uitab(app.TabGroup);
            app.YAlignmentTab.Title = 'Y Alignment';
            app.YAlignmentTab.BackgroundColor = [0.149 0.149 0.149];

            % Create BrowsetoFolderButton_2
            app.BrowsetoFolderButton_2 = uibutton(app.YAlignmentTab, 'push');
            app.BrowsetoFolderButton_2.ButtonPushedFcn = createCallbackFcn(app, @BrowsetoFolderButton_2Pushed, true);
            app.BrowsetoFolderButton_2.BackgroundColor = [0.502 0.502 0.502];
            app.BrowsetoFolderButton_2.FontSize = 16;
            app.BrowsetoFolderButton_2.FontColor = [1 1 1];
            app.BrowsetoFolderButton_2.Position = [253 811 138 27];
            app.BrowsetoFolderButton_2.Text = 'Browse to Folder';

            % Create FFStatusLabel_2
            app.FFStatusLabel_2 = uilabel(app.YAlignmentTab);
            app.FFStatusLabel_2.FontColor = [1 0.4118 0.1608];
            app.FFStatusLabel_2.Position = [56 776 240 36];
            app.FFStatusLabel_2.Text = '';

            % Create LoadImagesLabel_2
            app.LoadImagesLabel_2 = uilabel(app.YAlignmentTab);
            app.LoadImagesLabel_2.FontSize = 16;
            app.LoadImagesLabel_2.FontColor = [1 1 1];
            app.LoadImagesLabel_2.Position = [16 811 134 22];
            app.LoadImagesLabel_2.Text = '2.a.) Load Images';

            % Create YAlignmentWarning
            app.YAlignmentWarning = uilabel(app.YAlignmentTab);
            app.YAlignmentWarning.FontColor = [1 0.4118 0.1608];
            app.YAlignmentWarning.Position = [11 841 362 22];
            app.YAlignmentWarning.Text = 'Note: Please perform X-Z alignment before proceeding to this tab.';

            % Create LoadImagesLabel_3
            app.LoadImagesLabel_3 = uilabel(app.YAlignmentTab);
            app.LoadImagesLabel_3.FontSize = 16;
            app.LoadImagesLabel_3.FontColor = [1 1 1];
            app.LoadImagesLabel_3.Position = [16 715 221 22];
            app.LoadImagesLabel_3.Text = '2.b.) Outline Background Ring';

            % Create PositionROIButton_2
            app.PositionROIButton_2 = uibutton(app.YAlignmentTab, 'push');
            app.PositionROIButton_2.ButtonPushedFcn = createCallbackFcn(app, @PositionROIButton_2Pushed, true);
            app.PositionROIButton_2.BackgroundColor = [0.502 0.502 0.502];
            app.PositionROIButton_2.FontSize = 16;
            app.PositionROIButton_2.FontColor = [1 1 1];
            app.PositionROIButton_2.Position = [253 713 138 27];
            app.PositionROIButton_2.Text = 'Position ROI';

            % Create CenterCoordlabel_2
            app.CenterCoordlabel_2 = uilabel(app.YAlignmentTab);
            app.CenterCoordlabel_2.FontColor = [1 1 1];
            app.CenterCoordlabel_2.Position = [403 705 150 43];
            app.CenterCoordlabel_2.Text = '';

            % Create CalcOpticalDiamLabel
            app.CalcOpticalDiamLabel = uilabel(app.YAlignmentTab);
            app.CalcOpticalDiamLabel.FontSize = 16;
            app.CalcOpticalDiamLabel.FontColor = [1 1 1];
            app.CalcOpticalDiamLabel.Position = [14 618 233 22];
            app.CalcOpticalDiamLabel.Text = '2.c.) Calculate Optical Diameter';

            % Create CalcOpticalDiamButton
            app.CalcOpticalDiamButton = uibutton(app.YAlignmentTab, 'push');
            app.CalcOpticalDiamButton.ButtonPushedFcn = createCallbackFcn(app, @CalcOpticalDiamButtonPushed, true);
            app.CalcOpticalDiamButton.BackgroundColor = [0.502 0.502 0.502];
            app.CalcOpticalDiamButton.FontSize = 16;
            app.CalcOpticalDiamButton.FontColor = [1 1 1];
            app.CalcOpticalDiamButton.Position = [253 616 138 27];
            app.CalcOpticalDiamButton.Text = 'Calculate';

            % Create OpticalDiamLabel
            app.OpticalDiamLabel = uilabel(app.YAlignmentTab);
            app.OpticalDiamLabel.FontColor = [1 1 1];
            app.OpticalDiamLabel.Position = [401 607 214 43];
            app.OpticalDiamLabel.Text = '';

            % Create ResetCherenkovImageButton_2
            app.ResetCherenkovImageButton_2 = uibutton(app.YAlignmentTab, 'push');
            app.ResetCherenkovImageButton_2.ButtonPushedFcn = createCallbackFcn(app, @ResetCherenkovImageButton_2Pushed, true);
            app.ResetCherenkovImageButton_2.BackgroundColor = [0.502 0.502 0.502];
            app.ResetCherenkovImageButton_2.FontSize = 16;
            app.ResetCherenkovImageButton_2.FontWeight = 'bold';
            app.ResetCherenkovImageButton_2.FontColor = [1 1 1];
            app.ResetCherenkovImageButton_2.Position = [59 66 199 28];
            app.ResetCherenkovImageButton_2.Text = 'Reset Cherenkov Image';

            % Create ResetBackgroundImageButton_2
            app.ResetBackgroundImageButton_2 = uibutton(app.YAlignmentTab, 'push');
            app.ResetBackgroundImageButton_2.ButtonPushedFcn = createCallbackFcn(app, @ResetBackgroundImageButton_2Pushed, true);
            app.ResetBackgroundImageButton_2.BackgroundColor = [0.502 0.502 0.502];
            app.ResetBackgroundImageButton_2.FontSize = 16;
            app.ResetBackgroundImageButton_2.FontWeight = 'bold';
            app.ResetBackgroundImageButton_2.FontColor = [1 1 1];
            app.ResetBackgroundImageButton_2.Position = [282 66 210 28];
            app.ResetBackgroundImageButton_2.Text = 'Reset Background Image';

            % Create UIAxes_bkg_2
            app.UIAxes_bkg_2 = uiaxes(app.YAlignmentTab);
            title(app.UIAxes_bkg_2, 'Background Image')
            app.UIAxes_bkg_2.DataAspectRatio = [1 1 1];
            app.UIAxes_bkg_2.PlotBoxAspectRatio = [4 3 1];
            app.UIAxes_bkg_2.XTick = [];
            app.UIAxes_bkg_2.YTick = [];
            app.UIAxes_bkg_2.Color = [0 0 0];
            app.UIAxes_bkg_2.FontSize = 16;
            app.UIAxes_bkg_2.Box = 'on';
            app.UIAxes_bkg_2.Position = [563 468 662 395];

            % Create UIAxes_ch_2
            app.UIAxes_ch_2 = uiaxes(app.YAlignmentTab);
            title(app.UIAxes_ch_2, 'Cherenkov Image')
            app.UIAxes_ch_2.DataAspectRatio = [1 1 1];
            app.UIAxes_ch_2.PlotBoxAspectRatio = [4 3 1];
            app.UIAxes_ch_2.XTick = [];
            app.UIAxes_ch_2.YTick = [];
            app.UIAxes_ch_2.Color = [0 0 0];
            app.UIAxes_ch_2.FontSize = 16;
            app.UIAxes_ch_2.Box = 'on';
            app.UIAxes_ch_2.Position = [563 66 662 395];

            % Create ResultsTab
            app.ResultsTab = uitab(app.TabGroup);
            app.ResultsTab.Title = 'Results';
            app.ResultsTab.BackgroundColor = [0.149 0.149 0.149];

            % Create ResultsLabel
            app.ResultsLabel = uilabel(app.ResultsTab);
            app.ResultsLabel.FontSize = 16;
            app.ResultsLabel.FontColor = [1 1 1];
            app.ResultsLabel.Position = [41 776 101 23];
            app.ResultsLabel.Text = '3.) Results ';

            % Create dxmmLabel
            app.dxmmLabel = uilabel(app.ResultsTab);
            app.dxmmLabel.FontSize = 16;
            app.dxmmLabel.FontWeight = 'bold';
            app.dxmmLabel.FontColor = [1 1 1];
            app.dxmmLabel.Position = [238 728 67 23];
            app.dxmmLabel.Text = 'dx (mm)';

            % Create dymmLabel
            app.dymmLabel = uilabel(app.ResultsTab);
            app.dymmLabel.FontSize = 16;
            app.dymmLabel.FontWeight = 'bold';
            app.dymmLabel.FontColor = [1 1 1];
            app.dymmLabel.Position = [359 728 66 23];
            app.dymmLabel.Text = 'dy (mm)';

            % Create dzmmLabel
            app.dzmmLabel = uilabel(app.ResultsTab);
            app.dzmmLabel.FontSize = 16;
            app.dzmmLabel.FontWeight = 'bold';
            app.dzmmLabel.FontColor = [1 1 1];
            app.dzmmLabel.Position = [487 728 66 23];
            app.dzmmLabel.Text = 'dz (mm)';

            % Create drmmLabel
            app.drmmLabel = uilabel(app.ResultsTab);
            app.drmmLabel.FontSize = 16;
            app.drmmLabel.FontWeight = 'bold';
            app.drmmLabel.FontColor = [1 1 1];
            app.drmmLabel.Position = [623 728 64 23];
            app.drmmLabel.Text = 'dr (mm)';

            % Create RTtoMRLabel
            app.RTtoMRLabel = uilabel(app.ResultsTab);
            app.RTtoMRLabel.HorizontalAlignment = 'right';
            app.RTtoMRLabel.FontSize = 16;
            app.RTtoMRLabel.FontColor = [1 1 1];
            app.RTtoMRLabel.Position = [97 697 85 23];
            app.RTtoMRLabel.Text = 'RT to MR';

            % Create DifferencesLabel
            app.DifferencesLabel = uilabel(app.ResultsTab);
            app.DifferencesLabel.FontSize = 16;
            app.DifferencesLabel.FontWeight = 'bold';
            app.DifferencesLabel.FontColor = [1 1 1];
            app.DifferencesLabel.Position = [94 728 92 23];
            app.DifferencesLabel.Text = 'Differences';

            % Create CalculateResultsButton
            app.CalculateResultsButton = uibutton(app.ResultsTab, 'push');
            app.CalculateResultsButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateResultsButtonPushed, true);
            app.CalculateResultsButton.BackgroundColor = [0.502 0.502 0.502];
            app.CalculateResultsButton.FontSize = 16;
            app.CalculateResultsButton.FontColor = [1 1 1];
            app.CalculateResultsButton.Position = [151 774 100 27];
            app.CalculateResultsButton.Text = 'Calculate';

            % Create RT_MR_dx_Label
            app.RT_MR_dx_Label = uilabel(app.ResultsTab);
            app.RT_MR_dx_Label.BackgroundColor = [0.502 0.502 0.502];
            app.RT_MR_dx_Label.HorizontalAlignment = 'right';
            app.RT_MR_dx_Label.FontSize = 16;
            app.RT_MR_dx_Label.FontColor = [1 1 1];
            app.RT_MR_dx_Label.Position = [234 697 67 23];
            app.RT_MR_dx_Label.Text = '';

            % Create RT_MR_dy_Label
            app.RT_MR_dy_Label = uilabel(app.ResultsTab);
            app.RT_MR_dy_Label.BackgroundColor = [0.502 0.502 0.502];
            app.RT_MR_dy_Label.HorizontalAlignment = 'right';
            app.RT_MR_dy_Label.FontSize = 16;
            app.RT_MR_dy_Label.FontColor = [1 1 1];
            app.RT_MR_dy_Label.Position = [359 697 67 23];
            app.RT_MR_dy_Label.Text = '';

            % Create RT_MR_dz_Label
            app.RT_MR_dz_Label = uilabel(app.ResultsTab);
            app.RT_MR_dz_Label.BackgroundColor = [0.502 0.502 0.502];
            app.RT_MR_dz_Label.HorizontalAlignment = 'right';
            app.RT_MR_dz_Label.FontSize = 16;
            app.RT_MR_dz_Label.FontColor = [1 1 1];
            app.RT_MR_dz_Label.Position = [487 697 67 23];
            app.RT_MR_dz_Label.Text = '';

            % Create RT_MR_dr_Label
            app.RT_MR_dr_Label = uilabel(app.ResultsTab);
            app.RT_MR_dr_Label.BackgroundColor = [0.502 0.502 0.502];
            app.RT_MR_dr_Label.HorizontalAlignment = 'right';
            app.RT_MR_dr_Label.FontSize = 16;
            app.RT_MR_dr_Label.FontColor = [1 1 1];
            app.RT_MR_dr_Label.Position = [622 697 67 23];
            app.RT_MR_dr_Label.Text = '';

            % Create PhantOffsetMissingLabel
            app.PhantOffsetMissingLabel = uilabel(app.ResultsTab);
            app.PhantOffsetMissingLabel.FontColor = [1 0.4118 0.1608];
            app.PhantOffsetMissingLabel.Position = [266 769 240 36];
            app.PhantOffsetMissingLabel.Text = '';

            % Create CalibrationTab
            app.CalibrationTab = uitab(app.TabGroup);
            app.CalibrationTab.Title = 'Calibration';
            app.CalibrationTab.BackgroundColor = [0.149 0.149 0.149];

            % Create BrowsetoFolderButton_4
            app.BrowsetoFolderButton_4 = uibutton(app.CalibrationTab, 'push');
            app.BrowsetoFolderButton_4.ButtonPushedFcn = createCallbackFcn(app, @BrowsetoFolderButton_4Pushed, true);
            app.BrowsetoFolderButton_4.BackgroundColor = [0.502 0.502 0.502];
            app.BrowsetoFolderButton_4.FontSize = 16;
            app.BrowsetoFolderButton_4.FontColor = [1 1 1];
            app.BrowsetoFolderButton_4.Position = [241 811 197 27];
            app.BrowsetoFolderButton_4.Text = 'Browse to Folder';

            % Create LoadNewFlatfieldLabel
            app.LoadNewFlatfieldLabel = uilabel(app.CalibrationTab);
            app.LoadNewFlatfieldLabel.FontSize = 16;
            app.LoadNewFlatfieldLabel.FontColor = [1 1 1];
            app.LoadNewFlatfieldLabel.Position = [42 811 174 22];
            app.LoadNewFlatfieldLabel.Text = '4.a.) Load New Flatfield';

            % Create DefinePixelSizeLabel
            app.DefinePixelSizeLabel = uilabel(app.CalibrationTab);
            app.DefinePixelSizeLabel.FontSize = 16;
            app.DefinePixelSizeLabel.FontColor = [1 1 1];
            app.DefinePixelSizeLabel.Position = [42 617 175 23];
            app.DefinePixelSizeLabel.Text = '4.c.) Define Pixel Size';

            % Create PixelSizeSpinner
            app.PixelSizeSpinner = uispinner(app.CalibrationTab);
            app.PixelSizeSpinner.Step = 0.01;
            app.PixelSizeSpinner.Limits = [0 100];
            app.PixelSizeSpinner.FontSize = 16;
            app.PixelSizeSpinner.FontColor = [1 1 1];
            app.PixelSizeSpinner.BackgroundColor = [0.651 0.651 0.651];
            app.PixelSizeSpinner.Position = [215 617 87 22];

            % Create SavePixelSizeButton
            app.SavePixelSizeButton = uibutton(app.CalibrationTab, 'push');
            app.SavePixelSizeButton.ButtonPushedFcn = createCallbackFcn(app, @SavePixelSizeButtonPushed, true);
            app.SavePixelSizeButton.BackgroundColor = [0.502 0.502 0.502];
            app.SavePixelSizeButton.FontSize = 16;
            app.SavePixelSizeButton.FontColor = [1 1 1];
            app.SavePixelSizeButton.Position = [730 614 124 28];
            app.SavePixelSizeButton.Text = 'Save Pixel Size';

            % Create mmLabel_1
            app.mmLabel_1 = uilabel(app.CalibrationTab);
            app.mmLabel_1.FontSize = 16;
            app.mmLabel_1.FontColor = [1 1 1];
            app.mmLabel_1.Position = [311 617 35 23];
            app.mmLabel_1.Text = 'mm';

            % Create DoyouwanttosavethisvalueThiswillimpactresultsLabel
            app.DoyouwanttosavethisvalueThiswillimpactresultsLabel = uilabel(app.CalibrationTab);
            app.DoyouwanttosavethisvalueThiswillimpactresultsLabel.HorizontalAlignment = 'center';
            app.DoyouwanttosavethisvalueThiswillimpactresultsLabel.FontSize = 16;
            app.DoyouwanttosavethisvalueThiswillimpactresultsLabel.FontColor = [1 1 1];
            app.DoyouwanttosavethisvalueThiswillimpactresultsLabel.Position = [358 610 235 36];
            app.DoyouwanttosavethisvalueThiswillimpactresultsLabel.Text = {'Do you want to save this value?'; 'This will impact results.'};

            % Create SavePixelSizeCheck
            app.SavePixelSizeCheck = uidropdown(app.CalibrationTab);
            app.SavePixelSizeCheck.Items = {'No', 'Yes'};
            app.SavePixelSizeCheck.FontSize = 16;
            app.SavePixelSizeCheck.FontColor = [1 1 1];
            app.SavePixelSizeCheck.BackgroundColor = [0.502 0.502 0.502];
            app.SavePixelSizeCheck.Position = [600 617 100 22];
            app.SavePixelSizeCheck.Value = 'No';

            % Create SavePixelSizeStatusLabel
            app.SavePixelSizeStatusLabel = uilabel(app.CalibrationTab);
            app.SavePixelSizeStatusLabel.FontSize = 16;
            app.SavePixelSizeStatusLabel.FontColor = [1 1 1];
            app.SavePixelSizeStatusLabel.Position = [870 620 174 22];
            app.SavePixelSizeStatusLabel.Text = '';

            % Create RingDiameterCalibLabel
            app.RingDiameterCalibLabel = uilabel(app.CalibrationTab);
            app.RingDiameterCalibLabel.FontSize = 16;
            app.RingDiameterCalibLabel.FontColor = [1 1 1];
            app.RingDiameterCalibLabel.Position = [42 544 227 23];
            app.RingDiameterCalibLabel.Text = '4.d.) Ring Diameter Calibration';

            % Create BackgroundRingDiametermmLabel
            app.BackgroundRingDiametermmLabel = uilabel(app.CalibrationTab);
            app.BackgroundRingDiametermmLabel.HorizontalAlignment = 'right';
            app.BackgroundRingDiametermmLabel.FontSize = 16;
            app.BackgroundRingDiametermmLabel.FontColor = [1 1 1];
            app.BackgroundRingDiametermmLabel.Position = [311 544 241 22];
            app.BackgroundRingDiametermmLabel.Text = 'Background Ring Diameter (mm)';

            % Create BkgRingDiameter
            app.BkgRingDiameter = uieditfield(app.CalibrationTab, 'numeric');
            app.BkgRingDiameter.FontSize = 16;
            app.BkgRingDiameter.Position = [567 544 100 22];

            % Create CalibYShifts
            app.CalibYShifts = uilabel(app.CalibrationTab);
            app.CalibYShifts.FontSize = 16;
            app.CalibYShifts.FontColor = [1 1 1];
            app.CalibYShifts.Position = [877 549 269 23];
            app.CalibYShifts.Text = 'Y-shifts (mm): -5, -2.5, -1, 0, 1, 2.5, 5';

            % Create SaveYCalibButton
            app.SaveYCalibButton = uibutton(app.CalibrationTab, 'push');
            app.SaveYCalibButton.ButtonPushedFcn = createCallbackFcn(app, @SaveYCalibButtonPushed, true);
            app.SaveYCalibButton.BackgroundColor = [0.502 0.502 0.502];
            app.SaveYCalibButton.FontSize = 16;
            app.SaveYCalibButton.FontColor = [1 1 1];
            app.SaveYCalibButton.Position = [795 453 151 45];
            app.SaveYCalibButton.Text = {'Save Diameter'; 'Calibration Values'};

            % Create DoyouwanttosavethesevaluesThiswillimpactresultsLabel
            app.DoyouwanttosavethesevaluesThiswillimpactresultsLabel = uilabel(app.CalibrationTab);
            app.DoyouwanttosavethesevaluesThiswillimpactresultsLabel.HorizontalAlignment = 'center';
            app.DoyouwanttosavethesevaluesThiswillimpactresultsLabel.FontSize = 16;
            app.DoyouwanttosavethesevaluesThiswillimpactresultsLabel.FontColor = [1 1 1];
            app.DoyouwanttosavethesevaluesThiswillimpactresultsLabel.Position = [412 457 256 37];
            app.DoyouwanttosavethesevaluesThiswillimpactresultsLabel.Text = {'Do you want to save these values?'; 'This will impact results.'};

            % Create SaveYCalibCheck
            app.SaveYCalibCheck = uidropdown(app.CalibrationTab);
            app.SaveYCalibCheck.Items = {'No', 'Yes'};
            app.SaveYCalibCheck.FontSize = 16;
            app.SaveYCalibCheck.FontColor = [1 1 1];
            app.SaveYCalibCheck.BackgroundColor = [0.502 0.502 0.502];
            app.SaveYCalibCheck.Position = [671 464 100 22];
            app.SaveYCalibCheck.Value = 'No';

            % Create SaveYCalibStatusLabel
            app.SaveYCalibStatusLabel = uilabel(app.CalibrationTab);
            app.SaveYCalibStatusLabel.FontSize = 16;
            app.SaveYCalibStatusLabel.FontColor = [1 1 1];
            app.SaveYCalibStatusLabel.Position = [954 464 174 22];
            app.SaveYCalibStatusLabel.Text = '';

            % Create SaveYCalibStatusLabelEditFieldLabel
            app.SaveYCalibStatusLabelEditFieldLabel = uilabel(app.CalibrationTab);
            app.SaveYCalibStatusLabelEditFieldLabel.HorizontalAlignment = 'right';
            app.SaveYCalibStatusLabelEditFieldLabel.FontSize = 16;
            app.SaveYCalibStatusLabelEditFieldLabel.FontColor = [1 1 1];
            app.SaveYCalibStatusLabelEditFieldLabel.Position = [687 516 174 56];
            app.SaveYCalibStatusLabelEditFieldLabel.Text = {'Enter optical diameters '; '(mm) at y-shifts above'; '(comma separated)'};

            % Create RingDiameterCalib
            app.RingDiameterCalib = uieditfield(app.CalibrationTab, 'text');
            app.RingDiameterCalib.ValueChangedFcn = createCallbackFcn(app, @RingDiameterCalibValueChanged, true);
            app.RingDiameterCalib.Position = [877 524 252 22];

            % Create OpticalDiamsFormatWarning
            app.OpticalDiamsFormatWarning = uilabel(app.CalibrationTab);
            app.OpticalDiamsFormatWarning.FontSize = 16;
            app.OpticalDiamsFormatWarning.FontColor = [1 0.4118 0.1608];
            app.OpticalDiamsFormatWarning.Position = [891 516 237 22];
            app.OpticalDiamsFormatWarning.Text = '';

            % Create DefaultDataPathLabel
            app.DefaultDataPathLabel = uilabel(app.CalibrationTab);
            app.DefaultDataPathLabel.FontSize = 16;
            app.DefaultDataPathLabel.FontColor = [1 1 1];
            app.DefaultDataPathLabel.Position = [42 724 168 22];
            app.DefaultDataPathLabel.Text = '4.b.) Default Data Path';

            % Create DefaultDataPathField
            app.DefaultDataPathField = uieditfield(app.CalibrationTab, 'text');
            app.DefaultDataPathField.Position = [222 724.333332061768 393 23.6666679382324];

            % Create SavePathButton
            app.SavePathButton = uibutton(app.CalibrationTab, 'push');
            app.SavePathButton.ButtonPushedFcn = createCallbackFcn(app, @SavePathButtonPushed, true);
            app.SavePathButton.BackgroundColor = [0.502 0.502 0.502];
            app.SavePathButton.FontSize = 16;
            app.SavePathButton.FontColor = [1 1 1];
            app.SavePathButton.Position = [647 722 124 28];
            app.SavePathButton.Text = 'Save Path';

            % Create SavePathStatusLabel
            app.SavePathStatusLabel = uilabel(app.CalibrationTab);
            app.SavePathStatusLabel.FontSize = 16;
            app.SavePathStatusLabel.FontColor = [1 1 1];
            app.SavePathStatusLabel.Position = [787 725 174 22];
            app.SavePathStatusLabel.Text = '';

            % Show the figure after all components are created
            app.VIPERUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = VIPER_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.VIPERUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.VIPERUIFigure)
        end
    end
end