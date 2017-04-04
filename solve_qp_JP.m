%solve Jean QP
opts = optimset('Diagnostics', 'on', 'Algorithm', 'interior-point-convex');
a = param.C;
no_supPix_var = numel(saliency_vec);
param.no_supPix_var = no_supPix_var ;     
 
 if param.wt_disc || param.lapWght
%          B = zeros(param.nPics*param.noBoxes);
%          a = param.lambd*a; 
%          A = blkdiag(a,B);
        bb = param.mu*C_box;  % this is a relative term to keep the weightage of box high compared to segmentation           
%          bb = lapMatrix_box + param.mu * rrMatrix;
        A = blkdiag(a,bb);
 end    
  N = no_supPix_var + param.nPics* param.noBoxes ;
    
  sal_vec_box = param.saliency_vec_box/sum(param.saliency_vec_box) ;
  sal_vec_box = param.wt_BoxSaliency *sal_vec_box;
   
  saliency_vec = saliency_vec/sum(saliency_vec);
  saliency_vec = param.wt_saliency*saliency_vec;       
%   saliency_vec = param.lambd* saliency_vec   ;   
  if param.wt_BoxSaliency && param.wt_saliency  
      saliency_vec_joint = [saliency_vec', sal_vec_box] ;
  end                      
% 	% set up inequality matrix    
% first for loop for less than case
    kk = 1; cum_no_supbox_vec  = [0];
     Aineq = [] ;
    total_supPix_var = param.total_supPix_var ; % this is cumulative of all boxes ie. X Vector
    bineq = [] ; num_constraints = 0;    
    for i = 1:param.nPics      
            cum_count_vec = [0,cumsum(im_supPix_var_cell{i})'];  
            
            sup_pix_before_this_img = cum_no_supbox_vec(end) ;        
            cum_no_supbox_vec = [cum_no_supbox_vec ,cum_count_vec(end)+ sup_pix_before_this_img]; % for each image
        
            for j = 1:param.noBoxes
                supPix_vec = zeros(1,total_supPix_var);
                starting_idx = cum_no_supbox_vec(i) + cum_count_vec(j) +1;
                end_idx = cum_no_supbox_vec(i) + cum_count_vec(j+1);
                supPix_vec(starting_idx:end_idx) = box_supPix_non_zeros{i}{j};  % check this
                  
                box_idx = (i-1)*param.noBoxes + j ;
                box_vec = zeros(1,param.nPics*param.noBoxes);
                box_vec(box_idx) = -(.9)*sum(supPix_vec) ;
            
                SupPix_box_vec = [supPix_vec, box_vec] ;  
                Aineq(kk,:) = SupPix_box_vec;
                kk = kk+1;        
            end	
    end
     bineq = zeros(param.nPics*param.noBoxes,1);
        num_constraints = kk-1 ;  
        
    kk = 1; cum_no_supPix_vec = [0];
    num_constraints = param.nPics*param.noBoxes;
    % this is for upper bound    
   kk = 1; cum_no_supbox_vec = [0];    
    fg_box = 1;
    % this is for lower bound 
    for i = 1:param.nPics
        
        cum_count_vec = [0,cumsum(im_supPix_var_cell{i})'];       
        sup_pix_before_this_img = cum_no_supbox_vec(end) ;        
        cum_no_supbox_vec = [cum_no_supbox_vec ,cum_count_vec(end)+ sup_pix_before_this_img]; % for each image
        
        for j = 1:param.noBoxes
            supPix_vec = zeros(1,total_supPix_var);
            starting_idx = cum_no_supbox_vec(i) + cum_count_vec(j) +1;
            end_idx = cum_no_supbox_vec(i) + cum_count_vec(j+1);
            supPix_vec(starting_idx:end_idx) = box_supPix_non_zeros{i}{j};
            
            box_idx = (i-1)*param.noBoxes + j ;
            box_vec = zeros(1,param.nPics*param.noBoxes);
            
            if fg_box
                box_vec(box_idx) = (-1*param.optim.lambda0)*sum(supPix_vec) ;  % if foreground is considered only inside box          
            else
                total_sampled_pixels_im = 0 ;            
                box_vec(box_idx) = (-1*param.optim.lambda0)*param.lW_px(i) ;  %  foreground is considered over all image                                                                              
            end
            
            SupPix_box_vec = -1*[supPix_vec, box_vec] ;         
            Aineq(kk+ num_constraints,:) = SupPix_box_vec;
            kk = kk +1;           
         end
    end 
    
	bineq = [bineq; zeros(param.nPics*param.noBoxes,1)];    
    num_constraints = num_constraints + kk -1 ;
    
    % add the inequality constraint that fg could be present in only one
    % box   
     box_full_vec = param.noBoxes *ones(1,param.nPics);
    box_full_vec_idx = [0, cumsum( box_full_vec)];    
    kk = 1; cum_no_supbox_vec = [0];
%    
    for i = 1:param.nPics
        
        cum_count_vec = [0,cumsum(im_supPix_var_cell{i})'];      
        sup_pix_before_this_img = cum_no_supbox_vec(end) ;    
        cum_no_supbox_vec = [cum_no_supbox_vec ,cum_count_vec(end)+ sup_pix_before_this_img]; % for each image
        
        for j = 1:param.lW_supPix(i)
                       
            active_boxes_idx = find(param.box_supPix{i}(:,j));   % active wrt the particular supPix                                        
            sup_Pix_lin_idx = [];
            
            if numel(active_boxes_idx)
                sup_Pix_vec = zeros(1,total_supPix_var);
                
                for k = 1:numel(active_boxes_idx)
                    idx_box = active_boxes_idx(k);
                    
                    non_zeros_supPix_idx = find(param.box_supPix{i}(idx_box,:));  % it gives non zero supPix idx for active box
                    
                    sup_var_idx = find(non_zeros_supPix_idx==j) ; 
                    
                    sup_lin_idx = cum_no_supbox_vec(i) + cum_count_vec(idx_box) + sup_var_idx;
                    
                    sup_Pix_lin_idx = [sup_Pix_lin_idx, sup_lin_idx];
                end            
                sup_Pix_vec(sup_Pix_lin_idx) = 1;
                box_vec = zeros(1,param.nPics*param.noBoxes);               
                box_vec_idx = box_full_vec_idx(i)+ active_boxes_idx;
                  box_vec(box_vec_idx ) = -1;
                  
                  SupPix_box_vec = [sup_Pix_vec, box_vec] ;
                  
                 Aineq(kk+ num_constraints,:) = SupPix_box_vec;
%                     Aineq(kk,:) = SupPix_box_vec;  % when no bounds const
                    kk = kk+1;
            end
         end
    end
     bineq = [bineq; zeros(kk-1,1)];  
 
%         bineq = [bineq;ones( kk-1,1)];  % when no bounds constraints
    % setup equality matrix   
    for i = 1:param.nPics        
           box_id = (i-1)*param.noBoxes  ;
            box_vec = zeros(1,param.nPics*param.noBoxes);
            box_vec(box_id+1:box_id+param.noBoxes) = 1 ;
            assert(sum(box_vec)==param.noBoxes);            
            supPi_box_vec = [zeros(1,no_supPix_var), box_vec] ;            
            Aeq(i,:) = supPi_box_vec;       
    end    
	beq = ones(param.nPics,1);
     
    [x_sol, fval, exitflag, output, lambda] = quadprog(A, saliency_vec_joint', Aineq, bineq, Aeq, beq, zeros(1,N), ones(1,N), [], opts);
        