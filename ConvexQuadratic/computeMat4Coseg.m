function C = computeMat4Coseg(param, xDif, lapMatrix, projMatrix)

C = projMatrix'*projMatrix - sum(projMatrix)'*sum(projMatrix)/param.nDescr - (xDif * projMatrix)' * xDif * projMatrix;

Lap_mat = param.lapWght*lapMatrix;
C   = C + Lap_mat;
C       = C ./ param.nDescr;
trC     = trace(C);
C       = C/trC;