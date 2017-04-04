function [pixel_perBox_cell, Sup_occurence_cell,All_sup] = compute_Sup_occurence(descr,descr_im, param)

no_files = numel(param.imFileList) ;
BoxsupPixIndices  = cell(no_files*param.noBoxes,1);
Sup_occurence_cell = cell(no_files,1);

% structure for maintainig the occurence of supPix in various boxes
for iIm = 1:no_files
    [pathIm, fileName, ~] = fileparts(param.imFileList{iIm});       
    imFileName = [pathIm, '/superpixel/',fileName,'.mat'];       
    load(imFileName, 'supPixIm');
    supPixIndices{iIm} = supPixIm( descr_im.y{iIm} + size(supPixIm,1)*(descr_im.x{iIm}-1)) ; 
    All_sup{iIm} = unique(supPixIndices{iIm});     
    all_sup = All_sup{iIm};
    % these two are global variable for each image
     occurence.sup_sorted_idx = cell(all_sup(end),1); occurence.box_idx = cell(all_sup(end),1);    
    for j = 1:size(param.boxes(iIm).coords,1)
        id_x = (iIm-1)*param.noBoxes + j ;
        BoxsupPixIndices{id_x} = supPixIm(descr.y{id_x} + size(supPixIm,1)* (descr.x{id_x}-1)) ;    %  we have descr.x for each box separately.        
        % this portion for computing occurence of suppix in boxes..uncomment if buggy
        %if 0
            box_sup_id = unique(BoxsupPixIndices{id_x});         
        for k = 1:numel(all_sup)
             idx =find(box_sup_id==all_sup(k));
               if numel(idx)~= 0                 
                    occurence.sup_sorted_idx{all_sup(k)} =  [occurence.sup_sorted_idx{all_sup(k)},idx] ;   % stores the idx at which this supPix var occurs in box
                    occurence.box_idx{all_sup(k)} = [occurence.box_idx{all_sup(k)}, j]       ; % stores the corresponding idx  
               end
        end          
       % code to compute how many pixels for each supPix 
         for kk = 1:numel(box_sup_id)
             pixles_per_Sup_vec(kk) = numel(find(BoxsupPixIndices{id_x}==box_sup_id(kk)));                         
         end
          pixel_perBox_cell{iIm}{j} = pixles_per_Sup_vec ;
          pixles_per_Sup_vec = [] ;
    end    
    Sup_occurence_cell{iIm} = occurence ;
    occurence = [];
    
    
    
end 



