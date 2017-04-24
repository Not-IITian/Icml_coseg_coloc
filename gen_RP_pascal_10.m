 addpath([pwd '/']);
 addpath(genpath('./param/'));
  addpath(genpath('./feature'));
 addpath(genpath('./utils/'));
 
 rand('seed',1);
    randn('seed',1);
clear

for  i =1:19
    
    fileID = fopen('param_pascal_10.txt');
    C_data = textscan(fileID,'%s %f %f %f %f %f %f %f %f');
    fclose(fileID);    
%%%% PARAMETERS
    param.no_scaling =1; % no scaling of image
    param.MSRC = 0; param.Davis = 0;param.Utube = 0;
    dataset = double(C_data{4}(i));        
    if dataset ==1 % this is MSRC
        param.pascal_10 = 0;
        param.MSRC = 1;
        param.pascal_07_06 =0 ;
    elseif dataset ==2 % this is obj disc
        param.pascal_10 = 0;
        param.MSRC = 0;
        param.pascal_07_06 =0;
    elseif dataset ==0 % 0 for pascal
        param.pascal_10 = 1;
        param.MSRC = 0;
        param.pascal_07_06 =0;
    elseif dataset==3
        param.pascal_07_06 =1;
        param.pascal_10 = 0;
        param.MSRC = 0;
        param.only_coloc = 1;
    elseif dataset == 5
        param.Utube = 1;
        param.pascal_07_06 =0;
        param.pascal_10 = 0;
        param.MSRC = 0;
        param.Davis = 0;
    else
        param.Davis = 1;
        param.pascal_07_06 =0;
        param.pascal_10 = 0;
        param.MSRC = 0;
    end
    param.noBoxes = 30;    
    param.scaled_sal_box = 1 ;
    param.solve_pixel_qp = 0 ;
    param.useBox = 1; param.useSaliency = 1;  % if this is set,saliency is computed supPix wise
    
    typeObj   = C_data{1}(i);
    param.wt_disc = 1;
    lapWght  = double(C_data{3}(i));
    nPics   = C_data{5}(i); 
    param.wt_saliency = C_data{6}(i);    
    lambda0 = C_data{7}(i);
    param.wt_BoxSaliency = double(C_data{8}(i));  % if this is set, saliency is computed box-wise
    
    param.mu = 1;   
    param.box_form = 0 ;% this means using Jean formulation ..meaning image as a collection of 10 box..meaning computing features laplacian for 10 boxes separately 
    param.ViewOn = 1; % to look at results, if set to 0, results will not pop up,just saved   
    param.nClass  = 2; % nb of class  
     % binary parameter (\mu in the article)
%    lapWght  = lap_wt;  
    param.typeKernel  = 'chi2';% 'chi2' or 'Hellsinger'
    typeFeat        = 'sift';% 'color' or 'sift'
    feat_dim = 4096; % dimensionality of box features
    param.reboot   = 1; % 1 to recompute everythin
    computeParameters;% Parameters setting
[descr, descr_im,param] = openFeature_box_once(param);
  startup ;
 param = compute_region_props(param,params) ; 

    cc = cell2mat(typeObj) ;
    save_box_file = [ 'Pascal_10_RP_30/',cc, '.mat'];
    Region_props = param.boxes;
    save(save_box_file,'Region_props')
    
end
