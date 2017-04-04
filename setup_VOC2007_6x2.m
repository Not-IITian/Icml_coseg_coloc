
overwrite = 1;
% ----------------------------------------------------------------------
% configuration
root_result = 'eval_coloc_files/';
conf.path_result  = fullfile(root_result);
conf.path_dataset = fullfile(db_root, 'VOC2007_6x2');
cls_name = cell2mat(typeObj) ;
file_metadata = cls_name ;
if overwrite    
    fprintf('= Setup for %s\n', name_experiment);
    classes = dir(conf.path_dataset);
    classes = classes([classes.isdir]);
    classes = {classes(3:end).name};    
    images = {};
    imageClass = {};
    
    for ci = 1:length(classes)
        ims = dir(fullfile(conf.path_dataset, classes{ci}, '*.bmp'));
        ims = [ ims; dir(fullfile(conf.path_dataset, classes{ci}, '*.jpg')) ];
        ims = [ ims; dir(fullfile(conf.path_dataset, classes{ci}, '*.png')) ];
        ims = cellfun(@(x)fullfile(conf.path_dataset,classes{ci},x),{ims.name},'UniformOutput',false) ;
        images = {images{:}, ims{:}};
        imageClass{end+1} = ci * ones(1,length(ims));        
    end
    
    imageClass = cat(2, imageClass{:});    
    classes_eval  = classes;
    imageClass_eval  = imageClass;
    save(fullfile(conf.path_result, file_metadata), 'conf', 'images', ...
                                                    'classes', 'classes_eval', ...
                                                    'imageClass', 'imageClass_eval');    
else
    load(fullfile(conf.path_result,file_metadata));
end




