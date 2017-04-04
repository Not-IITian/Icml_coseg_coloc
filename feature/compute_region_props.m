 function param = compute_region_props(param,params)
    nPics = numel(param.imFileList);
for i = 1:nPics
   Im = param.imread(param.imFileList{i});
    param.boxes(i).coords = objectness_wrapper(Im, param.noBoxes, params);
end
 end
function boxes = objectness_wrapper(im, num_boxes, params)
	boxes = runObjectness(im, num_boxes, params);

end