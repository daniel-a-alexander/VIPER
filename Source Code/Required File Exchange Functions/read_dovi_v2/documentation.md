

# **Read Dovi (v2) Documentation**
Copyright DoseOptics LLC 2021
## **Syntax**
  
      I = read_dovi(file_path)
      I = read_dovi(___,Name,Value)


## **Description**

read_dovi_v2 will import image data from C-Dose Research (5.03 or later). 

## **Examples**
**Read in Cherenkov video frames**

    filename = 'meas_cam0.dovi';
    I = read_dovi_v2(filename);
**Read in Background video frames**

    filename = 'meas_cam0.dovi';
    I = read_dovi_v2(filename,'channel','bkgd');
**Read in cumulative Cherenkov image**

    filename = 'meas_cam0.dovi';
    I = read_dovi_v2(filename,'cumulative',1);
**Read in first 10 Cherenkov video frames**

    filename = 'meas_cam0.dovi';
    I = read_dovi_v2(filename,zrange,[1 10]);
## **Input Arguments**

    file_path
char array or string containing the path/file name to the .dovi header file corresponding to the data wish to be read in.

**Name-Value Arguments**

    channel - 'chkv' (default) | 'bkgd' | 'custom'
  
Determines whether the Cherenkov or Background image(s) are read in. If data was acquired in C-Dose Research 'Custom' mode, use 'custom'.

    zrange - two-element vector
Selects the range of frames to be read in. By default, all frames will be read in.

    cumulative - 0 (default) | 1
Determines whether the 8-bit video frames (0) are read in, or the 32-bit cumulative image.

## **Output Arguments**

    I - uint8 or uint32 array, 2D or 3D
2D or 3D array containing image data. If the cumulative option is set to 0 (default), I will be a (m x n x z) uint8 array containing z frames of (m x n) image data. If the cumulative option is set to 1, I will be a (m x n) uint32 array containing the cumulative image data.
