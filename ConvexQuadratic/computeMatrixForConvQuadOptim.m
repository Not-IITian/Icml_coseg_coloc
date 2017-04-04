% function C = computeMatrixForConvQuadOptim(param, xDif, lapMatrix, projMatrix)
function [im_supPix_var_cell,box_supPix_non_zeros,  Proj_box_supPix_mat, total_supPix_var] = computeMatrixForConvQuadOptim(param)

    supPix_idx = [0, cumsum( param.lW_supPix')];
    rows_tobe_removed_idx = cell(param.nPics,1);  % this is to store a matrix for each image, which tells for each box, which supPix are zero
    box_supPix_non_zeros = cell(param.nPics,1);
    im_supPix_var_cell = cell(param.nPics,1);
 
     total_supPix_var = 0;
    
   for i = 1:param.nPics      
       for j = 1:param.noBoxes                    
            non_zeros_idx = find(param.box_supPix{i}(j,:));  % cell of no of images, each is no of box by im_supPix            
            im_supPix_var_cell{i}(j,:) = numel(non_zeros_idx); % this is to keep a count of supPix var in all box...checked correct          
            box_supPix_non_zeros{i}{j} = param.box_supPix{i}(j, non_zeros_idx); % this stores only non zeros supPix pixels, to be used for constraints...checked many times..correct   
            
            all_idx = [1:param.lW_supPix(i) ];
            zeros_idx = setdiff(all_idx,non_zeros_idx) ;
            rows_tobe_removed_idx{i}{j} = zeros_idx ;
       end
        total_supPix_var = total_supPix_var + sum(im_supPix_var_cell{i}) ;
   end   
    
   % code for creating a position matrix which tells the position
             % of each supPix in each of the box...this is a cell             
            supPix_position_ineach_box_cell = cell(param.nPics,1);    %tells the position of each supPix in each of the box  
             for i = 1:param.nPics
                tot_sup_img = param.lW_supPix(i) ;                 
                for j = 1:tot_sup_img
                    position_vec= [] ;                   
                  for b = 1:param.noBoxes                     
                      non_zeros_sup_vec = find(param.box_supPix{i}(b,:)) ;                     
                      if ismember(j,non_zeros_sup_vec)
                          sup_postion = find(j ==non_zeros_sup_vec) ;
                          position_vec = [position_vec,sup_postion] ;
                      end                                 
                  end          
                  supPix_position_ineach_box_cell{i}{j} =   position_vec ;                 
                end               
             end                        
             % end of code  
   dim1 = total_supPix_var + param.noBoxes*param.nPics ;
   dim2 =  supPix_idx(end) + param.noBoxes*param.nPics ;
   
   Proj_box_supPix_mat = zeros(dim1, dim2) ;   
   cum_no_supbox_vec = [0];
   supPix_im_cell_for_ind_matrix = param.supPix_im_cell_for_ind_matrix ;  
  
   for i = 1:param.nPics
          boxes_per_SupPix = supPix_im_cell_for_ind_matrix{i,1} ;  % this will give me a cell of dims pixels_this_im bhy 1
          tot_supPix = numel(boxes_per_SupPix) ;          
           cum_count_vec = [0] ;        
          cum_count_vec = [cum_count_vec,cumsum(im_supPix_var_cell{i})']; % vec of no of supPix for each image         
          sup_pix_before_this_img = cum_no_supbox_vec(end) ;        
           cum_no_supbox_vec = [cum_no_supbox_vec ,cum_count_vec(end)+ sup_pix_before_this_img ]; % this is a global term..concat at image level
           
          for Sup_pix = 1 :tot_supPix
              
              boxes_idx = boxes_per_SupPix{Sup_pix,1} ;
              dummy_vec = zeros(dim1,1);
              sup_Pix_lin_idx = [] ;                       % for debugging
             
              if numel(boxes_idx) > 0                 
                    sup_pos_idx_vec = supPix_position_ineach_box_cell{i}{Sup_pix}  ; % this is a vec for all boxes...in the increasing order of box idx
                    assert(numel(boxes_idx)== numel(sup_pos_idx_vec)) ;
                    
                  for bb = 1:numel(boxes_idx)
                      box_idx = boxes_idx(bb) ;
                      
                        sup_idx = sup_pos_idx_vec(bb) ; % this gives the idx at which this supPix appears in box_idx
                        sup_lin_idx = cum_no_supbox_vec(i) + cum_count_vec(box_idx) + sup_idx;
                    
                     if sup_lin_idx > dim1
                             display(i) ;                           
                     end                       
                        sup_Pix_lin_idx = [sup_Pix_lin_idx, sup_lin_idx];   
                  end
                  dummy_vec(sup_Pix_lin_idx) = 1;                        
              end              
              col_idx = supPix_idx(i) + Sup_pix ;
              Proj_box_supPix_mat(:,col_idx) = dummy_vec ;
          end
   end      
   % this is for filling in the rest of matrix for box var  
   for i = 1:param.nPics
       for j = 1:param.noBoxes         
           dummy_vec = zeros(1,dim2);
           box_idx = supPix_idx(end) + (i-1)*param.noBoxes + j ;     
           row_idx = total_supPix_var + (i-1)*param.noBoxes + j ;
           dummy_vec(box_idx) = 1 ;
           Proj_box_supPix_mat(row_idx,:) = dummy_vec ;                   
       end
   end   
    % set up laplacian and discriminative matrix for each box and stack
    % them up for the joint vector       
    
