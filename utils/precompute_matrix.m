function [lapMatrix_box, rrMatrix] = precompute_matrix(param, feat)
%% PRECOMPUTE MATRICES USED IN QP

	
% 	load( 'feat.mat');

	% initialize variables
	X = [];
	box_obj = [];
	var_index = []; % image box_index

	% loop through images
	for j = 1:numel(feat)

		% feat
		X = vertcat(X, feat(j).hist(1:param.noBoxes,:));

% 		% box scores
% 		box_obj = vertcat(box_obj, feat(j).boxes(1:param.noBoxes,end));
% 
% 		% var index
% 		var_index = vertcat(var_index, [j*ones(1,param.noBoxes); 1:param.noBoxes]');

	end

	N = size(X,1);

	% compute index matrix
% 	savename = ['./qp_index'];
% 	save(savename, 'var_index', '-v7.3');


	% compute linear term (box prior)
% 	linVector = -log(box_obj + eps);
% 	linVector = linVector / sum(linVector);
% 	savename = ['./qp_linVector'];
% 	save(savename, 'linVector', '-v7.3');


	% compute Laplacian matrix (box similarity)
	disp('Computing Laplacian matrix...')
	Xchi = vl_alldist2(X', 'CHI2');
	Xchi = exp(-param.gamma * Xchi);
	Dinvroot = sparse(diag(sqrt(1 ./ (sum(Xchi)+eps))));
	lapMatrix_box = sparse(1:N, 1:N, 1) - Dinvroot * Xchi * Dinvroot;
    
	lapMatrix_box = lapMatrix_box / trace(lapMatrix_box);
    
% 	savename =  ['./qp_lapMatrix'];
% 	save(savename, 'lapMatrix', '-v7.3');


	% compute ridge regression matrix (box discriminability)
	disp('Computing ridge regression matrix...')
	X = X(:,end-999:end);
	P = sparse(1:N, 1:N, 1) - 1 / N;
	PX = P * X;
	rrMatrix = P' * (sparse(1:N, 1:N, 1) - PX * (PX'*PX + N * param.kappa * sparse(1:size(X,2), 1:size(X,2), 1))^-1 * PX') * P;
	rrMatrix = rrMatrix / trace(rrMatrix);
    
% 	savename = ['./qp_rrMatrix'];
% 	save(savename, 'rrMatrix', '-v7.3');
