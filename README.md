# ASLforNiigz

## 1. 作者信息及程序介绍
本程序由Xiangwei Kong编写，是一个用于肾脏ASL定量分析的MATLAB脚本。

## 2. 使用方法

### 环境准备
- 本程序需要MATLAB环境支持，建议使用MATLAB R2020a或更高版本。
- 需要安装以下MATLAB工具箱：
  - Image Processing Toolbox
  - Statistics and Machine Learning Toolbox
- 需要搭配以下开源工具包：
  - [DICOM工具包](https://www.mathworks.com/matlabcentral/fileexchange/19734-dicom-tools)：用于读取和处理DICOM文件。
  - [NIfTI工具包](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image)：用于加载NIfTI格式的掩码文件。

### 参数设置
打开ASL_0527.m，在程序的“Scan parameter”部分，填写以下扫描信息和文件路径：
- `ASL_type`：ASL类型，可选`PCASL`或`FAIR`。
- `filedir`：DICOM文件所在的目录路径。
- `TR`：重复时间（单位：秒）。
- `PLD`：标记延迟时间（单位：秒）。
- `tao`：标记时间（单位：秒）。
- `tesla`：磁场强度，如`3T`或`5T`。

在“Make your choice”部分，填写以下信息：
- `first_m0_number_in_collection`： ASL图像在DICOM集合中的序号，如‘s11’。
- `m0_number`：M0图像的具体编号。
- `ifmask`：是否使用掩码，可选`yes`或`no`。
- `mask_set`：掩码文件的路径。
