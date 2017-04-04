%%%%%%%%%% OPEN FEATURES %%%%%%%%%%%%

if 0
    
elseif strcmp(typeObj,'goose')
    load('goose_kernel.mat');
    param.imFileList = param_dummy.imFileList;
    param.featFileList = param_dummy.featFileList ;
    param.lW_px = param_dummy.lW_px;
    clear param_dummy
    
 elseif strcmp(typeObj,'statue')
    load('statue_kernel.mat');
    param.imFileList = param_dummy.imFileList;
    param.featFileList = param_dummy.featFileList ;
    param.lW_px = param_dummy.lW_px;
    clear param_dummy
 elseif strcmp(typeObj,'soccer')  % soccer
    load('soccer_kernel.mat');
    param.imFileList = param_dummy.imFileList;
    param.featFileList = param_dummy.featFileList ;
    param.lW_px = param_dummy.lW_px;
    clear param_dummy
 elseif strcmp(typeObj,'kendo')   % kendo
    load('kendo_kernel.mat');
    param.imFileList = param_dummy.imFileList;
    param.featFileList = param_dummy.featFileList ;
    param.lW_px = param_dummy.lW_px;
    clear param_dummy
    
 elseif strcmp(typeObj,'kite')  % kite
    load('kite_kernel.mat');
    param.imFileList = param_dummy.imFileList;
    param.featFileList = param_dummy.featFileList ;
    param.lW_px = param_dummy.lW_px;
    clear param_dummy
    
 elseif strcmp(typeObj,'baseball') 
    load('baseball_kernel.mat');
    param.imFileList = param_dummy.imFileList;
    param.featFileList = param_dummy.featFileList ;
    param.lW_px = param_dummy.lW_px;
    clear param_dummy
else

    descr.data = funKernel(descr.data);  % defined in computer parameter/
end
[ param.nDescr param.dimDescr] = size(descr.data);