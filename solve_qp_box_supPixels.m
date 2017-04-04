%  this scripts solves the qp at superpixel level...meaning the constraints
%  defined on superpixel has  0/1 superpixel binary instead of number of
%  pixels each supPix have


% List of variables needed for this script, which are computed
% somewhere else:
% 1. im_supPix_var_cell calculated in computematrixforConvQuadOptim.m
% it gives for each image, a vector telling the no of pixels for each image

%  2. Proj_box_supPix_mat : this is a matrix that maps the duplicated
%  SuperPixels (concatenated variables of all bounding box)to superPixels
%  of an image (without duplication). This is also computed in computematrixforConvQuadOptim.m

a = param.C;
qp_for_box = 0 ;
	% set up options
	opts = optimset('Diagnostics', 'on', 'Algorithm', 'interior-point-convex');

	% solve lp just for box finding based on saliency
    if param.wt_disc==0 && param.wt_hist_sift==0 && param.wt_hist_col ==0 && param.wt_saliency==0 && param.lapWght ==0
        
         saliency_vec = param.saliency_vec_box;
         sal_vec_box = saliency_vec;
         
          N = numel(saliency_vec);
         assert (param.nPics*param.noBoxes== N);
     % set up the equality constraints of having one box per image
         for i = 1:param.nPics
             
            box_id = (i-1)*param.noBoxes  ;
            box_vec = zeros(1,param.nPics*param.noBoxes);
            box_vec(box_id+1:box_id+param.noBoxes) = 1 ;
                                 
            Aeq(i,:) = box_vec;
         end  
          
        beq = ones(param.nPics,1);
              
        [x_sol, fval, exitflag, output, lambda] = linprog( saliency_vec', [],[], Aeq, beq, zeros(1,N), ones(1,N), [], opts);

    else
    
        no_supPix_var = numel(saliency_vec);
        param.no_supPix_var = no_supPix_var ;
     
        if qp_for_box
%          B = zeros(param.nPics*param.noBoxes);
%          a = param.lambd*a; 
%          A = blkdiag(a,B);
            a = param.lambd*a;  % this is a relative term to keep the weightage of box high compared to segmentation
            
            bb = lapMatrix_box + param.mu * rrMatrix;
            
        else
            bb = zeros(param.nPics*param.noBoxes);
        end    
        A = blkdiag(a,bb);
        
        N = no_supPix_var + param.nPics* param.noBoxes ;
    
        sal_vec_box = param.saliency_vec_box/sum(param.saliency_vec_box) ;
        sal_vec_box = param.wt_BoxSaliency *sal_vec_box;
   
        saliency_vec = saliency_vec/sum(saliency_vec);
        saliency_vec = param.wt_saliency*saliency_vec ;        
        % saliency_vec = param.lambd* saliency_vec   ; why lambda   
        saliency_vec_joint = [saliency_vec, sal_vec_box] ;
                 
    % constraints...............................        
% 	% set up inequality matrix
    
% first for loop for less than case
    kk = 1; cum_no_supbox_vec = [0];
    Aineq = [] ;
    total_supPix_var = param.total_supPix_var ; % this is cumulative of all boxes ie. X Vector
    bineq = [] ;
    num_constraints = 0;
    
    if 1
        for i = 1:param.nPics
        
            cum_count_vec = [0,cumsum(im_supPix_var_cell{i})'];  
            
            sup_pix_before_this_img = cum_no_supbox_vec(end) ;
        
        cum_no_supbox_vec = [cum_no_supbox_vec ,cum_count_vec(end)+ sup_pix_before_this_img]; % for each image
        
            for j = 1:param.noBoxes
                supPix_vec = zeros(1,total_supPix_var);
                starting_idx = cum_no_supbox_vec(i) + cum_count_vec(j) +1;
                end_idx = cum_no_supbox_vec(i) + cum_count_vec(j+1);
%                  supPix_vec(starting_idx:end_idx) = box_supPix_non_zeros{i}{j};  % check this
            
% binary vector defined on superPixel

                supPix_bin_vec = ones(1, numel(box_supPix_non_zeros{i}{j})) ;
               supPix_vec(starting_idx:end_idx) = supPix_bin_vec ;
          
                box_idx = (i-1)*param.noBoxes + j ;
                box_vec = zeros(1,param.nPics*param.noBoxes);
                box_vec(box_idx) = -(.85)*sum(supPix_vec) ;
            
                SupPix_box_vec = [supPix_vec, box_vec] ;
            
                Aineq(kk,:) = SupPix_box_vec;
                kk = kk+1;
            
            end
% 		
        end
    
    bineq = zeros(param.nPics*param.noBoxes,1);
    num_constraints = kk-1 ;      
    end
 
 if 1
    kk = 1; cum_no_supbox_vec = [0];
   
    % this is for upper bound
 
    for i = 1:param.nPics
        
        cum_count_vec = [0,cumsum(im_supPix_var_cell{i})'];
        
        sup_pix_before_this_img = cum_no_supbox_vec(end) ;
        
        cum_no_supbox_vec = [cum_no_supbox_vec ,cum_count_vec(end)+ sup_pix_before_this_img]; % for each image
        
        for j = 1:param.noBoxes
            supPix_vec = zeros(1,total_supPix_var);
            starting_idx = cum_no_supbox_vec(i) + cum_count_vec(j) +1;
            end_idx = cum_no_supbox_vec(i) + cum_count_vec(j+1);
            
%             supPix_vec(starting_idx:end_idx) = box_supPix_non_zeros{i}{j};
            
            % edited by me for binary optimisatiton
             supPix_bin_vec = ones(1, numel(box_supPix_non_zeros{i}{j})) ;
               supPix_vec(starting_idx:end_idx) = supPix_bin_vec ;
               
               % end
            box_idx = (i-1)*param.noBoxes + j ;
            box_vec = zeros(1,param.nPics*param.noBoxes);
            box_vec(box_idx) = (-1*param.optim.lambda0)*sum(supPix_vec) ;
            
            SupPix_box_vec = -1*[supPix_vec, box_vec] ;
            
            Aineq(kk+ num_constraints,:) = SupPix_box_vec;
            kk = kk +1;
            
         end
    end 
    
	bineq = [bineq; zeros(param.nPics*param.noBoxes,1)];
    num_constraints = num_constraints + kk -1 ; 
 end  
    % add the inequality constraint that fg could be present in only one
    % box
    
 if 1
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
    
 end 
     % this is for joint optimisation over (y+z)
    A_ineq_in_y =  Aineq*Proj_box_supPix_mat ; 
    
%     bineq = zeros(2*param.nPics*param.noBoxes + kk-1,1);

    
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
    
    if param.wt_disc==0 && param.wt_hist_sift==0 && param.wt_hist_col ==0 && param.lapWght ==0
        
        [x_sol, fval, exitflag, output, lambda] = linprog( saliency_vec_joint', Aineq, bineq, Aeq, beq, zeros(1,N), ones(1,N), [], opts);
    else
        [x_sol, fval, exitflag, output, lambda] = quadprog(A, saliency_vec_joint', A_ineq_in_y, bineq, Aeq, beq, zeros(1,N), ones(1,N), [], opts);
        
    end
    end
