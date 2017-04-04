 % Compute solution from Joulin et. al. cvpr'10 and Joulin et al. cvpr'12
 % function run_coseg(param,typeObj,nPics,typeFeat,lapWght) 
computeParameters;% Parameters setting
[descr, descr_im,param] = openFeature_box_once(param);

if 0  
    if param.useBox
        startup ;
        param = compute_region_props(param,params) ; 
    end
    cc = cell2mat(typeObj) ;
    save_box_file = ['pascal_07_RP_20/', cc, '.mat'];
    Region_props = param.boxes;
    save(save_box_file,'Region_props')

else
    % load the box file
    cc = cell2mat(typeObj) ;
   if param.pascal_07_06    
       if param.noBoxes == 10
            param.box_file = ['pascal_07_RP/', cc, '.mat'];
       else
            param.box_file = ['pascal_07_RP_20/', cc, '.mat'];
       end
   elseif param.pascal_10
            param.box_file = ['pascal_10_RP/', cc, '.mat'];
   elseif dataset==2 % object disc
            param.box_file = ['obj_disc_RP/', cc, '.mat'];
   elseif param.MSRC
        param.box_file = ['MSRC_RP/', cc, '_', num2str(param.noBoxes) '.mat'];
   end   
   
    load(param.box_file) ;
    param.boxes = Region_props(1:nPics);
    
    if param.noBoxes ~= 20
        for j = 1:param.nPics
            param.boxes(j).coords(param.noBoxes+1:end,:) = [] ;% choose only first 10 boxes out of 20 computed before
        end
    end
%         startup ;
%         param = compute_region_props(param,params) ;    
    % only take some of them and not all..        
    deep_net_name= 'imagenet-caffe-alex.mat' ;
    C_box = compute_box_feat_mat(param,deep_net_name)  ;         
    Compute_feature_kernel ;
%%%%%%%%%% Compute the binary term (Laplacian matrix) %%%%%%%%%%%%%%%
if param.box_form
   lapMatrix = Compute_Lap_Mat(descr, param) ;
else
    lapMatrix = LaplacianMatrix(descr, param);
end
%%%%%%%%%% Compute lambda (regularization parameter) %%%%%%%%%%%%%
[param.lambda, xDif] = computeRegularizationParam(descr.data', param.df); 
p = genpath('/BS/deep_3d/work/coseg/vlfeat-0.9.20') ;
addpath(p) ;   
if param.box_form
     [projMatrix, param ] = compute_Box_Proj_mat(descr, param) ; % this does oversegmentation and will give the proj matrix for box form, and also the occurence of each supPix in diff box
    [pixel_perBox_cell, Sup_occurence_cell,supPixIndices_Im] = compute_Sup_occurence(descr,descr_im, param) ;% this will generate the matrix required for constraint generation
else
   [projMatrix, supPixIndices, param] = openSuperpixel(descr, param); %AJ 
end
rmpath(p);
%%%%%%%%%% Open superixels %%%%%%%%%
% parametrs like which supPix are inside box and which not in param, for
% later use       
 
if param.wt_saliency
    saliency_vec = Compute_saliency_vec(param,descr);  % 1 by nSupPix vector for whole Images
else
    saliency_vec = zeros(1,sum(param.lW_supPix));
end
clear descr descr_im ;
[param.saliency_vec_box] = Compute_saliency_box(param);
lapMatrix = projMatrix' * lapMatrix * projMatrix;

lapMatrix = param.lapWght * lapMatrix;    

%%%%%%%%%%%%%%%% CVPR'10 %%%%%%%%%%%%%%%%%%%%     
if param.box_form 
    param = compute_mat_coseg(param, projMatrix, lapMatrix, xDif);
else
     [param ,im_supPix_var_cell,box_supPix_non_zeros, Proj_box_supPix_mat] = convexQuadraticCoseg(param, projMatrix, lapMatrix, xDif);
end
clear lapMatrix projMatrix xDif

if param.box_form
   solve_qp_JP_modular;
else
%   solve_qp_box_pixels ;
qp_box_val;
end
    %    [labelsDif,param] =  extract_output_var(x_sol,saliency_vec_box,param,im_supPix_var_cell );
if param.box_form 
   x_sol = y_sol;
end
 no_supPix_var = numel(saliency_vec) ;
 supPix_var = y_sol(1:no_supPix_var) ;
    % box anlaysis
 box_scores_mat = reshape(y_sol(no_supPix_var+1:end), param.noBoxes, []);
 box_sal_mat   =  reshape(param.saliency_vec_box, param.noBoxes, []); % for debugging
 [~, box_max_sal_inds] = min(box_sal_mat) ;
 [~, box_sol_inds] = max(box_scores_mat); % in case, more than 1 max, take the biggest
 param.box_sol_inds = box_sol_inds; 
 numel(find(box_max_sal_inds~=box_sol_inds))
 
 if param.box_form
    sup_var_im = compute_labels_4_Im(param,descr,supPix_var,supPixIndices_Im) ; 
    sup_var_im= sup_var_im/sum(sup_var_im);  % this is just a normalization..check if it is needed
    labels_Im = [sup_var_im>=.0001, sup_var_im<.0001];
    supPixIndices = supPixIndices_Im;
 else
   labels_Im = [supPix_var>=.01, supPix_var<.01];
 end
    cc = cell2mat(typeObj) ;
    
    if param.pascal_10
        param.label_mat_str = ['eval/', 'pascal_', cc, '.mat'];
    elseif param.MSRC
        param.label_mat_str = ['eval/', 'MSRC_', cc, '.mat'];
    else
        param.label_mat_str = ['eval/', 'obj_disc_', cc, '.mat'];
    end
    
    
 if param.pascal_07_06        
    exp_name = ['exp_', num2str(param.wt_saliency), '_', num2str(param.wt_BoxSaliency), '_', num2str(param.max_pixels), '_', num2str(param.optim.lambda0),'_',num2str(param.lapWght), '_', num2str(nPics),'_', num2str(param.noBoxes)];
    folder_name = cell2mat(['acc_val/',  typeObj,'/', exp_name]);
    
    if(isdir(folder_name)==0)
        mkdir(folder_name);
    end   
    if param.scaled_sal_box
        accuracy_file_name = ['/acc_new_', num2str(param.wt_saliency), '_', num2str(param.wt_BoxSaliency), '_', num2str(param.max_pixels), '_', num2str(param.optim.lambda0),'_',num2str(param.lapWght), '_', num2str(nPics),'_', num2str(param.noBoxes)];
    else
        accuracy_file_name = ['/no_scal_', num2str(param.wt_saliency), '_', num2str(param.wt_BoxSaliency), '_', num2str(param.max_pixels), '_', num2str(param.optim.lambda0),'_',num2str(param.lapWght), '_', num2str(nPics),'_', num2str(param.noBoxes)];  
    end
     plot_groups_coloc(param, folder_name, accuracy_file_name, 430, 'Ours-Joint Approach ');
 else    
     plot_groups_original(param, labels_Im, supPixIndices, 430, 'Ours-Joint Approach ');
 end
 
 if param.only_coloc ==0   
     eval_output ;
 elseif param.pascal_07_06
     eval_coloc_pascal;    
 elseif dataset==2 % obj_disc
     eval_obj_disc ; % eval both coseg and coloc
 end
 end
