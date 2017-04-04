function [Hist_Mat,param] = compute_hist_mat(param, supPix_Intensity)

% Hist_mat = cell(numel(param.imFileList),1);
printMessage('Computing Histogram matrix....');
Hist_cell = cell(numel(param.imFileList),1) ; 

param.nbins = round(sqrt(param.nSupPix/numel(param.imFileList))-1); 

Hist_mat = zeros(param.nbins+1,param.nSupPix);

MAX = max(supPix_Intensity);   
MIN = min(supPix_Intensity);
bin_width = (MAX-MIN)/param.nbins;
% Bin_ranges = [MIN:bin_width:MAX ];
 Bin_ranges = [(MIN-(bin_width/2)):bin_width:(MAX +(bin_width/2))];
 
 

%  for iIm = 1 : numel(param.imFileList) 
%      Hist_cell{iIm} =  zeros(param.nbins+1,param.lW_supPix(iIm));
    for sup_pix = 1:numel(supPix_Intensity)
        
        [~, indx] = histc(supPix_Intensity(sup_pix),Bin_ranges);
       
        Hist_mat(indx,sup_pix) = 1;
%           Hist_cell{iIm}(indx,sup_pix) = 1;
    end
%  end
arrays_index = [0,cumsum(param.lW_supPix)'];
for iIm = 1 : numel(param.imFileList)
    Hist_cell{iIm} =  zeros(param.nbins+1,param.lW_supPix(iIm));
%     if iIm+1 <= numel(param.imFileList)
        Hist_cell{iIm} = Hist_mat(:,arrays_index(iIm)+1:arrays_index(iIm+1));
%     end
end

% Hist_term_diag = cell(numel(param.imFileList),1); Hist_term_cross_im = cell(numel(param.imFileList)-1,1);
Hist_term = cell(numel(param.imFileList)*numel(param.imFileList),1);

for i = 1:numel(param.imFileList)
    for j =1:numel(param.imFileList)
        idx = (i-1)*numel(param.imFileList) +j;
        if i==j
            Hist_term{idx} = (param.nPics -1)*Hist_cell{i}'*Hist_cell{i};
        else
            Hist_term{idx} = -1 * Hist_cell{i}'*Hist_cell{j};
        end
    end
end

Hist_term_im = cell(numel(param.imFileList),1); 
dum_arr = param.nPics*ones(1,param.nPics); 
indx_range = [0,cumsum(dum_arr)];

for i = 1:numel(param.imFileList)
    Hist_term_im{i} = cell2mat(Hist_term(indx_range(i)+1:indx_range(i+1))') ;
end
Hist_Mat = cell2mat(Hist_term_im);
% for i = 1:numel(param.imFileList)
%     for j =1:numel(param.imFileList)