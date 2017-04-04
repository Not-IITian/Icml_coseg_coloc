
if (~exist('eval_path', 'var'))
    eval_path = cell2mat([param.path.root ,'eval/',typeObj,'/GT/']);
end


% typeObj =mat2cell(typeObj);
accurate_pixels = zeros(param.nPics,1);
 size_vec = zeros(param.nPics,1);
List_file = getAllFiles(eval_path); GT_cell = cell(numel(List_file),1);
    
for Im = 1:numel(List_file)
    GT_cell{Im} = param.imread(List_file{Im});
end

% for cow, red means class 2, which is foreground..put all the rest in
% background
 
output_labels = cell(param.nPics,1); Correct_pixels = cell(param.nPics,1);

if param.MSRC== 1
    
    for i = 1:param.nPics
          
          Output_Im = param.output_labels{i}; % this image also contains some pixels outside bbox, of supPix which are 1
          box = param.box_coords{i} ;  % coords of supPix
          output_labels{i} = zeros(size(Output_Im));
          
          output_labels{i}(box(2):box(4),box(1):box(3)) = Output_Im(box(2):box(4),box(1):box(3));  % only pixels inside box is 1
          
%           figure; imshow(output_labels{i});
          
%           figure; Im =param.imread(param.imFileList{i});
%           visualize(Im,box);
%                 
        % for cat and dog, G value = 192, for cow, B value = 128; for face, G = 128
        
        if strcmp(typeObj{1},'cat') || strcmp(typeObj{1},'dog')   % cat and dog
            
            Correct_pixels{i} = GT_cell{i}(:,:,2) == 192 ;
            
        elseif strcmp(typeObj{1},'chair')  % chair
            
             Correct_pixels{i} = GT_cell{i}(:,:,2) == 192 ;
             
         elseif strcmp(typeObj{1},'car')  % car
            
             Correct_pixels{i} = GT_cell{i}(:,:,1) == 64 ;
                         
        elseif strcmp(typeObj{1},'cow') || strcmp(typeObj{1},'sheep') % cow and sheep
            
            Correct_pixels{i} = GT_cell{i}(:,:,3) == 128 ;
            
        elseif  strcmp(typeObj{1},'face')  % face
            
            Correct_pixels{i} = GT_cell{i}(:,:,2) == 128 ;
        else                                                 % aero and bike
            Correct_pixels{i} = GT_cell{i}(:,:,1) == 192 ;
            
        end
        % for bike, R =192, for aero R = 192; B = 128  fOR SHEEP, 
        im_size = size(GT_cell{i});                % for chair, G  = 192; car_front, R =64
        size_vec(i) = im_size(1)*im_size(2);
%         figure; imshow(Correct_pixels{i});
        
    end
else
    
    for i = 1:param.nPics
        
          Output_Im = param.output_labels{i}; % this image also contains some pixels outside bbox, of supPix which are 1
          box = param.box_coords{i} ;  % coords of supPix
          output_labels{i} = zeros(size(Output_Im));
          
          output_labels{i}(box(2):box(4),box(1):box(3)) = Output_Im(box(2):box(4),box(1):box(3));  % only pixels inside box is 1
        
        
        if param.nPics == 93
            Correct_pixels{i} = (GT_cell{i} == 255)  ; % for horse, it is 255 else it is 1
        else
            Correct_pixels{i} = (GT_cell{i} == 1)  ;
        end
        im_size = size(GT_cell{i});               
        size_vec(i) = im_size(1)*im_size(2);
    end
end


for i = 1:param.nPics
    dummy = (output_labels{i}==Correct_pixels{i} );
     accurate_pixels(i) = sum(sum(dummy));
end

accuracy_per_im = accurate_pixels./size_vec;
accuracy = mean(accuracy_per_im)

Box_coords = param.box_coords;
    save(param.label_mat_str,'output_labels','accuracy','Box_coords'); 
    clear typeObj;
