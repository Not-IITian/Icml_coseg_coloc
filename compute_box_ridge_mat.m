function C_box = compute_box_ridge_mat(param)

nPics = param.nPics ;
no_box =  param.noBoxes ;       

load(param.box_feat_file, 'X')
[param.lambda_b, xDif_b] = computeRegularizationParam(X', param.df);
  nDescr = nPics*no_box ; 
    disp('Computing ridge regression matrix for boxes...')
  %  param.lambda_b = .01; tr this and see if it improves anything as
  %  claimed by armand and co..
  
 projMatrix_box = sparse((1:nDescr)',(1:nDescr)',1);
     xDif_b   = ridgeKernel( xDif_b, param.lambda_b );
    
C_box = projMatrix_box'*projMatrix_box - sum(projMatrix_box)'*sum(projMatrix_box)/nDescr - (xDif_b * projMatrix_box)' * xDif_b * projMatrix_box;

C_box       = C_box ./nDescr;
trC     = trace(C_box);
C_box       = C_box/trC;