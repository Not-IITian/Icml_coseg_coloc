close all; clear;
warning('off', 'all');

globals;


% CLEAR TEMPORARY DIRECTORY
system(['rm ' tmp_dir '*']); 


% GENERATE LIST OF IMAGES
disp('Generate list of images...');
im_list = {};
D = dir([image_dir '*.jpg']);
for i = 1:numel(D)
	im_list{i} = [image_dir D(i).name];
end


% EXTRACT FEATURES
disp('Extract features from images...');
extract_feat(im_list);


% PRECOMPUTE MATRICES
disp('Precompute matrices for QP...');
precompute_matrix;


% SOLVE QP
disp('Solve QP with MATLAB solver...');
solve_qp;


% VISUALIZE RESULTS
disp('Visualize co-localization results...');
load([tmp_dir 'qp_sol']);
for i = 1:numel(im_list)
	visualize(im_list{i}, box_sol(i,:));
	disp('Press any key to continue...');
	pause;
end
