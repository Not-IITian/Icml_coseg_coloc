eval_path = '/home/abhishek/VOCdevkit (3)/VOC2012/SegmentationClass/' ;
 
classes={...
    'plane'
    'bus'
    'car'
    'cat'
    'cow'
    'dog'
    'horse'
    'sheep'
   };

GT_color = [1,6,7,8,10,12, 13,17] ;

CC = cell2mat(typeObj) ;

index = find(strcmp(classes, CC));
fg_class_label = 2; % 2 for red ,3 for green ,look and decde
load(param.label_mat_str);  % this will load output labels;
% typeObj =mat2cell(typeObj);

accurate_pixels = zeros(param.nPics,1);
 size_vec = zeros(param.nPics,1);
  GT_cell = cell(numel(param.nPics),1);

%   imresize  = @(I) min(max(imresize(I, param.picMaxSize ./ max(size(I,1) , size(I,2)) ),0),255);
    
for Im = 1:param.nPics
%     for Im = 1:param.nPics-1   % just for goose
   [~ ,file_name, ~] = fileparts(param.imFileList{Im});
   name_len = length(file_name);
   
   GT_file = [eval_path,file_name, '.png' ]  ;
   [aa,map] = imread(GT_file, 'png'); 
   
    re_Im = param.imresize(aa);
    [a,b] = size(re_Im);
    
    GT_cell{Im}  = re_Im ;
end

% for cow, red means class 2, which is foreground..put all the rest in
% background
 
output_labels = cell(param.nPics,1); Correct_pixels = cell(param.nPics,1);

 for i = 1:param.nPics
     
    output_labels{i}= (Class_labels_all_Im{i}==fg_class_label);
    
     Correct_pixels{i} = GT_cell{i}(:,:) == GT_color(index) ;
     im_size = size(GT_cell{i});                % for chair, G  = 192; car_front, R =64
        size_vec(i) = im_size(1)*im_size(2);
        
 end
 
 for i = 1:param.nPics
     accurate_pixels(i)= sum(sum(output_labels{i}.*Correct_pixels{i} ));
             
 end

 for i = 1:param.nPics
        
        output_labels{i}= (Class_labels_all_Im{i}~=fg_class_label);
        Correct_pixels{i} = GT_cell{i}(:,:) ~= GT_color(index) ;
        
 end
        
   for i = 1:param.nPics
     accurate_pixels(i)= accurate_pixels(i) +sum(sum(output_labels{i}.*Correct_pixels{i} ));
             
end
accuracy_per_im = accurate_pixels./size_vec;
CC
accuracy= mean(accuracy_per_im)     
 
           