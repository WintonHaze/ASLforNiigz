# ASLforNiigz
# README

## 1. 作者信息及程序介绍


本程序由Xiangwei Kong编写，是一个用于肾脏ASL定量分析的MATLAB脚本。它支持PCASL和FAIR两种ASL类型。程序的主要功能包括：
- 数据加载与预处理：从DICOM文件中读取ASL图像和M0图像，并进行必要的预处理。
- 掩码处理：支持加载外部掩码文件，并对掩码进行处理以适应图像大小。
- 图像配准：对控制图像（Ctrl）和标记图像（Tag）进行刚性或非刚性配准。
- 定量分析：基于ASL原理，计算肾脏的血流灌注量（RBF）。

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
在程序的“Scan parameter”部分，填写以下扫描信息和文件路径：
- `ASL_type`：ASL类型，可选`PCASL`或`FAIR`。
- `filedir`：DICOM文件所在的目录路径。
- `TR`：重复时间（单位：秒）。
- `PLD`：标记延迟时间（单位：秒）。
- `tao`：标记时间（单位：秒）。
- `tesla`：磁场强度，如`3T`或`5T`。

在“Make your choice”部分，填写以下信息：
- `first_m0_number_in_collection`：M0图像在DICOM集合中的序号。
- `m0_number`：M0图像的具体编号。
- `ifmask`：是否使用掩码，可选`yes`或`no`。
- `mask_set`：掩码文件的路径。
