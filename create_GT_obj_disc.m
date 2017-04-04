
clear all
    % format of param TEXT file
    % Class disc_term_bin_var lap_wt sift_wt color_wt text_wt nPics
for  i =26:26
    i
    fileID = fopen('param_MSRC.txt');
    C_data = textscan(fileID,'%s %f %f %f %f %f %f %f %f');
    fclose(fileID);    
%%%% PARAMETERS    
    dataset = double(C_data{4}(i));  
    no_scaling = 1;
    param.pascal_10 = 0;
        param.MSRC = 0;
        param.pascal_07_06 =0;
        param.noBoxes = 15;    
    param.scaled_sal_box = 1 ;
    param.solve_pixel_qp = 0 ;
    param.useBox = 1; param.useSaliency = 1;  % if this is set,saliency is computed supPix wise
    
    typeObj   = C_data{1}(i);
    param.wt_disc = 1;
    param.max_pixels = double(C_data{2}(i));
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
    param.reboot   = 1;
    computeParameters ;
     [descr, descr_im,param] = openFeature_box_once(param);
    % create GT boxes for obj disc data from segmentation GT
%     class = {'Horse_93', 'Aero_82', 'Car_89'}
    GT_file_suffix = '.png' ;
    eval_GT_path = cell2mat(['./eval/',typeObj,'/GT/']);
    nPics = numel(param.imFileList);
    eval_path = ['eval_coloc_files/'];
if 0
  for Im = 1:nPics
   [~ ,file_name, ~] = fileparts(param.imFileList{Im});
    GT_file = [eval_GT_path, file_name, GT_file_suffix] ;  
    GT_cell{Im} = param.imread(GT_file);
 
    rp = regionprops(GT_cell{Im}, 'BoundingBox', 'Area');
    area = [rp.Area].';
    [idx,~] = find(area>50);
     
    box_file = cell2mat([eval_path, typeObj, '/',file_name, '.mat']) ; 
    bbox_list = cell(1,length(idx));
    for j= 1:length(idx)
        b_boxes = rp(idx(j)).BoundingBox; 
        box(1:4) = b_boxes;
         box(3)= box(1)+box(3) ;
         box(4) = box(2) +box(4);
         bboxes =  round(box(1:4));
        bbox_list{1,j}= bboxes;
            bbox_list{1,j}= b_boxes;
    end
    % save GT boxes in eval path
    save(box_file, 'bbox_list');  
  end

  
  else  % if you want to visualize the GT box
  for Im = 1:10
   [~ ,file_name, ~] = fileparts(param.imFileList{Im});
    GT_file = [eval_path, typeObj, '/',file_name, '.mat'] ;  
    load(cell2mat(GT_file))
    gt_boxes = cell2mat(bbox_list);
	ngtboxes = size(gt_boxes, 1);
    if 1 % debug      
         Img = param.imread(param.imFileList{Im});
         box(1:4) = round(gt_boxes(1:4));
         box(3)= box(1)+box(3) ;
         box(4) = box(2) +box(4);
         figure;
         visualize(Img,box);
    end
    
  end
   end
   close all
   clear all
end