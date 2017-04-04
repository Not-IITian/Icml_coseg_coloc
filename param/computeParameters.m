% param.nClass = nClass;
%%%%%%%%%%%%%%%%%%%%%%%%% OBJ + IMAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~iscell(typeObj)
    typeObj = {typeObj};
end
param.nObj = numel(typeObj);
if numel(nPics) == 1
    param.nPics = param.nObj * nPics;
    nPics = nPics .* ones(param.nObj, 1);
elseif numel(nPics) ~= param.nObj
    printMessage('Ambiguous number of images', 1, mfilename,'e');
    return
else
    param.nPics = sum(nPics(:));
end
param.listObj       = typeObj;
param.listNPics     = nPics;

if ~exist('no_scaling','var')
    param.no_scaling = 0 ;
else
    param.no_scaling = no_scaling  ;
end
%%%%%%%%%%%%%%%%%%%%%%%%% FEATURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
patchSize = 16; gridSpacing = 4 ;
param.featType      = typeFeat;
param.patchSize     = patchSize;
param.gridSpacing   = gridSpacing;
param.resolution    = 16;
%%%%%%%%%%%%%%%%%%%%%%%%% KERNEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param.df             = 400;
% param.typeKernel = typeKernel;

if ~strcmp(param.typeKernel,'Hellinger') && ~strcmp(typeFeat,'colorSift')
    param.paramKernel         = .1;
elseif ~strcmp(param.typeKernel,'Hellinger')
    param.paramKernel         = 1e-3;
end
%%%%%%%%%%%%%%%%%%%%%%%%% REGULARIZATION %%%%%%%%%%%%%%%%%%%%%%%%
param.lambda = 1;
%%%%%%%%%%%%%%%%%%%%%%%%% BINARY TERM %%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('lapWght','var')
   lapWght          =.05;
end
param.lapWght = lapWght;

%%%%%%%%%%%%%%%%%%%%%%%%% OPTIM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param.optim.lambda0 = lambda0;   
param.useSuperpix  = 1;
param.useTag  = 0;
%%%%%%%%%%%%%%%%%%%%%%%%% PATH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
param.path.root         = './';
param.path.output       = [param.path.root,'output/box/',cell2mat(param.listObj),'/'];

%where the images and descriptors are
if param.pascal_10 
    im_path         = [param.path.root ,  'Pascal_10/'];
    data_path       = [param.path.root , 'Pascal_10/descr/']; % this might be a bug when box_form is not enabled
elseif param.box_form
    im_path         = [param.path.root ,  'input/images/'];
    data_path       = [param.path.root , 'input/box_descr/'];
    data_im_feat_path = [param.path.root , 'input/descr/'];
    param.im_path.feat = cellfun( @(x) sprintf('%s%s/',data_im_feat_path , x), param.listObj, 'UniformOutput', 0);
elseif param.pascal_07_06
    im_path         = [param.path.root ,  'pascal_07_06/'];
    data_path       = [param.path.root , 'pascal_07_06/descr/']; 
elseif param.Davis
    im_path         = [param.path.root ,  'Davis_val/'];
    data_path       = [param.path.root , 'Davis_val/descr/'];
else   
    im_path         = [param.path.root ,  'input/images/'];
    data_path       = [param.path.root , 'input/descr/'];
end
if ~exist('only_coloc','var')
    param.only_coloc =0 ;
else
    param.only_coloc = only_coloc;
end

param.path.pic  = cellfun( @(x) sprintf('%s%s/',im_path , x),   param.listObj, 'UniformOutput', 0);
param.path.feat = cellfun( @(x) sprintf('%s%s/',data_path , x), param.listObj, 'UniformOutput', 0);

if param.useBox
    objectness_dir = [param.path.root, 'utils/objectness-release-v2.2/objectness-release-v2.2/'];
    addpath(genpath(objectness_dir));
end

%%%%%%%%%%%%%%%%%%%%%%%%% saliency %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if param.pascal_07_06
    param.saliency_path = cell2mat([param.path.root ,'pascal_07_06/',param.listObj,'/ContrastSal/']);
elseif param.Davis
    param.saliency_path = cell2mat([param.path.root ,'Davis_val/',param.listObj,'/ContrastSal/']);
else
    param.saliency_path = cell2mat([param.path.root ,'input/images/',param.listObj,'/ContrastSal/']);
end
if param.useSuperpix==1
    param.path.superpixel =  cellfun( @(x) sprintf('%ssuperpixel/',x), param.path.pic, 'UniformOutput', 0);
%     cellfun(@(x) sp_make_dir(x), param.path.superpixel);
end
if param.useTag==1
    param.path.tag     =  cellfun( @(x) sprintf('%smask/',x), param.path.feat, 'UniformOutput', 0);
    cellfun(@(x) sp_make_dir(x), param.path.tag);
end
param.path.feat = cellfun( @(x) sprintf('%s%s/',x, param.featType), param.path.feat, 'UniformOutput', 0);
cellfun(@(x) sp_make_dir(x), param.path.feat);
%%%%%%%%%%%%%%%%%%%%%%%%% FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if param.no_scaling ==0      
    param.picMaxSize    = 360;
    param.imresize  = @(I) min(max(imresize(I, param.picMaxSize ./ max(size(I,1) , size(I,2)) ),0),255);
end

if  param.no_scaling % no rescaling duirng pascal_06_      
     param.compSupPix    = @(imPath)vl_quickseg(single(imread( imPath))./255, .7, 2, 15); 
     param.imread    = @(imPath) imread(imPath);
else    
    param.compSupPix    = @(imPath)vl_quickseg(param.imresize(single(imread( imPath))./255), .7, 2, 15);
    param.imread    = @(imPath) param.imresize(imread(imPath));
end

funKernel   = @(X) double(chi2Kernel(single(X)', single(param.paramKernel), param.df));
param.funFeat   = @(X) dense_sift(param.imread(X), param.patchSize, param.gridSpacing);
%  vl_slic(supPixIm, 10, 500) + 1;






