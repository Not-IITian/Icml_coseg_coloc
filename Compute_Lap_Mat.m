function L = Compute_Lap_Mat(descr, param)
% EVALUTATE THE LAPLACIAN MATRIX
% when we use dense sifts on a gride.
% The output is the combination of the Laplacian matrices at different
% scales.
printMessage('Computing Laplacian matrix (mex file)....', 0 , mfilename, 'm');

I=cell(param.nPics,1);
J=cell(param.nPics,1);
V=cell(param.nPics,1);

if numel(param.featFileList) ~= numel(param.imFileList)
    printMessage('wrong number of features or images', 1 , mfilename, 'e');
end

iFeat=0; L_size = 0;

for iIm = 1 : numel(param.imFileList)    
    Im = param.imread( param.imFileList{iIm});   
    for j = 1:size(param.boxes(iIm).coords,1)
             
        idx = (iIm-1)*param.noBoxes + j ;
%         iFeat   = iFeat + param.lW_px(idx);
        L = LaplacianMatrixForOneImage(descr.x{idx} ,descr.y{idx}, Im); % replace this by box
    
    [I{idx}, J{idx}, V{idx}] = find(L);
    
    I{idx} = I{idx} + L_size;
    J{idx} = J{idx} + L_size;
    L_size = L_size + size(L,1);
    
    end
end
L = sparse(cell2mat(I),cell2mat(J),cell2mat(V),L_size,L_size);

printMessage('done');
