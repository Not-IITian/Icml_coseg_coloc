 function [x_sol,cell_supPix]= solve_qp_box(param,saliency_vec,projMatrix)
%% SOLVE QP USING MATLAB SOLVER AND RECONSTRUCT SOLUTION
a = param.C;
	% set up options
	opts = optimset('Diagnostics', 'on', 'Algorithm', 'interior-point-convex');

	% solve lp just for box finding based on saliency
    if param.wt_disc==0 && param.wt_hist_sift==0 && param.wt_hist_col ==0 

        
         saliency_vec = param.saliency_vec_box;
          N = numel(saliency_vec);
         assert (param.nPics*param.noBoxes== N);
         for i = 1:param.nPics
            box_id = (i-1)*param.noBoxes  ;
            box_vec = zeros(1,param.nPics*param.noBoxes);
            box_vec(box_id+1:box_id+param.noBoxes) = 1 ;
                                 
            Aeq(i,:) = box_vec;
          end  
        beq = ones(param.nPics,1);
        
        cell_supPix = [];
        [x_sol, fval, exitflag, output, lambda] = linprog( saliency_vec', [],[], Aeq, beq, zeros(1,N), ones(1,N), [], opts);

    else
% 	[x, fval, exitflag, output, lambda] = quadprog(A, b, [], [], Aeq, beq, zeros(1,N), ones(1,N), [], opts);


% implicit constraint x = P*y
        
    B = zeros(param.nPics*param.noBoxes);
    A = blkdiag(a,B);
    
    N = numel(saliency_vec) + param.nPics* param.noBoxes ;
    
    saliency_vec = [saliency_vec, zeros(1, param.nPics*param.noBoxes)] ;
      
    supPix_idx = [0, cumsum( param.lW_supPix')];
    cell_supPix = cell(param.nPics,1);  % this is to store a matrix, which tells for each box, which supPix are active (including no of pixels inside)
    
    
    for i = 1:param.nPics
        for j = 1:param.noBoxes
            cell_supPix{i}(j,:) = zeros(1,param.nSupPix);
            cell_supPix{i}(j,supPix_idx(i)+1:supPix_idx(i+1)) = param.box_supPix{i}(j,:);  % cell of no of images, each is no of box by im_supPix 
        end
    end
        
    
% 	% set up inequality matrix at x level 
    
% first for loop for less than case
    kk = 1;
    for i = 1:param.nPics
            
        for j = 1:param.noBoxes
            
            supPix_vec = cell_supPix{i}(j,:);
            box_idx = (i-1)*param.noBoxes + j ;
            box_vec = zeros(1,param.nPics*param.noBoxes);
            box_vec(box_idx) = -(1-param.optim.lambda0)*sum(supPix_vec) ;
            
            SupPix_box_vec = [supPix_vec, box_vec] ;
            
            Aineq(kk,:) = SupPix_box_vec;
            kk = kk+1;
            
        end
% 		
    end
    
    kk = 1;
    num_constraints = param.nPics*param.noBoxes;
    % this is for upper bound
    for i = 1:param.nPics
        for j = 1:param.noBoxes
            supPix_vec = cell_supPix{i}(j,:);
            box_idx = (i-1)*param.noBoxes + j ;
            box_vec = zeros(1,param.nPics*param.noBoxes);
            box_vec(box_idx) = (-1*param.optim.lambda0)*sum(supPix_vec) ;
            
            SupPix_box_vec = -1*[supPix_vec, box_vec] ;
            
            Aineq(kk+ num_constraints,:) = SupPix_box_vec;
            kk = kk +1;
            
         end
    end  
% 	bineq = zeros(2*param.nPics*param.noBoxes,1);
    
    % add the inequality constraint that fg could be present in only one
    % box
    
% Ineq_sup_box_mat = zeros(param.nSupPix, param.nPics*param.noBoxes);  % this is to 
    box_full_vec = param.noBoxes *ones(param.nPics,1);
    box_full_vec_idx = [0, cumsum( box_full_vec')];    
    kk = 1;
    % calculates a matrix, of supPix by no of boxes, which gives a vector
    % of active boxes for each supPix
    for i = 1:param.nPics
        for j = 1:param.lW_supPix(i)
            sup_idx = supPix_idx(i) + j;       % calculate the linear idx of supPix           
%             active_boxes_vec = zeros(param.noBoxes,1);             
            active_boxes_idx = find(param.box_supPix{i}(:,j));   % active wrt the particular supPix            
                        
            sup_Pix_vec = zeros(1,param.nSupPix);
            sup_Pix_vec(sup_idx) = 1;
            
            if numel(active_boxes_idx)
                for k= 1:numel(active_boxes_idx)
                    box_vec = zeros(1,param.nPics*param.noBoxes);                     
                    box_vec( box_full_vec_idx(i)+ active_boxes_idx(k)) = -1;
                    SupPix_box_vec = [sup_Pix_vec, box_vec] ;
                    Aineq(kk+ 2*num_constraints,:) = SupPix_box_vec;
                    kk = kk+1;
                end
            end
                    
%             active_boxes_vec(active_boxes_idx) =1;
%             Ineq_sup_box_mat(sup_idx, box_full_vec_idx(i)+1:box_full_vec_idx(i+1)) = active_boxes_vec;  % cell of no of images, each is no of box by im_supPix 
        end
    end    
    
    bineq = zeros(2*param.nPics*param.noBoxes + kk-1,1);

    % setup equality matrix
    
    for i = 1:param.nPics
        
            
            box_id = (i-1)*param.noBoxes  ;
            box_vec = zeros(1,param.nPics*param.noBoxes);
            box_vec(box_id+1:box_id+param.noBoxes) = 1 ;
            assert(sum(box_vec)==param.noBoxes);            
            supPi_box_vec = [zeros(1,param.nSupPix), box_vec] ;
            
            Aeq(i,:) = supPi_box_vec;
            
        
    end  
	beq = ones(param.nPics,1);
    
        [x_sol, fval, exitflag, output, lambda] = quadprog(A, saliency_vec', Aineq, bineq, Aeq, beq, zeros(1,N), ones(1,N), [], opts);
    end
    
