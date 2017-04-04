 % Compute solution from Joulin et. al. cvpr'10 and Joulin et al. cvpr'12
 % function run_coseg(param,typeObj,nPics,typeFeat,lapWght) 
computeParameters;% Parameters setting
cc = cell2mat(typeObj) ;
if param.pascal_07_06
    if param.noBoxes == 20
        class_file_name = ['pascal_07_RP_20/', cc, '_matrix', '.mat'];
    else
       class_file_name = ['pascal_07_RP_20/', cc, '_matrix', '_',num2str(param.noBoxes), '.mat']; 
    end
elseif dataset ==2
    if param.noBoxes == 20
        class_file_name = ['obj_disc_RP/', cc, '_matrix', '.mat'];
    else
        class_file_name = ['obj_disc_RP/', cc, '_matrix','_',num2str(param.noBoxes), '.mat'];
    end  
end
 if isempty(dir(class_file_name)) % replace this exist param.mat
    
[descr, descr_im,param] = openFeature_box_once(param);
    % load the box file
    cc = cell2mat(typeObj) ;
   if param.pascal_07_06    
       if param.noBoxes == 10
            box_file = ['pascal_07_RP/', cc, '.mat'];
       else
           box_file = ['pascal_07_RP_20/', cc, '.mat'];
       end
   elseif param.pascal_10
       box_file = ['pascal_10_RP/', cc, '.mat'];
   elseif dataset==2 % object disc
        if param.noBoxes == 20
                box_file = ['obj_disc_RP/', cc, '.mat'];
        else
            box_file = ['obj_disc_RP/', cc,'_',num2str(param.noBoxes) '.mat'];
        end
   end   
 load(box_file) ;
 param.boxes = Region_props;
    
deep_net_name= 'imagenet-caffe-alex.mat' ;
if param.pascal_07_06
    if param.noBoxes == 20
        param.box_feat_file = ['pascal_07_RP_20/', cc, 'feat_file','.mat'];
    else
        param.box_feat_file = ['pascal_07_RP_20/', cc, 'feat_file','_', num2str(param.noBoxes),'.mat'];
    end
elseif dataset==2
    if param.noBoxes == 20
        param.box_feat_file = ['obj_disc_RP/', cc, 'feat_file','.mat'];
    else
         param.box_feat_file = ['obj_disc_RP/', cc, 'feat_file','_', num2str(param.noBoxes),'.mat'];
    end
end

C_box = compute_box_ridge_mat(param) ;

    
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

lapMatrix = projMatrix' * lapMatrix * projMatrix;

%%%%%%%%%%%%%%%% CVPR'10 %%%%%%%%%%%%%%%%%%%%     
[param ,im_supPix_var_cell,box_supPix_non_zeros, Proj_box_supPix_mat] = convexQuadraticCoseg_fast(param, projMatrix, xDif);
C = param.C ;

box_supPix = param.box_supPix;
nDescr= param.nDescr;
total_supPix_var = param.total_supPix_var;
lW_supPix = param.lW_supPix ;
supPixFileList =param.supPixFileList;
save(class_file_name, 'im_supPix_var_cell', 'box_supPix_non_zeros', 'C', 'Proj_box_supPix_mat', 'box_supPix', 'lapMatrix','nDescr', 'saliency_vec', 'C_box', 'Region_props','total_supPix_var','lW_supPix','supPixFileList','supPixIndices', '-v7.3')
else
    
    load (class_file_name, 'im_supPix_var_cell', 'box_supPix_non_zeros', 'C', 'Proj_box_supPix_mat', 'box_supPix', 'lapMatrix', 'nDescr', 'saliency_vec', 'C_box','Region_props', 'total_supPix_var', 'supPixFileList','supPixIndices','lW_supPix' )
    param.boxes = Region_props;
    param.nDescr = nDescr;
    param.box_supPix = box_supPix ;
    param.supPixFileList = supPixFileList;
    param.C = C;
    param.total_supPix_var= total_supPix_var;
    param.lW_supPix = lW_supPix;
end

Lap_mat = param.lapWght*lapMatrix;
 if param.lapWght 
        C   = C + Lap_mat;
 end   
 C       = C ./ param.nDescr;
 trC     = trace(C);
 C       = C/trC;
clear Lap_mat lapMatrix 

[param.saliency_vec_box] = Compute_saliency_box(param);
if param.box_form
   solve_qp_JP_modular;
else
  solve_qp_box_pixels ;
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
   labels_Im = [supPix_var>=.0097, supPix_var<.0097];
 end
    
    if param.pascal_10
        param.label_mat_str = ['eval/', 'pascal_', cc, '.mat'];
    elseif param.MSRC
        param.label_mat_str = ['eval/', 'MSRC_', cc, '.mat'];
    else
        param.label_mat_str = ['eval/', 'obj_disc_', cc, '.mat'];
    end
    
if  ~isfield( param,'imFileList')  
   param=  createImageFileList(param);
end
 if param.ViewOn == 1
     plot_groups_original(param, labels_Im, supPixIndices, 430, 'Ours-Joint Approach ');
 end
 if param.only_coloc ==0   
     eval_output ;
 elseif param.pascal_07_06
     eval_coloc_fast;    
 elseif dataset==2 % obj_disc
     eval_obj_disc ; % eval both coseg and coloc
 end
 close all
 
