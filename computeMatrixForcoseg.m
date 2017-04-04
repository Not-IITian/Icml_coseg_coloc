function [C,im_supPix_var_cell,box_supPix_non_zeros, Sal_vec, total_supPix_var] = computeMatrixForcoseg(param, xDif, lapMatrix, projMatrix,lin_saliency_vec)

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
   
if param.wt_disc 
   C = (projMatrix'*projMatrix - sum(projMatrix)'*sum(projMatrix)/param.nDescr - (xDif * projMatrix)' * xDif * projMatrix);
    C = param.wt_disc*C;% what are the 
       
    C_box_all = cell(param.noBoxes,1);
    C_all_Im = cell(param.nPics,1);    
    
    for i = 1:param.nPics                   
        for j = 1:param.noBoxes           
            C_box_all{j} = [];          
            for i_2 = 1:param.nPics                     
                for j_2 = 1:param.noBoxes                 
                    C_im = C(supPix_idx(i)+1:supPix_idx(i+1),supPix_idx(i_2)+1:supPix_idx(i_2+1)); 
                    C_im(rows_tobe_removed_idx{i}{j},:) = [];  % remains constant for im1_box, only second im box changes
                    
                    % uncomment the if part to make disc psd
%                     if i ==i_2
%                         if j==j_2                           
%                             C_im(:,rows_tobe_removed_idx{i}{j}) = [];
%                             C_box_all{j} =[ C_box_all{j},C_im] ;
%                         else
%                             % if for same img, one box var against second
%                             % box
%                             C_box_all{j} =[ C_box_all{j},zeros(im_supPix_var_cell{i}(j),im_supPix_var_cell{i}(j_2))] ; % dims to be filled 
%                         end                                               
%                     else                      
                       C_im(:,rows_tobe_removed_idx{i_2}{j_2}) = [];  % remove all those columns whose supPix are nt inside the box
                        C_box_all{j} = [ C_box_all{j},C_im] ; % check this again
            
%                     end                  
                end 
            end
            
        end
        C_all_Im{i} =cell2mat(C_box_all); % make it sparse too
    end    
    Disc_mat = cell2mat(C_all_Im);
end
   

if param.lapWght   
%     lapMatrix = param.lapWght*lapMatrix;
    L_Im_all = cell(param.nPics,1);    
    if param.lap_diag       
        for i = 1:param.nPics
            L_all_box = cell(param.noBoxes,1);
                
            for j = 1:param.noBoxes
                L_im = lapMatrix(supPix_idx(i)+1:supPix_idx(i+1),supPix_idx(i)+1:supPix_idx(i+1)); % make it more efficient
                L_im(rows_tobe_removed_idx{i}{j},:) = [];
                L_im(:,rows_tobe_removed_idx{i}{j}) = [];  % remove all those columns whose supPix are nt inside the box
                L_all_box{j} =  L_im ;
            
                if j==1
                    L_Im_all{i} =  L_all_box{j} ;
                else
                    L_Im_all{i} = blkdiag(L_Im_all{i},L_all_box{j}) ; % it may not work,create a dummy var then
                end
            end  
            if i==1
              Lap_mat = L_Im_all{i};
            else
              Lap_mat = blkdiag(Lap_mat,L_Im_all{i});
            end
        end          
    else           
        for i = 1:param.nPics
            L_all_box = cell(param.noBoxes,1);                
            for j = 1:param.noBoxes
                L_all_box{j} = [];
                for j_2= 1:param.noBoxes                  
                    L_im = lapMatrix(supPix_idx(i)+1:supPix_idx(i+1),supPix_idx(i)+1:supPix_idx(i+1)); % make it more efficient
                    L_im(rows_tobe_removed_idx{i}{j},:) = [];
                    L_im(:,rows_tobe_removed_idx{i}{j_2}) = [];  % remove all those columns whose supPix are nt inside the box
                    L_all_box{j} = [L_all_box{j}, L_im] ;  % horizontal concat           
                end             
            end           
            L_Im_all{i} = cell2mat(L_all_box) ;  % it shud concat vertically           
            if i==1
              Lap_mat = L_Im_all{i};
            else
              Lap_mat = blkdiag(Lap_mat,L_Im_all{i});
            end       
        end
    end
end

if param.wt_saliency
    Sal_Im_all = cell(param.nPics,1);
    
    for i = 1:param.nPics
        Sal_all_box = cell(param.noBoxes,1);
              
        for j = 1:param.noBoxes
            Sal_im = lin_saliency_vec(supPix_idx(i)+1:supPix_idx(i+1))'; 
            Sal_im(rows_tobe_removed_idx{i}{j}) = [];
            
            Sal_all_box{j} = Sal_im ;
            
            if j==1
                Sal_Im_all{i} =  Sal_all_box{j} ;
            else
                Sal_Im_all{i} = [Sal_Im_all{i};Sal_all_box{j}] ; % it may not work,create a dummy var then
            end
        end  
          if i==1
              Sal_vec = Sal_Im_all{i};
          else
              Sal_vec = [Sal_vec;Sal_Im_all{i}];
          end
    end  
end

if param.wt_disc   
    C = Disc_mat ; % what are the
  if param.lapWght 
        C   = C + Lap_mat;
  end    
else
    if param.lapWght 
        C   =  Lap_mat;
    end
end