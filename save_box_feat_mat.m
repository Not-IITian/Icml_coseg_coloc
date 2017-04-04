function save_box_feat_mat(param,network_name, typeObj) 
net = load(network_name) ;
net = vl_simplenn_tidy(net) ;
nPics = param.nPics ;
no_box =  param.noBoxes ;       
im_size  = net.meta.normalization.imageSize(1:2) ; % this is the input size of alex net
 feat = zeros(param.nPics*param.noBoxes, 4096);
kk = 1;

for i = 1:nPics
    Im = param.imread(param.imFileList{i}); 
        for j = 1:no_box
            
%            fprintf('Extracting features');
            box = param.boxes(i).coords(j,:);
			box(1:4) = round(box(1:4));
            
            box_idx = (i-1)*no_box + j ;
   
            box_values = single(Im(box(2):box(4),box(1):box(3),:));
        
        im_ = imresize(box_values,im_size ) ;
        mean = net.meta.normalization.averageImage;
% im_ = im_ - net.meta.normalization.averageImage ;

        for k = 1:3 
            A = im_(:,:,k) ;
            im_(:,:,k) = bsxfun(@minus, A, mean(k)) ;
%               Run the CNN.i
        end
        
        res = vl_simplenn(net, im_) ;% Show the classification result.
        feat(box_idx,:) = squeeze(res(20).x) ;
         assert(box_idx == kk)
        kk = kk+1 ;
       
        end    
end 

% define the kernel matrix here:
% kernel = X^T*X ;
        % compute ridge regression matrix (box discriminability)
	
% 	X = X(:,end-999:end);
    X = feat;
    cc= cell2mat(typeObj);
    box_feat_file = ['obj_disc_RP/', cc, 'feat_file','_',num2str(param.noBoxes),'.mat'];
    save(box_feat_file, 'X');