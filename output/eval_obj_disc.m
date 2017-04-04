
% eval_output ;
nPics = numel(param.imFileList);
GT_path = ['eval_coloc_files/'];
 GT_SEG_path = cell2mat([param.path.root ,'eval/',typeObj,'/GT/']);
if param.scaled_sal_box
    accuracy_file_name = ['acc_',num2str(param.wt_BoxSaliency),'_', num2str(param.wt_saliency), '_', num2str(param.max_pixels), '_', num2str(param.optim.lambda0),'_', num2str(param.lapWght),'_', num2str(param.noBoxes),'_new', '.mat'];   
else
    accuracy_file_name = ['acc_',num2str(param.wt_BoxSaliency),'_no_scaling_', num2str(param.wt_saliency), '_', num2str(param.max_pixels), '_', num2str(param.optim.lambda0),'_', num2str(param.lapWght),'_', num2str(param.noBoxes),'_new', '.mat'];
end
accuracy_file = cell2mat(['./acc_val/', typeObj '_', accuracy_file_name]);

overlap_list = zeros(nPics,1);
% success or not (0: fail, 1: success, 2: negative class)
success_list = zeros(nPics, 1, 'uint8');
% to do: save one such matfile for all classes in MSRC and load the mat file    
for Im = 1:nPics
   [~ ,file_name, ~] = fileparts(param.imFileList{Im});
    GT_file = [GT_path, typeObj, '/',file_name, '.mat'] ;  
    load(cell2mat(GT_file))
    gt_boxes = cell2mat(bbox_list);
	ngtboxes = size(gt_boxes, 1);
    
	% ignore images without GT boxes (or negative images)
	if isempty(gt_boxes)
		overlap_list(iidx, :) = -1;
		success_list(iidx, :) = 2;
		continue;
    end
	% box to rect
	gt_rects = gt_boxes;
% 	gt_rects(:, 3:4) = gt_rects(:, 3:4) - gt_rects(:, 1:2) + 1;
	ngtrect = size(gt_rects, 1);	
		% load localization results ('saliency', 'conf_acc')	
        best_rect = param.boxes(Im).coords(box_sol_inds(Im),:);
		best_rect(:, 3:4) = best_rect(:, 3:4) - best_rect(:, 1:2) + 1;
		% intersection/union areas
		int_area = rectint(best_rect, gt_rects);
		uni_area = zeros(1, ngtrect);
		for gidx = 1 : ngtrect
			uni_area(gidx) = prod(best_rect(3:4)) + prod(gt_rects(gidx, 3:4));
		end
		uni_area = uni_area - int_area;
		ovl_ratio = int_area ./ uni_area;
		overlap_list(Im) = max(ovl_ratio);
		if max(ovl_ratio) > 0.5
			success_list(Im) = 1;
		end
end
% summary per class
fprintf('Summarize performance\n');
% oratio_all_cls  = cell(nclass_eva, 1);
% 
% % summary for all
% corLoc_cls = zeros(corLo);
% oratio_cls = zeros(nclass_eva);
ioverlap_list = overlap_list(overlap_list(:, 1) >= 0);	% ignore negative images
cls_nimage = size(overlap_list, 1);

Map = mean(overlap_list)

corLoc_val = sum(overlap_list>0.5, 1) ./ cls_nimage 
% %eval segmentation part%%
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
    GT_file = [GT_SEG_path, file_name, GT_file_suffix] ;  
    GT_cell{Im} = param.imread(GT_file);
end

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
P = 0;
J = 0;
nPositive = 0;

for i = 1:param.nPics
    P =  P +sum(sum(output_labels{i}==Correct_pixels{i}))./size_vec(i) ;    
        J = J + sum( (output_labels{i}(:)==1) & (Correct_pixels{i}(:)==1) ) ./ sum( (output_labels{i}(:) | Correct_pixels{i}(:))==1 );
        nPositive = nPositive+1;
   
end
J = J / nPositive 
P = P/nPositive 
save(accuracy_file, 'corLoc_val', 'Map', 'P', 'J');
