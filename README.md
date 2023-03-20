# VIPER (Visual Isocenter Position Enhanced Review)
_Update: 03/20/2023 by Daniel Alexander (_[_daniel.a.alexander.th@dartmouth.edu_](mailto:daniel.a.alexander.th@dartmouth.edu)_)_
Updated to version 1.3. Auto-detect is no longer used for the crosshair slection, only the user input. Now requires 9.14 runtime (2023a).

_Written 04/07/2021 by Daniel Alexander (_[_daniel.a.alexander.th@dartmouth.edu_](mailto:daniel.a.alexander.th@dartmouth.edu)_)_

The VIPER system is a phantom and analysis program designed to perform MR-RT isocenter coincidence verification for MR-Linacs. This repository contains the source code and downloadable exectuable for the VIPER MATLAB program, as well as example image data and calibration files.

Upon launching the program (VIPER.exe) or running the script (VIPER.m in MATLAB 2020a or later), the UI presents four tabs: X-Z Alignment, Y Alignment, Resuts, and Calibration. The calibration tab allows the user to edit settings and calibration parameters used by the program. These settings are saved as .mat files in userpath/VIPER/calib_files/, which by default are:
~~~
%USERPROFILE%\Documents\MATLAB\VIPER\calib_files\
~~~
on Windows, and 
~~~
home/Documents/MATLAB/VIPER/calib_files/
~~~
on Mac. Example calibration files are found in the "Example Data" directory, and these files can be copied to the appropriate path above to test the program on the image data found in the same directory. When clicking the "Browse to Folder" button, select the parent directory of the image data to be analyzed. Details on the diameter calibration can be found in the "Diameter Calibration" directory.

![demo_xz](https://user-images.githubusercontent.com/42974485/113936904-73f9c680-97c6-11eb-9f32-1112ab84aa0d.png)
