%% A method for renal ASL quantification
% update: 2025.5.27
% This version is for easy quantification, accompanied with DL Segmentation

% % Variation mark
% data_** is dicom in one time scan. The size is [H,W,S]
% set_** is all dicom needed to be analyzed. The size is [H,W,S,C]

%% Scan parameter
clear;
clc;

% -------------- Type here -------------- %

% 填写各项扫描信息、文件位置

ASL_type = 'PCASL'; % FAIR or PCASL
filedir = "D:\BaiduNetdiskDownload\XU XINLEI20250327\XU XINLEI\DICOM";
TR = 4.5;
PLD = 2;
tao = 2;
tesla = '5T';
% -------------- Type here -------------- %


TI = PLD;
TI_1 = tao;
data_collection = dicomCollection(filedir);
SliceNumbers = (1:size(data_collection,1)).';
SeriesDescription = data_collection{:,'SeriesDescription'};
show_collection = table(SliceNumbers, SeriesDescription) %#ok<NOPTS>
%% Make your choice

% -------------- Type here -------------- %

% 分别填写ASL图像的序号、M0图像的序号、是否需要掩码、掩码的位置
% load_nii函数需要安装开源工具包https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image
first_m0_number_in_collection = 's10';
m0_number = 's11';
ifmask = 'yes';
mask_set = load_nii('D:\BaiduNetdiskDownload\XU XINLEI20250327\01.nii.gz');

% -------------- Type here -------------- %

mask1 = permute(mask_set.img, [1, 3, 2]);
set_mask = mask1;
for i = 1:7
    img = mask1(:, :, i);
    
    % 旋转90度
    rotated_img = rot90(img);
    
    % 进行左右镜像翻转
    flipped_img = fliplr(rotated_img);
    
    % 将处理后的图像存回新数组
    set_mask(:, :, 8-i) = flipped_img;
end


cycle_num = 7;
set_m0 = squeeze(double(dicomreadVolume(data_collection,m0_number)));
set_ctrl_tag = squeeze(double(dicomreadVolume(data_collection,first_m0_number_in_collection)));
% 排列
% 初始化 set_ctrl 和 set_tag
set_ctrl = zeros(192, 192, 30, 7);
set_tag = zeros(192, 192, 30, 7);

% 遍历每个分组
for i = 1:7
    % 计算当前分组的起始和结束索引
    start_index = (i-1)*60 + 1; % 当前分组的起始索引
    end_index = i*60; % 当前分组的结束索引
    
    % 将前 30 张图像分配给 set_ctrl
    set_ctrl(:, :, :, i) = set_ctrl_tag(:, :, start_index:start_index+29);
    
    % 将后 30 张图像分配给 set_tag
    set_tag(:, :, :, i) = set_ctrl_tag(:, :, start_index+30:end_index);
end

% mask处理
set_mask(set_mask == 2) = 1;

% 粘贴扩展掩码数据大小
set_mask = double(set_mask);
set_mask_broadcasted = reshape(set_mask, [192, 192, 1, 7]);
set_mask_broadcasted = repmat(set_mask_broadcasted, [1, 1, 30, 1]);

% 应用mask到ctrl tag m0
set_ctrl = set_mask_broadcasted .* set_ctrl;
set_tag = set_mask_broadcasted .* set_tag;
set_m0 = set_mask .* set_m0;


% Register and Quantification

region_mask = ones(192,192);
for my_cycle = 1:cycle_num

    % Load                        
    data_m0 = set_m0(:,:,my_cycle);
    data_ctrl = set_ctrl(:,:,:,my_cycle);
    data_tag = set_tag(:,:,:,my_cycle);


    % Register
    [data_ctrl_rg, data_tag_rg, ~] = renalRegister(data_m0,data_ctrl,data_tag,1,region_mask);

    % Save
    set_ctrl(:,:,:,my_cycle) = data_ctrl_rg;
    set_tag(:,:,:,my_cycle) = data_tag_rg;

end

res = zeros(size(set_ctrl));
set_ctrl_rg = set_ctrl;
set_tag_rg = set_tag;

for my_cycle = 1:cycle_num

    % Load
    data_m0 = set_m0(:,:,my_cycle);
    data_ctrl = set_ctrl(:,:,:,my_cycle);
    data_tag = set_tag(:,:,:,my_cycle);

    % % Affine Registration or Non-rigid Registration
    for slice = 1:size(data_ctrl,3)
        set_ctrl_rg(:,:,slice,my_cycle) = renalRegisterNonrigid(data_ctrl(:,:,slice),data_m0,'nonrigid');
        set_tag_rg(:,:,slice,my_cycle) = renalRegisterNonrigid(data_tag(:,:,slice),set_ctrl_rg(:,:,slice,my_cycle),'nonrigid');
    end

    % Quantification for kidney
    RBF = data_ctrl;
    for slice = 1:size(RBF,3)
        RBF(:,:,slice) = aslQuant(data_m0,set_ctrl_rg(:,:,slice,my_cycle), ...
            set_tag_rg(:,:,slice,my_cycle),TR,PLD,tao,'FAIR',tesla);
    end
    res(:,:,:,my_cycle) = RBF;
end


% Correction
% 阈值处理、平均

nres = res;

% 阈值
nres(nres>3000)=3000;
nres(nres<0)=0; 

% 将多次扫描平均
nres_after_mean=squeeze(mean(nres,3)); 

figure;
for i = 1:6
    subplot(2,4,i);imagesc(nres_after_mean(:,:,i));colorbar;axis off;
end

save_time = string(datetime('now','Format','M_d_HH_mm'));
save(strcat('ASL_result_',save_time,'.mat'));