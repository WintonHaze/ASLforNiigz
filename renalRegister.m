function [ctrl_result, tag_result, region_mask] = renalRegister(m0,ctrl,tag,draw_num,region_mask)
%不推荐使用，推荐改用kidneyRegASL
%   Renal ASL registeration
%   update: 2023.5.11 by Xiangwei Kong
%   m0: 2D data
%   ctrl & tag: 4D data or 3D data
%   Method: 
%     1. Monomodal & Rigid. 
%     2. Register left and right kidneys, respectively.

% Region
% This step is a preprocessing of registration. A rough and wide region
% around two kidneys needed to be drawed. Caution: It's not an acute mask.
% It's a region which can include all kidneys with motion.

interation_number = 1000;
image_show = 0; % show the result of registration

ctrl = squeeze(ctrl);
tag = squeeze(tag);
m0 = squeeze(m0);
[H,W,S] = size(ctrl);
ctrl_result = zeros(H,W,S);
tag_result = zeros(H,W,S);
if nargin <= 4
    % if no mask in input
    set(gcf,'position',[0,0,3440,1440]);
    region_mask = zeros(size(m0));
    for i = 1:draw_num
        mask = drawROI(m0, ['Please draw a rough area, including only one object. ' ...
            'Draw other objects in the next window. Caution: It is ' ...
            'not an acute mask. It is a region which can include all' ...
            ' kidneys with motion.'], 'poly');
        % mask = ones(size(m0));

        if i == 1
            region_mask1 = double(mask);
            region_mask = region_mask1;
        else
            region_mask2 = double(mask);
            region_mask = cat(3,region_mask1,region_mask2);
        end
    end
    close;
else
    % if there's mask in input
    region_mask1 = region_mask(:,:,1);
    if draw_num == 2
        region_mask2 = region_mask(:,:,2);
    end
end
ctrl = double(ctrl);
tag = double(tag);


data_ctrl_r = zeros(H,W,S);
data_tag_r = zeros(H,W,S);
for half = 1:draw_num
    if half == 1
        half_mask = region_mask1;
    else
        half_mask = region_mask2;
    end
    data_m0_r = double(m0).*half_mask;

    for slice = 1:size(ctrl,3)
        data_ctrl_r(:,:,slice) = ctrl(:,:,slice).*double(half_mask);
        data_tag_r(:,:,slice) = tag(:,:,slice).*double(half_mask);
    end

    % Registration
    % 'interation_number' can be modified.
    fixed = data_m0_r;
    data_ctrl_rg = zeros(H,W,S);
    data_tag_rg = zeros(H,W,S);
    [optimizer, metric] = imregconfig('monomodal');
    optimizer.MaximumIterations = interation_number;
    for i = 1:S
        moving = double(data_ctrl_r(:,:,i));
        movingRegistered = imregister(moving, fixed, 'rigid', optimizer, metric);
        if image_show == 1 && mod(i,6) == 1
            figure;
            subplot 121;imshowpair(fixed, moving,'Scaling','joint');
            title('Original');
            subplot 122;imshowpair(fixed, movingRegistered,'Scaling','joint');
            title('Registration');set(gcf,'position',[0,0,3440,1440]);
        end
        data_ctrl_rg(:,:,i) = movingRegistered;
    end
    for i = 1:S
        moving = double(data_tag_r(:,:,i));
        movingRegistered = imregister(moving, fixed, 'rigid', optimizer, metric);
        data_tag_rg(:,:,i) = movingRegistered;
    end
    ctrl_result = ctrl_result + data_ctrl_rg;
    tag_result  = tag_result  +  data_tag_rg;
end
end