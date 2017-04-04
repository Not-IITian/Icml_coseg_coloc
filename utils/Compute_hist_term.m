function [ Hist_mat ] = Compute_hist_term(Hist_cell,param)
%THis function takes as input a cell of histogram of all images and return
%sthe positive definite matrix correspodning to the sum of l2 norm histogram diff
%over all images

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
Hist_mat = cell2mat(Hist_term_im);
end

