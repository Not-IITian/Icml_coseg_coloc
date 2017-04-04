% Sup_occurence_cell, computed in compute_box_proj_mat stores 
%for each superPix in image, the idx of box it belongs to and
% the corresponding sorted idx in that box

% Global var computed before
no_boxes = param.noBoxes ;
no_im = param.nPics ;
total_supPix_var = param.tot_SupPix ;
no_Sup_per_box = param.local_supPix ;
Sup_im_mat = reshape(no_Sup_per_box, [no_boxes,no_im]); % stores 
count_Im_level = sum(Sup_im_mat,1);
% Constraint that pixel can be fg in only one box..
box_full_vec = no_boxes*ones(1,no_im);
box_full_vec_idx = [0, cumsum( box_full_vec)];    
kk = 1; Unique_fg_ineq = [];
  cum_count_Im = [0,cumsum(count_Im_level)] ;
  
  for i = 1:no_im   
        occurence     = Sup_occurence_cell{i};
        cum_count_box_level = [0, cumsum(Sup_im_mat(:,i))'];  
        all_sup = supPixIndices_Im{i} ;          
        for j = 1:numel(all_sup)                      
            active_boxes_idx = occurence.box_idx{all_sup(j)};   % active wrt the particular supPix                                        
            sup_Pix_lin_idx = [];
            supPix_idx = occurence.sup_sorted_idx{all_sup(j)} ;
            if numel(active_boxes_idx)
                sup_Pix_vec = zeros(1,total_supPix_var);              
                for k = 1:numel(active_boxes_idx)
                    idx_box = active_boxes_idx(k);                    
                    sup_lin_idx =  cum_count_box_level(idx_box) + supPix_idx(k);                                   
                    sup_Pix_lin_idx = [sup_Pix_lin_idx, sup_lin_idx];
                end  
                sup_Pix_var_idx = cum_count_Im(i) + sup_Pix_lin_idx; % these many superpixel before this image
                sup_Pix_vec(sup_Pix_lin_idx) = 1;
                box_vec = zeros(1,no_im*no_boxes);               
                box_vec_idx = box_full_vec_idx(i)+ active_boxes_idx;
                 box_vec(box_vec_idx ) = -1;
                SupPix_box_vec = [sup_Pix_vec, box_vec] ;           
                Unique_fg_ineq(kk,:) = SupPix_box_vec;
                kk = kk+1;
            end
         end
  end
     Unique_fg_rhs = zeros(kk-1,1);  
  % constraint on the size of fg in boxes
  kk = 1; cum_no_supbox_vec  = [0];
   size_ineq = [] ; size_ineq_rhs = [] ;  
   pixel_level_count = 0;
    for i = 1:no_im   
         cum_count_box_level = [0, cumsum(Sup_im_mat(:,i))'];              
            for j = 1:no_boxes
                supPix_vec = zeros(1,total_supPix_var);
                starting_idx = cum_count_Im(i) + cum_count_box_level(j) +1;
                end_idx = cum_count_Im(i) + cum_count_box_level(j+1);
                % this determines if we count the supPix in fg or just the
                % no of sup pixel
                if pixel_level_count
                    supPix_vec(starting_idx:end_idx) = pixel_perBox_cell{i}{j};  
                else
                    supPix_vec(starting_idx:end_idx) = ones(numel(pixel_perBox_cell{i}{j}),1) ;
                end
                box_idx = (i-1)*no_boxes + j ;
                box_vec = zeros(1,no_im*no_boxes);
                box_vec(box_idx) = -(.9)*sum(supPix_vec) ;          
                SupPix_box_vec = [supPix_vec, box_vec] ;  
                size_ineq(kk,:) = SupPix_box_vec;
                kk = kk+1;        
            end	
    end
 size_ineq_rhs = zeros(no_im*no_boxes,1);
  no_size_constraints = kk-1 ;    
  % upper bound size constraints..
  pixel_level_count = 0;
  for i = 1:no_im   
         cum_count_box_level = [0, cumsum(Sup_im_mat(:,i))'];              
            for j = 1:no_boxes
                supPix_vec = zeros(1,total_supPix_var);
                starting_idx = cum_count_Im(i)+cum_count_box_level(j) +1;
                end_idx = cum_count_Im(i) + cum_count_box_level(j+1);
                if pixel_level_count
                    supPix_vec(starting_idx:end_idx) = -1*pixel_perBox_cell{i}{j}; 
                else
                    supPix_vec(starting_idx:end_idx) = -1*ones(numel(pixel_perBox_cell{i}{j}),1);
                end
                box_idx = (i-1)*no_boxes + j ;
                box_vec = zeros(1,no_im*no_boxes);
                box_vec(box_idx) = param.optim.lambda0*sum(supPix_vec) ;          
                SupPix_box_vec = [supPix_vec, box_vec] ;  
                size_ineq(kk,:) = SupPix_box_vec;
                kk = kk+1;        
            end	
    end
  size_ineq_rhs = [size_ineq_rhs; zeros(no_im*no_boxes,1)];
  Aeq = []; 
  for i = 1:no_im       
        box_id = (i-1)*no_boxes  ;
        box_vec = zeros(1,no_im*no_boxes);
        box_vec(box_id+1:box_id+no_boxes) = 1 ;
        assert(sum(box_vec)==no_boxes);            
         supPi_box_vec = [zeros(1,total_supPix_var), box_vec] ;  
         if param.only_coloc
              Aeq(i,:) = box_vec ;
         else
            Aeq(i,:) = supPi_box_vec;     
         end
  end    
beq = ones(no_im,1);
  % linear vector 
sal_vec_box = param.saliency_vec_box/sum(param.saliency_vec_box) ; % is the normalization needed
sal_vec_box = param.wt_BoxSaliency *sal_vec_box;
   
 saliency_vec = saliency_vec/sum(saliency_vec);
 saliency_vec = param.wt_saliency* saliency_vec;       
 % define objective function depending upon the case
a = param.C;
bb = param.mu*C_box;  % this is a relative term to keep the weightage of box high compared to segmentation 
opts = optimset('Diagnostics', 'on', 'Algorithm', 'interior-point-convex');

%% Case1 : only coloc 
if param.only_coloc
    A = bb;
    N = no_im*no_boxes;
    saliency_vec_joint = sal_vec_box ;
%% case2: only coseg 
    [x_sol, fval, exitflag, output, lambda] = quadprog(A, saliency_vec_joint', [], [], Aeq, beq, zeros(1,N), ones(1,N), [], opts);
else

%% case 3 joint coloc-coseg
    A = blkdiag(a,bb);
    saliency_vec_joint = [saliency_vec', sal_vec_box] ;
    N = total_supPix_var + no_im*no_boxes;
    
    Aineq = [Unique_fg_ineq;size_ineq] ;
%     Aineq = [size_ineq] ;
    bineq = [Unique_fg_rhs;size_ineq_rhs];
%     bineq = [size_ineq_rhs];   
    [x_sol, fval, exitflag, output, lambda] = quadprog(A, saliency_vec_joint', Aineq, bineq, Aeq, beq, zeros(1,N), ones(1,N), [], opts);
end