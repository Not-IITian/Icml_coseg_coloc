% clear all;
    HOMECODE = param.path.root;

HOME = fullfile(HOMECODE,'input');

% if (~exist('typeObj','var') ) 
%     typeObj{1} = 'Car_89';
% end

% K=200; % it was 200 before...this is related to superpixel generation


% if(~exist('K','var'));
%     K=200;  % it was 200 before
% end

HOMEIMAGES = fullfile(HOME,'/images/',typeObj{1});
HOMEDATA = fullfile(HOME,'descr',typeObj{1}); % this is for saving descriptors...
SP_path = fullfile(HOMECODE,'input','images',typeObj{1});


if(~exist('segSuffix','var')); segSuffix = []; end
if(~exist('useGlobal','var')); useGlobal = 1; end
 if (~exist('param','var') ) 
     param.picMaxSize = 160;
    param.imresize  = @(I) min(max(imresize(I, param.picMaxSize ./ max(size(I,1) , size(I,2)) ),0),255);
    param.imread    = @(imPath) param.imresize(imread(imPath));
    param.gridSpacing =1;
    param.compSupPix    = @(imPath) vl_quickseg(param.imresize(single(imread(imPath))./255), .7, 2, 15);
    param.imFileList = getAllFiles(HOMEIMAGES) ;
    param.nPics = 24;
    param.dict_length = 50;
    
 end

 % for debugging
% load ('dummy.mat'); [centers foo] = vl_kmeans(fullresp, param.dict_length, 'verbose', 'algorithm', 'elkan');


 
    %note you can run this command on multiple matlab instances to do simple multi-threading. 
    % but you have to go into the file and change the flag useBusyFile=true;
    %It won't try to compute the same image descriptors at the same time.
    %descFuns = sort({'centered_mask_sp','bb_extent','pixel_area','centered_mask','absolute_mask','top_height','bottom_height', 'int_text_hist_mr','dial_text_hist_mr','top_text_hist_mr','bottom_text_hist_mr','right_text_hist_mr','left_text_hist_mr','sift_hist_int_','sift_hist_dial','sift_hist_bottom','sift_hist_top','sift_hist_right','sift_hist_left','mean_color','color_std','color_hist','dial_color_hist','color_thumb','color_thumb_mask','gist_int'})';
    
    % may be uncomment it as of now
    
%     descFuns = sort({'centered_mask_sp','bb_extent','pixel_area','absolute_mask','top_height','int_text_hist_mr','dial_text_hist_mr','sift_hist_int_','sift_hist_dial','sift_hist_bottom','sift_hist_top','sift_hist_right','sift_hist_left','mean_color','color_std','color_hist','dial_color_hist','color_thumb','color_thumb_mask','gist_int'});
%     [descFuns,Hist_cell_sift, Hist_cell_mr] = Compute_Desc( fileList, HOMEIMAGES, HOMEDATA,HOMEDATA, HOMECODE, 1, 1:length(fileList), K(j), segSuffix,descFuns,param);
%         [descFuns,Hist_cell_sift, Hist_cell_mr] = Compute_Desc( HOMEDATA,HOMEDATA, HOMECODE, 1, 1:length(param.imFileList), K(j), segSuffix,descFuns,param);
%                                     descFuns =  {'int_text_hist_mr','sift_hist_int_'};
    [descFuns,Hist_cell_sift, Hist_cell_mr] = Compute_Desc( HOMEDATA, HOMECODE,1:length(param.imFileList), param,descr);
                                if param.useHist_vocab
                                    Hist_term_sift = Compute_hist_term(Hist_cell_sift,param);
                                elseif param.useHist_mr
                                    Hist_term_mr = Compute_hist_term(Hist_cell_mr,param);
                                end
                                clear Hist_cell_sift Hist_cell_mr;
