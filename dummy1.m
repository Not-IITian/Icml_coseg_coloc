
% script for moving files frm a strcutured folder to another
% dataset
clear all
source_dir = '/BS/deep_3d/work/coseg/coseg_joint_cluster/Davis_data/JPEGImages/480p/';
sal_path = '/BS/deep_3d/work/coseg/coseg_joint_cluster/Davis_data/JPEGImages/480p/bear/res';
dest_base_dir = './Davis_val/';
base_Davis_dir = './Davis_data/';
class_folders_name = ap_Dir(dest_base_dir, true) ; % the output is a cell here
classes = cellfun(@(x) strsplit(x, '/'), class_folders_name, 'UniformOutput', false);
class_names = cellfun(@(x) x(end), classes,'UniformOutput', false);
%no_files = cellfun(@(x) length(ap_Dir([x,'/*.jpg'])), class_folders_name, 'UniformOutput', false);

cellfun(@(x) mkdir(cell2mat([dest_base_dir,x, '/superpixel/'])), class_names,'UniformOutput', false)

fid=fopen('train.txt');
C = textscan(fid, '%s%s');
file_names = cellfun(@(x) strsplit(x, '/'), C{1}, 'UniformOutput', false);
class_val= cellfun(@(x) x(end-1), file_names,'UniformOutput', false);
frames = cellfun(@(x) x(end), file_names,'UniformOutput', false);

% cant you further use cellfun and get rid of for loop
for i= 1:length(C{1})
   class = class_val{i};
   frame_no = frames{i};
   [~,pic_name,~] = fileparts(cell2mat(frame_no));
   sal_file_name = [pic_name, '_res.png'];
    source_file = cell2mat([source_dir,class, '/res/', sal_file_name]);
    dest_file = cell2mat([dest_base_dir,class, '/ContrastSal/', sal_file_name]);
    if exist(source_file, 'file') && ~exist(dest_file, 'file')
    copyfile(source_file, dest_file);
    end
end
fclose(fid);true