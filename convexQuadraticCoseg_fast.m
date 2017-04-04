function [paramDif ,im_supPix_var_cell,box_supPix_non_zeros,Proj_box_supPix_mat ] = convexQuadraticCoseg_fast( param, projMatrix , xDif)

printMessage('Convex quadratic cosegmentation : BEGIN', 1 , mfilename, 'm');
paramDif                    = param;


xDif                        = ridgeKernel( xDif, param.lambda );
paramDif.optim.tab_lambda0  = floor( param.lW_px*param.optim.lambda0 + 1);


X_dif_term = (xDif * projMatrix)' * xDif * projMatrix ;
clear xDif

% Disc_mat = (projMatrix'*projMatrix - sum(projMatrix)'*sum(projMatrix)/param.nDescr - (xDif * projMatrix)' * xDif * projMatrix);
    Disc_mat = (projMatrix'*projMatrix - sum(projMatrix)'*sum(projMatrix)/param.nDescr - X_dif_term); 
       
    C = Disc_mat ; % what are the
clear X_dif_term ;
 paramDif.C = C;
 
% paramDif.C              = computeMatrixForConvQuadOptim(param, xDif, lapMatrix, projMatrix);
%%%%% my code
[im_supPix_var_cell,box_supPix_non_zeros,  Proj_box_supPix_mat, total_supPix_var]  = computeMatrixForConvQuadOptim(param);


paramDif.total_supPix_var = total_supPix_var ;