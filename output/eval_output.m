% asumming param exits in current workspace...so that function definition
% such as param.imread exists...so do the max size of image...this script
% first reads all the ground truth images by using param.imread which
% simultaneously scales the image accordingly...u can find the foreground
% by selecting a specific color and create a cell with all the images
if param.pascal_10
    eval_path = cell2mat([param.path.root ,'eval_pascal_10/',typeObj, '/']);
else
    eval_path = cell2mat([param.path.root ,'eval/',typeObj,'/GT/']);
end
fg_class_label = 2; % 2 for red ,3 for green ,look and decde
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
if param.MSRC== 1
    for i = 1:param.nPics
        output_labels{i}= (Class_labels_all_Im{i}==fg_class_label);% for cat and dog, G value = 192, for cow, B value = 128; for face, G = 128        
        if typeObj{1}(end)== 't' || typeObj{1}(end)== 'g'   % cat and dog           
            Correct_pixels{i} = GT_cell{i}(:,:,2) == 192 ;
            
        elseif typeObj{1}(1)== 'c' && typeObj{1}(end)== 'r' && length(typeObj{1})== 5  % chair
             Correct_pixels{i} = GT_cell{i}(:,:,2) == 192 ;
             
         elseif typeObj{1}(1)== 'c' && typeObj{1}(end)== 'r' && length(typeObj{1})== 3  % car          
             Correct_pixels{i} = GT_cell{i}(:,:,1) == 64 ;            
             
        elseif typeObj{1}(end)== 'w' || typeObj{1}(end)== 'p' % cow and sheep           
            Correct_pixels{i} = GT_cell{i}(:,:,3) == 128 ;
            
        elseif  typeObj{1}(end)== 'e' && typeObj{1}(1)== 'f'  % face            
               Correct_pixels{i} = GT_cell{i}(:,:,2) == 128 ;
        else                                                 % aero and bike
            Correct_pixels{i} = GT_cell{i}(:,:,1) == 192 ;
            
        end
        % for bike, R =192, for aero R = 192; B = 128  fOR SHEEP, 
        im_size = size(GT_cell{i});                % for chair, G  = 192; car_front, R =64
        size_vec(i) = im_size(1)*im_size(2);
    end
    
elseif param.pascal_10
    for i = 1:param.nPics
        output_labels{i}= (Class_labels_all_Im{i}==fg_class_label);
        
        Correct_pixels{i} = (GT_cell{i}(:,:,1) == 255)  ; % check if it is 255 for all classes
        
        im_size = size(GT_cell{i});               
        size_vec(i) = im_size(1)*im_size(2);
    end    
else
    for i = 1:param.nPics
        output_labels{i}= (Class_labels_all_Im{i}==fg_class_label);
        if strcmp(typeObj{1}, 'Horse_93')
            Correct_pixels{i} = (GT_cell{i} == 255)  ; % for horse, it is 255 else it is 1
        else
            Correct_pixels{i} = (GT_cell{i} == 1)  ;
        end
        im_size = size(GT_cell{i});               
        size_vec(i) = im_size(1)*im_size(2);
    end
end

P = 0;
J = 0;
nPositive = 0;

for i = 1:param.nPics
    P =  P +sum(sum(output_labels{i}==Correct_pixels{i}))./size_vec(i) ;
%     P = P;
    
    % Compute Jaccard only for images that contain an object
    
        J = J + sum( (output_labels{i}(:)==1) & (Correct_pixels{i}(:)==1) ) ./ sum( (output_labels{i}(:) | Correct_pixels{i}(:))==1 );
        nPositive = nPositive+1;
   
end
J = J / nPositive 
P = P/nPositive 

