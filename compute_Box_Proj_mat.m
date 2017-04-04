function [boxprojMatrix, param, Sup_occurence_cell] = compute_Box_Proj_mat(descr, param)

no_files = numel(param.imFileList) ;
boxSupPixIm = cell(no_files*param.noBoxes,1);
param.supPixFileList  =  cell(no_files,1);
BoxsupPixIndices  = cell(no_files*param.noBoxes,1);
printMessage('Open superpixels files...', 0 , mfilename, 'm');
indPt = 0;
createSP = 0;
% structure for maintainig the occurence of supPix in various boxes
for iIm = 1:no_files
    [pathIm, fileName, ~] = fileparts(param.imFileList{iIm});       
    imFileName = [pathIm, '/superpixel/',fileName,'.mat'];    
    %%%%% LOAD SUPERPIXELS
    if isempty(dir(imFileName))  || param.reboot
        if iIm == 1
            fprintf('\n')
        end
        createSP = 1;
        printMessage(sprintf('compute superpixels for image : %s ...',param.imFileList{iIm}), 0, mfilename,'w');
         [~, supPixIm]  = param.compSupPix(param.imFileList{iIm});
        save(imFileName,'supPixIm');    
        printMessage('done');
    else
        load(imFileName, 'supPixIm');
    end  
    
    param.supPixFileList {iIm} = imFileName;   
    for j = 1:size(param.boxes(iIm).coords,1)
        idx = (iIm-1)*param.noBoxes + j ;
        BoxsupPixIndices{idx} = supPixIm(descr.y{idx} + size(supPixIm,1)* (descr.x{idx}-1)) ;    %  we have descr.x for each box separately.        
        boxSupPixIm{idx}= indPt+BoxsupPixIndices{idx} ;   
        indPt = indPt + numel(unique(supPixIm(:)));    
    end    
end 
param.local_supPix     = cellfun(@(x) numel(unique(x)),boxSupPixIm);
param.tot_SupPix       = sum(param.local_supPix);
 
boxSupPixIm         = double(cell2mat (boxSupPixIm));
boxprojMatrix      = sparse( (1 : numel(boxSupPixIm))', boxSupPixIm(:), 1 , numel(boxSupPixIm), max(boxSupPixIm(:)));
boxprojMatrix(:,sum(boxprojMatrix,1)==0) = [];
