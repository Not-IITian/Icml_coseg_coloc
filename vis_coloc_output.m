% class_names --> exp_pramater_names-->acc_files

% first find the best 5 performance among exp with full images..
% then find best 3 overall
clear all
max_no = 5; % this is the max scores u want to visualize/cmpare
base_dir = './acc_val/' ;

class_folders= ap_Dir(base_dir, true);
fieldnames = {'Map', 'corLoc_val'} ;
sort_by_Map = 0;

class_names_cell = cellfun(@(x) strsplit(x, '/'), class_folders,'UniformOutput', false );
class_names = cellfun(@(x) x{3}, class_names_cell, 'UniformOutput', false);
count = 1;

for i = class_folders  
    exp_folders = ap_Dir(cell2mat([i '/exp*'])); % if we do true, this will exclude without folder files
    
   acc_files = cellfun(@(x) ap_Dir([x '/*.mat']), exp_folders, 'UniformOutput', false); % now load each of them
   acc_metric = cellfun(@(L) importdata(cell2mat(L)), acc_files);
   Corloc = [];
   Map =[];
   for j = 1:length(acc_metric)
       Corloc = [Corloc;acc_metric(j).corLoc_val] ;
       Map = [Map;acc_metric(j).Map];
   end
    [sorted_Corloc,Ind] = sort(Corloc, 'descend');
    [sorted_Map, Ind_Map] = sort(Map, 'descend');
    if sort_by_Map
         exp_param_cell = cellfun(@(x) strsplit(x, '_'), exp_folders(Ind_Map(1:max_no)),'UniformOutput', false);
    else
        exp_param_cell = cellfun(@(x) strsplit(x, '_'), exp_folders(Ind(1:max_no)),'UniformOutput', false);
    end
    class_name = class_names{count};
    param(count).class = class_name;
    
    for k = 1:max_no  
        param(count).info(k).sal_w = exp_param_cell{k}{4};
        param(count).info(k).box_w = exp_param_cell{k}{5};
        param(count).info(k).max_const = exp_param_cell{k}{6};
        param(count).info(k).min_const = exp_param_cell{k}{7};
        param(count).info(k).mu = exp_param_cell{k}{8};
        param(count).info(k).n_im = exp_param_cell{k}{9};
        param(count).info(k).n_box = exp_param_cell{k}{10};
        param(count).info(k).corLoc = sorted_Corloc(k);
        param(count).info(k).Map = sorted_Map(k);
              
    end
    count = count +1;
end