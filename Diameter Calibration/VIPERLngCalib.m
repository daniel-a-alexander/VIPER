
%%%%%%%%%%%%%%%%%%%%% READ ME %%%%%%%%%%%%%%%%%%%%%%%
%%%     VIPER Longitudinal Calibration Script     %%%
%%%     11/23/20 by Dan Alexander                 %%%
%%%     daniel.a.alexander.th@dartmouth.edu       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Dependencies

% This script utilitizes "fwhm.m", included below.

%% First, load PNG images into MATLAB for each position [-5, -2.5, -1, 0, 1, 2.5, 5]

% Note, s0 means Background images, s1 means Cherenkov images - load s1 for
% all, and s0 for the 0 mm position!

%% Next, define pixel size (use calibration pane)

% ENTER HERE
pixelsize = 0.2375; % mm 

% PHANTOM RING DIAM
phant_diam = 62.94; % mm, this is fixed diam of phantom ring
% Note, you can use this in the background image for pixel size
% calibration.

y_values = [-5, -2.5, -1, 0, 1, 2.5, 5];

%% yCalib center point

% Find the center point of the crosshair in the s0 image at 0 mm:

% imagesc(im_0mm_s0)
% imcontrast

yCalib_imcent = [x,y]; 

%% Calculate Optical Diameters

% this portion calcualted radial profiles from the center defined by user
% above at each angle and averages.

% radius of profile on image
rad_mm = 60; % mm profile
rad = rad_mm/pixelsize; % convert to pixels
divs = 100; % spacing between angles from 0 to 360

profs = struct(); % save profiles to struct

[xends,yends] = pol2cart(linspace(0, 2*pi, divs), rad); % convert to cartesian
% shift ends of profiles based on circle center
xends = xends+yCalib_imcent(1);
yends = yends+yCalib_imcent(2); 

yCalib_fields = {'yCalib_n5', 'yCalib_n2p5', 'yCalib_n1', 'yCalib_0', 'yCalib_p1', 'yCalib_p2p5', 'yCalib_p5'};

optical_diams = zeros(size(y_values)); % intialize

% loop over fields
for j=1:numel(yCalib_fields)
    profs.(yCalib_fields{j}).raw = zeros(divs, rad); % save raw prof, 2D matrix with profs at each div
    for i = 1:divs % loop over divs
        % insert correct image below for IM (different for each loop
        % iteration)
        prof = improfile(IM, [yCalib_imcent(1), xends(i)], [yCalib_imcent(2), yends(i)], rad);
        profs.(yCalib_fields{j}).raw(i,:) = prof; % populate matrix
    end
    profs.(yCalib_fields{j}).mean = mean(profs.(yCalib_fields{j}).raw, 1); % average over divs
    [width, rise, fall] = fwhm(1:rad, profs.(yCalib_fields{j}).mean, 0.40); % find FW@40%
    radius = mean([rise,fall]); % mean of rising and falling edge
    
    profs.(yCalib_fields{j}).width = width; 
    profs.(yCalib_fields{j}).rise = rise; 
    profs.(yCalib_fields{j}).fall = fall; 
    profs.(yCalib_fields{j}).radius = radius;
    
    optical_diams(j)  = radius*pixelsize*2; % double for diameter
end

%% DONE! Optical_diams variable should have all the numbers you need.


%% FWHM function

function [width, tlead, ttrail] = fwhm(x,y, thres)

% function width = fwhm(x,y)
%
% Full-Width at Half-Maximum (FWHM) of the waveform y(x)
% and its polarity.
% The FWHM result in 'width' will be in units of 'x'
%
%
% Rev 1.2, April 2006 (Patrick Egan)


    y = y / max(y);
    N = length(y);
    lev50=thres;
    % lev50 = 0.3;
    if y(1) < lev50                  % find index of center (max or min) of pulse
        [~,centerindex]=max(y);
    %     Pol = +1;
    %     disp('Pulse Polarity = Positive')
    else
        [~,centerindex]=min(y);
    %     Pol = -1;
    %     disp('Pulse Polarity = Negative')
    end
    i = 2;
    while sign(y(i)-lev50) == sign(y(i-1)-lev50)
        i = i+1;
    end                                   %first crossing is between v(i-1) & v(i)
    interp = (lev50-y(i-1)) / (y(i)-y(i-1));
    tlead = x(i-1) + interp*(x(i)-x(i-1));
    i = centerindex+1;                    %start search for next crossing at center
    while ((sign(y(i)-lev50) == sign(y(i-1)-lev50)) && (i <= N-1))
        i = i+1;
    end
    if i ~= N
    %     Ptype = 1;  
    %     disp('Pulse is Impulse or Rectangular with 2 edges')
        interp = (lev50-y(i-1)) / (y(i)-y(i-1));
        ttrail = x(i-1) + interp*(x(i)-x(i-1));
        width = ttrail - tlead;
    else
    %     Ptype = 2; 
    %     disp('Step-Like Pulse, no second edge')
        ttrail = NaN;
        width = NaN;
    end
end


