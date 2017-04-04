% function [z,zSoft] = convexQuadraticCoseg(param, projMatrix, lapMatrix , xDif)
% function [zz,zSoft, param] = convexQuadraticCoseg(param, projMatrix, lapMatrix , xDif, Hist_term_sift,Hist_term_col,Hist_term_mr,lin_saliency_vec,supPixIndices)
function [paramDif ,im_supPix_var_cell,box_supPix_non_zeros,Proj_box_supPix_mat ] = convexQuadraticCoseg ( param, projMatrix, lapMatrix , xDif)

printMessage('Convex quadratic cosegmentation : BEGIN', 1 , mfilename, 'm');
paramDif                    = param;


xDif                        = ridgeKernel( xDif, param.lambda );
paramDif.optim.tab_lambda0  = floor( param.lW_px*param.optim.lambda0 + 1);

if 0
paramDif.one_pic        = createIndexMatrix(param.lW_px, param.nPics, param.nDescr);
paramDif.one_pic_bar    = paramDif.one_pic;
paramDif.one_pic        = projMatrix'*paramDif.one_pic;
end

X_dif_term = (xDif * projMatrix)' * xDif * projMatrix ;
clear xDif

% Disc_mat = (projMatrix'*projMatrix - sum(projMatrix)'*sum(projMatrix)/param.nDescr - (xDif * projMatrix)' * xDif * projMatrix);
    Disc_mat = (projMatrix'*projMatrix - sum(projMatrix)'*sum(projMatrix)/param.nDescr - X_dif_term); 
   Lap_mat = param.lapWght*lapMatrix;    
    C = Disc_mat ; % what are the
clear xDif projMatrix ;

  if param.lapWght 
        C   = C + Lap_mat;
  end
   
 C       = C ./ param.nDescr;
 trC     = trace(C);
 C       = C/trC;
 paramDif.C = C;
 clear lapMatrix 
% paramDif.C              = computeMatrixForConvQuadOptim(param, xDif, lapMatrix, projMatrix);
%%%%% my code
[im_supPix_var_cell,box_supPix_non_zeros,  Proj_box_supPix_mat, total_supPix_var]  = computeMatrixForConvQuadOptim(param);


paramDif.total_supPix_var = total_supPix_var ;


    
%     if param.wt_saliency
%         lin_saliency_vec = param.wt_saliency*lin_saliency_vec;
%     else
%         lin_saliency_vec = zeros(1,sum(param.lW_supPix));
%     end
%    
%     [z, sal_vec_box] = solve_qp_box(paramDif ,Sal_vec,im_supPix_var_cell,box_supPix_non_zeros) ;
%     
%     if param.useBox
%             % solving an lp for box finding only
%          if param.wt_disc==0 && param.wt_hist_sift==0 && param.wt_hist_col ==0 && param.wt_saliency==0 && param.lapWght ==0
%        
%                 box_sol_vec = z;
%                 box_scores_mat = reshape(box_sol_vec, param.noBoxes, []);
%                 box_sal_mat   = reshape(sal_vec_box, param.noBoxes, []); % for debuging
%                 [~, box_sol_inds] = max(box_scores_mat); % in case, more than 1 max, take the biggest
%         
%                 for i = 1:param.nPics
%             
%                     box = param.boxes(i).coords(box_sol_inds(i),:);
%                     box(1:4) = round(box(1:4));
%                     Im = param.imread(param.imFileList{i});
%                     box_mask = Im(box(2):box(4),box(1):box(3),:);
%                     figure;
%                     imshow(box_mask);
%                 end

% 
%          else
%             no_supPix_var = numel(Sal_vec);
%             supPix_z = z(1:no_supPix_var);
%             
% %         zz= [supPix_z>.5 , supPix_z<=.5];
% 
%             box_sol_vec = z(no_supPix_var+1:end);
%         
%         assert(length(box_sol_vec)==param.nPics*param.noBoxes);
%         box_scores_mat = reshape(box_sol_vec, param.noBoxes, []);
%         box_sal_mat   = reshape(sal_vec_box, param.noBoxes, []); % for debugging
%         [~, box_sol_inds] = max(box_scores_mat); % in case, more than 1 max, take the biggest
%         param.box_sol_inds = box_sol_inds;
% %         zz   = [supPix_z>=.5, supPix_z<.5];  
%         
%         
%         cum_no_supPix_vec = [0];
%         supPix_all_img = [];
%         
%         for i = 1:param.nPics
%             cum_count_vec = [0,cumsum(im_supPix_var_cell{i})'];
%             cum_no_supPix_vec = [cum_no_supPix_vec ,cum_count_vec(end)];
%             
%             starting_idx = cum_no_supPix_vec(i) + cum_count_vec(box_sol_inds(i)) +1;
%             end_idx = cum_no_supPix_vec(i) + cum_count_vec(box_sol_inds(i)+1);
%             
%             box = param.boxes(i).coords(box_sol_inds(i),:);
% 			box(1:4) = round(box(1:4));
%             Im = param.imread(param.imFileList{i});
%             
%             z_supPix = param.box_supPix{i}(box_sol_inds(i),:);
% %                              
% %             % for debugging
% %             z_supPix_binary =  [z_supPix>0];  % gives a vector of 0 and 1 telling which supPix arein box
% %             z_supPix_scores =  z_supPix_binary.*supPix_z(supPix_idx(i)+1:supPix_idx(i+1))'; % gives score of supPix inside box
% %             sal_vec_z = z_supPix_binary.*lin_saliency_vec(supPix_idx(i)+1:supPix_idx(i+1));
% %             
% %             %%%%%%%%
%              non_zero_supIdx = find(z_supPix);
%              z_im = zeros(length(z_supPix),1);
%              
%              assert(length(z_supPix)==param.lW_supPix(i));
%              z_im(non_zero_supIdx) = supPix_z(starting_idx:end_idx);
%              supPix_all_img = [supPix_all_img; z_im];
% %             
% %           
%         end
% %         end
% 
% %     else
% %         zz= [z>.5 , z<=.5];
%     end
%         zz   = [supPix_all_img>=.5, supPix_all_img<.5];  
% 
%     if (~exist('zSoft', 'var'))
%         zSoft = [];
%     end
% 
%     
% printMessage('Convex quadratic cosegmentation : END', 1 , mfilename, 'm');
% end
% 
% 
