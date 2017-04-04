% SETUP PARAMETERS
feat_dim = 10000; % dimensionality of features
param = struct;
param.kappa = 1e-2 / feat_dim; % weight for ridge regression regularization
param.gamma = 1 / sqrt(feat_dim); % weight for distance -> similarity matrix
param.lambda = 0.1; % weight between linear/quadratic term
param.mu = 0.4; % weight between laplacian/ridge regression term
param.num_boxes = 10; % number of boxes to extract with objectness

% SETUP DIRECTORIES
base_dir = '/afs/cs/u/kdtang/code/release/colocalize-v1'; % CHANGE THIS TO CORRECT BASE DIRECTORY
image_dir = [base_dir '/images/']; % directory of images to co-localize
tmp_dir = [base_dir '/tmp/']; % temporary directory for saving files
vlfeat_dir = [base_dir '/ext/vlfeat-0.9.17/']; % vlfeat directory
objectness_dir = [base_dir '/ext/objectness-release-v2.2/']; % objectness directory
dsift_dict_file = [base_dir '/data/dsift_dict.mat']; % precomputed dictionary for dsift descriptors
