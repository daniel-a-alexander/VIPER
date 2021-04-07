# VIPER (Visual Isocenter Position Enhanced Review)
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


<iframe width="560" height="315" src="https://www.youtube.com/embed/HqxceAFdDMs" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
