% this script evaluates the intersection over union scores of ground truth pixels inside
% the bounding box and ground truth pixels and if the score >.5 then it
% counts as one.
if param.pascal_10
    eval_path = cell2mat([param.path.root ,'eval_pascal_10/',typeObj, '/']);
else
    eval_path = cell2mat([param.path.root ,'eval/',typeObj,'/GT/']);
end

fg_class_label = 2; % 2 for red ,3 for green ,look and decide
load(param.label_mat_str);  % this will load output labels;
% typeObj =mat2cell(typeObj);
accurate_pixels = zeros(param.nPics,1);
 size_vec = zeros(param.nPics,1); 
 
 if param.MSRC
     GT_file_suffix = '_GT.bmp' ;
 else
     GT_file_suffix = '.png' ;
 end
nPics = numel(param.imFileList);
GT_cell = cell(numel(nPics),1);
% to do: save one such matfile for all classes in MSRC and load the mat file    
for Im = 1:nPics
   [~ ,file_name, ~] = fileparts(param.imFileList{Im});
    GT_file = [eval_path, file_name, GT_file_suffix] ;  
    GT_cell{Im} = param.imread(GT_file);
end
% for cow, red means class 2, which is foreground..put all the rest in
% background
 output_labels = cell(param.nPics,1); Correct_pixels = cell(param.nPics,1);

  for i = 1:param.nPics            
        output_labels{i}= (Class_labels_all_Im{i}==fg_class_label); % only need to change this line (of all foreground, choose ones inside bbox)
        bbox = param.boxes(i).coords(box_sol_inds(i),:);
        box = round(bbox(1:4));
        x_idx = (box(1):box(3));
        y_idx = (box(2):box(4));
               
        labels = zeros(size(output_labels{i}));
        
        for x = box(2):box(4)   % x
            for y= box(1):box(3) 
                labels(x,y) = output_labels{i}(x,y);
                
            end
        end
        
        box_labels{i} = labels ;
        
        if param.nPics == 93
            Correct_pixels{i} = (GT_cell{i} == 255)  ; % for horse, it is 255 else it is 1
        else
            Correct_pixels{i} = (GT_cell{i} == 1)  ;
        end
        
        im_size = size(GT_cell{i});               
        size_vec(i) = im_size(1)*im_size(2);   
end
P = 0;
J = 0;
nPositive = 0;

for i = 1:param.nPics
%     P =  P +sum(sum(output_labels{i}==Correct_pixels{i}))./size_vec(i) ;
      % Compute Jaccard only for images that contain an objec
%       J = J + sum( (output_labels{i}(:)==1) & (Correct_pixels{i}(:)==1) ) ./ sum( (output_labels{i}(:) | Correct_pixels{i}(:))==1 );
      I_o_u= sum( (box_labels{i}(:)==1) & (Correct_pixels{i}(:)==1) ) ./ sum( (box_labels{i}(:) | Correct_pixels{i}(:))==1 );
      success = I_o_u>=.5;
      J = J + success ; 
end
J = J/param.nPics;
P = P/param.nPics; 

