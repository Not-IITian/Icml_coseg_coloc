  function [lin_vec] = Compute_saliency_vec(param,descr)
%% TO DO: % use proj matrix to assert x = Py;;  sanity check and short
            % code%
saliency_path = param.saliency_path;
SP_path = param.path.superpixel;

 if param.box_form 
     total_no_cell = param.nPics*param.noBoxes ;
 else
     total_no_cell = param.nPics ;
 end
 
 sal_values_cell = cell(total_no_cell,1);
 sal_sampled_values_cell = cell(total_no_cell,1);
 scaled_sampled_values_cell = cell(total_no_cell,1);
 lin_vec_cell = cell(total_no_cell,1);
     
 for Im = 1:param.nPics        
%     [dirN baseFName ] = fileparts(List_file{Im}); 
    [dirN, baseFName ] = fileparts(param.imFileList{Im}); 
    file_name = [baseFName,'.mat']; % check if it is jpg or png
    sal_file = [saliency_path, baseFName, '_res.png'] ;
%     SP_fileName = fullfile(SP_path,file_name);
    SP_fileName = cell2mat([SP_path,file_name]);
    load (SP_fileName,'supPixIm');    
    sal_values_cell{Im} = param.imread(sal_file);
     
    if param.box_form
       for j = 1:param.noBoxes          
            idx = (Im-1)*param.noBoxes + j ;             
            sal_sampled_values = double(sal_values_cell{Im}(descr.y{idx} + size(supPixIm,1) *(descr.x{idx}-1)));           
%             sal_sampled_values_cell{Im} = double(sal_values_cell{Im}(descr.y{Im} + size(supPixIm,1)*(descr.x{Im}-1)));            
            scaled_sampled_values  = sal_sampled_values./256;                           
            supPixIndices = supPixIm(descr.y{idx} + size(supPixIm,1)*(descr.x{idx}-1)) ;   
            superPixInd = unique(supPixIndices ); % sorted vector of unique supPix idx            
            for sup_Pix = 1:length(superPixInd)        
                pixels_id = supPixIndices  == superPixInd(sup_Pix); % gives a binary vector with 1 at place of pixel belonging to supPix       
                lin_vec_cell{idx}(sup_Pix) = sum(-log(scaled_sampled_values(pixels_id) + eps)); % before it was l        
            end 
            
       end         
    else
          width_im = size(sal_values_cell{Im},1);       
          sal_sampled_values_cell{Im} = double(sal_values_cell{Im}(descr.y{Im} + width_im *(descr.x{Im}-1)));           
%             sal_sampled_values_cell{Im} = double(sal_values_cell{Im}(descr.y{Im} + size(supPixIm,1)*(descr.x{Im}-1)));            
          scaled_sampled_values_cell{Im}  = sal_sampled_values_cell{Im}./256;                        
     
          supPixIndices = supPixIm( descr.y{Im} + size(supPixIm,1) * (descr.x{Im}-1) ) ;   
          superPixInd = unique(supPixIndices ); % sorted vector of unique supPix idx          
          for sup_Pix = 1:length(superPixInd)        
              pixels_id = supPixIndices  == superPixInd(sup_Pix); % gives a binary vector with 1 at place of pixel belonging to supPix       
              lin_vec_cell{Im}(sup_Pix) = sum(-log(scaled_sampled_values_cell{Im}(pixels_id) + eps)); % before it was l        
          end  
     end 
end

clear sal_values_cell;

% if param.box_form
    lin_vec = [];
    for j =1:total_no_cell
        lin_vec = [lin_vec; lin_vec_cell{j}'];
    end
% else
%     lin_vec = cell2mat(lin_vec_cell);
% end% output will be nsupPix vector
end