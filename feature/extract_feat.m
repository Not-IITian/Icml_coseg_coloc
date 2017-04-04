% function extract_feat(im_list)
function [feat]= extract_feat(param)
%% EXTRACT FEATURES FROM IMAGES IN im_list
% 	globals;
    im_list =  param.imFileList;

	% load dictionary of dsift cluster centers
% 	load(dsift_dict_file); % shud be 128 by 1000
    
	% set up savename
	savename = ['./feat.mat'];

	% initialize structs
	feat = struct;
% 	boxes = struct;
	dsift = struct;

	% loop through images
    fullresp = [];
    
    for i = 1:numel(im_list)

		fprintf('Extracting features for dictionary: %d/%d\n', i, numel(im_list));

		% extract dsift		
        im = param.imread(im_list{i});
        [f,d] = dsift_wrapper(im); % d is 128 by no_features
        fullresp = [fullresp,d];
    end
    
    fullresp = single(fullresp);
    [centers foo] = vl_kmeans(fullresp, param.box_dict_length, 'verbose', 'algorithm', 'elkan'); % ful resp shud be 128 by no_feat, centers shud be 128 by dict_length
    
    boxes = param.boxes;
    
	for i = 1:numel(im_list)

		fprintf('Extracting features: %d/%d\n', i, numel(im_list));

		% run objectness
% 		im_path = im_list{i};
% 		boxes(i).coords = objectness_wrapper(im_path, param.num_boxes, params);
% 		boxes(i).im_path = im_path;

		% extract dsift
		im_path = im_list{i};
        im = param.imread(im_list{i});
% 		[f,d] = dsift_wrapper(im_path);
        [f,d] = dsift_wrapper(im);
		% normalize and quantize
		d = double(d);
		d = d ./ (repmat(sum(d,1), size(d,1), 1) + eps); % L1 NORM
		d = d ./ (repmat(sqrt(sum(d.^2,1)), size(d,1), 1) + eps); % L2 NORM
		[~, quant_d] = min(pdist2(d', centers'), [], 2);

		dsift(i).location = f;
		dsift(i).words = quant_d';
		dsift(i).im_path = im_path;

		% compute SPM features
		hist_temp = zeros(size(boxes(i).coords,1), 10000);
		im_maxsize = max(dsift(i).location, [], 2);
		% loop through boxes
		for j = 1:size(hist_temp,1)

			box = param.boxes(i).coords(j,:);
			box(1:4) = round(box(1:4));

			% generate image mask
			im_mask = zeros(im_maxsize(1), im_maxsize(2), 'uint8');
			im_mask_gridx = floor(linspace(box(1), box(3), 4));
			im_mask_gridy = floor(linspace(box(2), box(4), 4));
			im_mask_gridind = 1;
			for mx = 1:3
				for my = 1:3
					im_mask(im_mask_gridx(mx):im_mask_gridx(mx+1), im_mask_gridy(my):im_mask_gridy(my+1)) = im_mask_gridind;
					im_mask_gridind = im_mask_gridind + 1;
				end
			end
			% compute histogram representation
			box_sifthist = zeros(10, 1000);
			for k = 1:numel(dsift(i).words)
				loc_temp = dsift(i).location(:,k);
				if im_mask(loc_temp(1), loc_temp(2)) > 0
					box_sifthist(im_mask(loc_temp(1), loc_temp(2)), dsift(i).words(k)) = box_sifthist(im_mask(loc_temp(1), loc_temp(2)), dsift(i).words(k)) + 1;
					box_sifthist(10, dsift(i).words(k)) = box_sifthist(10, dsift(i).words(k)) + 1;
				end
			end
			hist_temp(j,:) = box_sifthist(:)';

		end

		% normalize histogram
		hist_temp = hist_temp ./ repmat(sum(hist_temp,2) + eps, 1, size(hist_temp,2));

		% add to feat
		feat(i).hist = sparse(hist_temp);
		feat(i).boxes = boxes(i).coords;
		feat(i).im_path = dsift(i).im_path;

    end
	% save feat
% 	save(savename, 'feat');

end


%% WRAPPER TO RUN DENSE SIFT DESCRIPTOR CODE
% function [f,d] = dsift_wrapper(im_path)
function [f,d] = dsift_wrapper(im)

	% read in image
% 	I = single(vl_imreadgray(im_path));
    I = im2double(im) ;

    if(size(I,3) > 1)
        Im = rgb2gray(I) ;
    end
    
    Im = single(Im);
	% run feat
	binSize = 8;
	magnif = 3;
	Im = vl_imsmooth(Im, sqrt((binSize/magnif)^2 - .25));
	[f,d] = vl_dsift(Im, 'size', binSize, 'step', 4);

end


%% WRAPPER TO RUN OBJECTNESS CODE
% function boxes = objectness_wrapper(im_path, num_boxes, params)
% 
% 	% read in image
% 	imgExample = imread(im_path);
% 
% 	% run objectness
% 	boxes = runObjectness(imgExample, num_boxes, params);
% 
% end
