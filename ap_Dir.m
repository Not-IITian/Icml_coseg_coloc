function [ out ] = ap_Dir( path, mustbedir )
% Get the list of a directory in a cell array

if nargin < 2 || isempty(mustbedir), mustbedir = false; end

files = dir(path);
t = strfind(path,'/');
path = path(1:t(end));
out = [];
c = 0;
for i = 1 : length(files)
  
  if (mustbedir && ~files(i).isdir) || files(i).name(1) == '.', continue; end
  
  c = c+1;
  out{c} = [path '/' files(i).name];
  
end

end

