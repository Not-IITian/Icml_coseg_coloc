function param = generateAllFeatures(param, featEmptyFileList)

if nargin<2
    featEmptyFileList = ones(param.nPics,1);
end

for idFile = 1 : param.nPics
    if featEmptyFileList(idFile)==1                 
       if param.box_form   
            feat = generateFeature(param.imFileList{idFile}, param.im_featFileList{idFile}, param);        
            params = param.params;       
            Im = param.imread(param.imFileList{idFile}); 
            param.boxes(idFile).coords = objectness_wrapper(Im, param.noBoxes, params);   
            unique_x_coord = feat.x(1,:);
            unique_y_coord = feat.y(:,1);
            [~,fileName,~] = fileparts(param.imFileList{idFile}); 
           
        for j = 1:param.noBoxes
            % now generate for each image           
            iFile = (idFile-1)*param.noBoxes + j ;
             param.box_featFileList{iFile}    = sprintf('%s%s%s%s.mat', cell2mat(param.path.feat),fileName, '_' ,num2str(j));   % this is outpath where box_sift desc will be saved    
            outpath = param.box_featFileList{iFile};
            
            box = param.boxes(idFile).coords(j,:);
			box(1:4) = round(box(1:4));                      
            % get the x idx by doing descr_im.x <= box_max (box(3))and box_min (box(1))
            % check the max box(3) correponds to 160
           Idx_1 = find(unique_x_coord <= box(3));
            Idx_2 = find(unique_x_coord >= box(1));
             Idx_x = intersect(unique_x_coord(Idx_1),unique_x_coord(Idx_2)) ; 
             missing_x = intersect(Idx_1,Idx_2) ;% this gives the intersection  
           Id_x_missing = setdiff((1:numel(unique_x_coord)), missing_x) ;
           
           % do the same along y coord
                Idy_1 = find(unique_y_coord <= box(4));
                Idy_2 = find(unique_y_coord >= box(2));
                Idy_y = intersect(unique_y_coord(Idy_1), unique_y_coord(Idy_2)) ;
                missing_y = intersect(Idy_1,Idy_2) ;
               Id_y_missing = setdiff((1:numel(unique_y_coord)), missing_y) ;
           
           [sift_box.x,sift_box.y] = meshgrid(Idx_x, Idy_y);                                
            
           data_mat = feat.data ; % three dim mat
           % now recover fsift_box.data from fsift.data using this information              
           data_mat(:,Id_x_missing,:) = [] ;
           data_mat(Id_y_missing,:,:) = [];
           
           sift_box.data  = data_mat ;
           save(outpath, 'sift_box') ;
        end
%         printMessage('done');   
       else 
           feat = generateFeature(param.imFileList{idFile}, param.featFileList{idFile},  param);        
           sift_box = [] ;
       end
       
    end    
end
% instead of saving sift as descr, save siftbox and then read it as
% before..
end
function boxes = objectness_wrapper(im, num_boxes, params)
	boxes = runObjectness(im, num_boxes, params);
end