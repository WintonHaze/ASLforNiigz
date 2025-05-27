function [BF] = aslQuant(m0,ctrl,tag,TR,PLD,tao,ASL_type,tesla)
%Quantification for kidney with single compartment model
% m0: 2D data
% ctrl & tag: 2D or 3D data. If they're 3D, average will be done.

if nargin < 8
    tesla = '3T';
end

% Assumed parameter
TI = PLD;
TI_1 = tao;
T1_tissue = 1.25; % T1 kideney is 1000-1500. In muscle it's 800.
T1_blood = 1.65; % 1.65 s at 3 T and 1.48 s at 1.5 T

if strcmp(tesla, '5T')
    T1_tissue = 1.4;
    T1_blood = 1.85;
end

lambda = 0.9;
% lambda assumed constant value for the tissue–blood partition
% coefficient, defined as the grams of water per gram of tissue
% divided by the grams of water per mL of blood. 0.9 mL/g.
if strcmp(ASL_type,'FAIR')
    alp = 0.95; % assumed labelling efficiency, PASL = 95%, PCASL = 85%
elseif strcmp(ASL_type,'PCASL')
    alp = 0.85;
end
% BGS -> alpha, multi-slice -> PLD & TI
% Two points below remaining to consider in the future.
% TR <= 5s correction
diff = ctrl-tag;
diff_avg = mean(diff,3);
% if TR <= 5
%     m0 = m0/(1-exp(-TR/T1_tissue));
% end
m0 = m0/(1-exp(-TR/T1_tissue));
if strcmp(ASL_type, 'FAIR')
    % FAIR with QUIPSSII type saturation
    BF = (6000*lambda*diff_avg*exp(TI/T1_blood))./(2*alp*TI_1*m0);
elseif strcmp(ASL_type, 'PCASL')
    % PCASL
    BF = (6000*lambda*diff_avg*exp(PLD/T1_blood))./(2*alp*T1_blood* ...
        m0*(1-exp(-tao/T1_blood)));
end
BF(isnan(BF)|isinf(BF)) = 0;
end