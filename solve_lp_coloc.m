
qp_for_box = 1 ;
	% set up options
opts = optimset('Diagnostics', 'on', 'Algorithm', 'interior-point-convex');
  
   %A= C_box ;                   
  N =  param.nPics* param.noBoxes ; 
  sal_vec_box = param.saliency_vec_box/sum(param.saliency_vec_box) ;
  sal_vec_box = param.wt_BoxSaliency *sal_vec_box;                      
    % setup equality matrix   
    for i = 1:param.nPics
            box_id = (i-1)*param.noBoxes  ;
            box_vec = zeros(1,param.nPics*param.noBoxes);
            box_vec(box_id+1:box_id+param.noBoxes) = 1 ;
            assert(sum(box_vec)==param.noBoxes);                                  
            Aeq(i,:) = box_vec;       
    end   
	beq = ones(param.nPics,1); 
    
[y_sol, fval, exitflag, output, lambda] = linprog(sal_vec_box', [], [], Aeq, beq, zeros(1,N), ones(1,N), [], opts);   
    
    
