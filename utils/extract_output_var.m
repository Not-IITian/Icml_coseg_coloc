function [ zz,param ] = extract_output_var(z,sal_vec_box,param,im_supPix_var_cell)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
 no_supPix_var = param.no_supPix_var;
            supPix_z = z(1:no_supPix_var);
            
%         zz= [supPix_z>.5 , supPix_z<=.5];

            box_sol_vec = z(no_supPix_var+1:end);
        
        assert(length(box_sol_vec)==param.nPics*param.noBoxes);
        box_scores_mat = reshape(box_sol_vec, param.noBoxes, []);
        box_sal_mat   = reshape(sal_vec_box, param.noBoxes, []); % for debugging
        [~, box_sol_inds] = max(box_scores_mat); % in case, more than 1 max, take the biggest
        param.box_sol_inds = box_sol_inds;
%         zz   = [supPix_z>=.5, supPix_z<.5];  
        
        
        cum_no_supPix_vec = [0];
        supPix_all_img = [];
        
        for i = 1:param.nPics
            cum_count_vec = [0,cumsum(im_supPix_var_cell{i})'];
            cum_no_supPix_vec = [cum_no_supPix_vec ,cum_count_vec(end)];
            
            starting_idx = cum_no_supPix_vec(i) + cum_count_vec(box_sol_inds(i)) +1;
            end_idx = cum_no_supPix_vec(i) + cum_count_vec(box_sol_inds(i)+1);
            
            box = param.boxes(i).coords(box_sol_inds(i),:);
			box(1:4) = round(box(1:4));
            Im = param.imread(param.imFileList{i});
            
            z_supPix = param.box_supPix{i}(box_sol_inds(i),:);
%                              
%             % for debugging
%             z_supPix_binary =  [z_supPix>0];  % gives a vector of 0 and 1 telling which supPix arein box
%             z_supPix_scores =  z_supPix_binary.*supPix_z(supPix_idx(i)+1:supPix_idx(i+1))'; % gives score of supPix inside box
%             sal_vec_z = z_supPix_binary.*lin_saliency_vec(supPix_idx(i)+1:supPix_idx(i+1));
%             
%             %%%%%%%%
             non_zero_supIdx = find(z_supPix);
             z_im = zeros(length(z_supPix),1);
             
             assert(length(z_supPix)==param.lW_supPix(i));
             z_im(non_zero_supIdx) = supPix_z(starting_idx:end_idx);
             supPix_all_img = [supPix_all_img; z_im];
%             
%           
        end
%         end
     zz   = [supPix_all_img>=.08, supPix_all_img<.08];  

printMessage('Convex quadratic cosegmentation : END', 1 , mfilename, 'm');
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


end




