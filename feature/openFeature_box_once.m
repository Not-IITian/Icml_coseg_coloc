function [descr, descr_im, param] = openFeature_box_once(param)

if  ~isfield( param,'featFileList') || param.reboot
    [param,featEmptyFileList] =  createFeatFileList(param);
           
    if sum(featEmptyFileList(:))~=0
        param = generateAllFeatures(param,featEmptyFileList);
    end    
end

if param.box_form
    fsift = cellfun(@(L) importdata(L), param.box_featFileList); % this will load descriptors from box feat directory defined in computer parameters
else
    fsift = cellfun(@(L) importdata(L), param.featFileList); 
end

descr.data = double(cell2mat(convertData({fsift(:).data}',3))) ;
descr.x =  convertData({fsift(:).x},2); 
descr.y =  convertData({fsift(:).y},2);

param.lW_px = cellfun(@(L) firstSize(L,3) ,{fsift.data})';
if param.box_form 
    fsift_im = cellfun(@(L) importdata(L), param.im_featFileList); 
    descr_im.x =  convertData({fsift_im(:).x},2); 
    descr_im.y =  convertData({fsift_im(:).y},2);
    
else
    descr_im = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function z = convertData(y,d)
        z = cellfun(@(x) reshape(x, [firstSize(x,d), secondSize(x,d)]), y,'UniformOutput', 0);
%           z = cellfun(@(x) reshape(x, [firstSize(x,d), secondSize(x,d)]), y,'UniformOutput', false,0);
    end

    function sz = firstSize(x,d)
        sz = size(x,1) * ( (size(x,2) - 1) * (size(x,d)~=1) + 1);
    end

    function sz = secondSize(x,d)
        sz = numel(x) / firstSize(x,d) ;
    end

end

