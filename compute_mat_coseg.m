function paramDif = compute_mat_coseg(param, projMatrix, lapMatrix, xDif)
printMessage('Convex quadratic cosegmentation : BEGIN', 1 , mfilename, 'm');

paramDif                    = param;
xDif                        = ridgeKernel( xDif, param.lambda );

paramDif.optim.tab_lambda0  = floor( param.lW_px * param.optim.lambda0 + 1 );

paramDif.C              = computeMat4Coseg(param, xDif, lapMatrix, projMatrix);
