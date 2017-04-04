function labels_im = compute_labels_4_Im(param, descr, labels_box, supPixIndices)

%tthis function takes a 1d concat vector of box labels and converts it into
%image level according to the labelling of highest scoring box..
no_files = numel(param.imFileList) ;
no_Sup_per_box = param.local_supPix ; % vector of all box sup number
cum_vec = [0;cumsum(no_Sup_per_box)] ;
% labels_box = label_box(:,1) ;
labels_im = []; 
for iIm = 1:no_files   
    [pathIm, fileName, ~] = fileparts(param.imFileList{iIm});       
    imFileName = [pathIm, '/superpixel/',fileName,'.mat'];       
    load(imFileName, 'supPixIm');
    supPixInd_im =  supPixIndices{iIm} ; % sorted unique vector of sup Idx 
        
     
      j = param.box_sol_inds(iIm);
      id_x = (iIm-1)*param.noBoxes + j ;
      BoxsupPixIndices = supPixIm(descr.y{id_x} + size(supPixIm,1)* (descr.x{id_x}-1)) ;               
      box_sup_id = unique(BoxsupPixIndices); 
      assert(numel(box_sup_id)== no_Sup_per_box(id_x));
      % find at which idx box_idx and im_idx match
      idx_vec = [];
      for k = 1:numel(box_sup_id)
        sup_idx=  find(supPixInd_im==box_sup_id(k)) ;
        idx_vec = [idx_vec;sup_idx];
      end
      labels_vec = zeros(numel(supPixInd_im),1);
       assert(numel(idx_vec)== (cum_vec(id_x+1)-cum_vec(id_x)));
      labels_vec(idx_vec) = labels_box(cum_vec(id_x)+1:cum_vec(id_x+1));
      labels_im = [labels_im;labels_vec ] ;   
      labels_vec = [];
end

% duplicate the labels for the second class which is complimentary
% dummy_class = (labels_im==0);
% labels_Im = [labels_im,dummy_class ];