% function [projMatrix, supPixIndices, param] = openSuperpixel(descr, param)
% 
function [supPixIndices, param] = openSuperpixel_box(descr, param)

subSupPixIm             = cell(numel(param.imFileList),1);
param.supPixFileList    =  cell(numel(param.imFileList),1);
supPixIndices  = cell(numel(param.imFileList),1);

param.supPix_im_cell_for_ind_matrix = cell(numel(param.imFileList),1);
supPix_count = zeros(param.nPics,1);

for iIm = 1:numel(param.imFileList)
    
    [pathIm, fileName, ~] = fileparts(param.imFileList{iIm});
    imFileName = [pathIm, '/superpixel/',fileName,'.mat'];   
    load(imFileName, 'supPixIm');
    
    param.supPixFileList{iIm} = imFileName;
        
    supPixIndices{iIm} = supPixIm( descr.y{iIm} + size(supPixIm,1)*(descr.x{iIm}-1) ) ; % extract the index sampled points from the original image
       
    if param.useBox         
        unique_supPix_sampled = unique(supPixIndices{iIm});
       supPix_count(iIm) = numel(unique_supPix_sampled);
       pixels_count = zeros(1,supPix_count(iIm));
       
            for ss = 1:supPix_count(iIm)
                pixels_count(ss) = sum(supPixIndices{iIm}==unique_supPix_sampled(ss));
                param.SupPix_pixels_count{iIm} = pixels_count(ss);
            end
            
       param.box_supPix{iIm} = zeros(param.noBoxes,supPix_count(iIm));
    
       Im = param.imread(param.imFileList{iIm});
        suppix_box_cell = cell(size(param.boxes(iIm).coords,1) ,1);           
        supPix_indicator_cell = cell(numel(unique(supPixIndices{iIm})),1) ;  % this cell is tot_suP_im1 by 1..each entry is an array which tells the idx of all box that contains particular supPix
        
        for j= 1:size(param.boxes(iIm).coords,1)
            
			box = param.boxes(iIm).coords(j,:);
			box(1:4) = round(box(1:4));       
            i= 1;        
            % this can rewritten by taking the box out of image 
            for x = box(1):box(3)
                for y= box(2):box(4)
                    
%                     assert((max(descr.x{iIm}) +8 -x )>=0 );
%                     assert((max(descr.y{iIm}) +8 -y )>=0 );
%                     
                    if numel(find(descr.x{iIm}==x))>0 && numel(find(descr.y{iIm}==y))>0
                            suppix_box_cell{j}(i) = supPixIm(y+ size(supPixIm,1)*(x-1));  % for sampled pixels inside each box, find their supPix labels and make a vector
                            
                            i = i+1;                      
                    end
                end
            end          
%             count_pixels = i ;                      
            Sup_unique = unique(suppix_box_cell{j}(:));
                    
            for k = 1:numel(Sup_unique)
               sup_idx =  find(unique(supPixIndices{iIm})== Sup_unique(k));   % vector telling at which position the supPix id shud be ...according to the optimsation var
               param.box_supPix{iIm}(j,sup_idx)= numel(find(suppix_box_cell{j}(:)==Sup_unique(k)));  % vector telling how many pixels inside the supPix of box j
               
               % this is for indicator matrix
               supPix_indicator_cell{sup_idx} = [supPix_indicator_cell{sup_idx}, j] ; % checked this is correct ..                           
            end                   
        end                 
    end     
    param.supPix_im_cell_for_ind_matrix{iIm,1} = supPix_indicator_cell ;          
end

%%%%%%%%%%%%%%%%%%%%
param.lW_supPix     = cellfun(@(x) numel(unique(x)), subSupPixIm);

for m = 1:param.nPics
    assert(supPix_count(m)==param.lW_supPix(m));
end

param.nSupPix       = sum(param.lW_supPix);
supPixIndices       = cellfun(@(x) unique(x), supPixIndices,'uniformOutput', 0);
printMessage('computing box proj matrix done');

end

