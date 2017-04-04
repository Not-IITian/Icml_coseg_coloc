if  ~isfield( param,'imFileList')  
   param=  createImageFileList(param);
end

nPics = numel(param.imFileList);
eval_path = ['eval_coloc_files/'];

if 0
    % create GT boxes
    GT_file_suffix = '.png' ;
    eval_GT_path = cell2mat([param.path.root ,'eval/',typeObj,'/GT/']);
  for Im = 1:nPics
   [~ ,file_name, ~] = fileparts(param.imFileList{Im});
    GT_file = [eval_GT_path, file_name, GT_file_suffix] ;  
    GT_cell{Im} = param.imread(GT_file);
 
    rp = regionprops(GT_cell{Im}, 'BoundingBox', 'Area');
    area = [rp.Area].';
    [idx,~] = find(area>50);
     
    box_file = cell2mat([eval_path, typeObj, '/',file_name, '.mat']) ; 
    bbox_list = cell(1,length(idx));
    for j= 1:length(idx)
        b_boxes = rp(idx(j)).BoundingBox; 
        box(1:4) = b_boxes;
         box(3)= box(1)+box(3) ;
         box(4) = box(2) +box(4);
         bboxes =  round(box(1:4));
        bbox_list{1,j}= bboxes;
    end
    % save GT boxes in eval path
    save(box_file, 'bbox_list');
  end
else
    

overlap_list = zeros(nPics,1);
% success or not (0: fail, 1: success, 2: negative class)
success_list = zeros(nPics, 1, 'uint8');
% to do: save one such matfile for all classes in MSRC and load the mat file    
for Im = 1:nPics
   [~ ,file_name, ~] = fileparts(param.imFileList{Im});
    GT_file = [eval_path, typeObj, '/',file_name, '.mat'] ;  
    load(cell2mat(GT_file))
    gt_boxes = cell2mat(bbox_list);
	ngtboxes = size(gt_boxes, 1);
    if 0 % debug      
         Img = param.imread(param.imFileList{Im});
         box(1:4) = round(gt_boxes(1:4));
         box(3)= box(1)+box(3) ;
         box(4) = box(2) +box(4);
         figure;
         visualize(Img,box);
    end
	% ignore images without GT boxes (or negative images)
	if isempty(gt_boxes)
		overlap_list(iidx, :) = -1;
		success_list(iidx, :) = 2;
		continue;
    end
	% box to rect
	gt_rects = gt_boxes;
	gt_rects(:, 3:4) = gt_rects(:, 3:4) - gt_rects(:, 1:2) + 1;
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

ioverlap_list = overlap_list(overlap_list(:, 1) >= 0);	% ignore negative images
cls_nimage = size(overlap_list, 1);
	
corLoc_val = sum(overlap_list>0.5, 1) ./ cls_nimage 
if param.mu % this is qp
    accuracy_file_name = ['qp_',num2str(param.wt_BoxSaliency),'_', num2str(param.noBoxes), '.mat'];   
else
    accuracy_file_name = ['lp_',num2str(param.wt_BoxSaliency),'_', num2str(param.noBoxes), '.mat'];   
end
accuracy_file = cell2mat([eval_path, typeObj, '/', accuracy_file_name]);
save(accuracy_file, 'corLoc_val', 'box_sol_inds');
end