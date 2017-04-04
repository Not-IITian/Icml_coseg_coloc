  function [box_vec] = Compute_saliency_box(param)
% 
    
    saliency_path = param.saliency_path;
    List_file = getAllFiles(saliency_path);    
% normalised_sampled_values_cell = cell(numel(param.nPics,1));
box_vec = zeros(1,param.nPics*param.noBoxes);

for i = 1:param.nPics
        for j = 1:param.noBoxes           
            box = param.boxes(i).coords(j,:);
			box(1:4) = round(box(1:4));           
            box_idx = (i-1)*param.noBoxes + j ;         
            
            if param.pascal_10
                [dirN baseFName ] = fileparts(param.imFileList{i}); 
                 sal_file = [saliency_path, baseFName, '_res.png'] ;
                 Im  = param.imread(sal_file);
            else
                Im = param.imread(List_file{i});
            end      
            
            size_im = size(Im);
            size_box = (box(4)-box(2))*(box(3)- box(1)) ;
            Im_size = size_im(1)*size_im(2);
            
             if param.scaled_sal_box  
                box_wt = size_box/Im_size; % always between 0 and 1
            else
                box_wt = 1;  % during alt_optim, do no tscal eas there is no problem
             end
            
            box_values = double(Im(box(2):box(4),box(1):box(3)));
            box_scaled_values =  box_values./256 ; % values scaled between 0 and 1          
            
%                width_im = size(sal_values_cell{Im},1);
%   sal_sampled_values_cell{Im} = double(sal_values_cell{Im}(descr.y{Im} + width_im * (descr.x{Im}-1)));
%   normalised_sampled_values_cell{Im}  = sal_sampled_values_cell{Im}./sum(sal_sampled_values_cell{Im});
%   
            avg_sal_box  = sum(sum(box_scaled_values))/size_box;  
             sal_box =   box_wt*avg_sal_box ; % just to ensure they r between 0 and 1  
            box_vec( box_idx) =  -log(sal_box + eps); % this will make values positive
        end   
end
end