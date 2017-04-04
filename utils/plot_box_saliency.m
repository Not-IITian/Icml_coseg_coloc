function plot_box_saliency( param, nfig,titre)

  oldFig = 1; i =1;
    label_str = param.label_mat_str;
 
  load (label_str,'output_labels','Box_coords');
  
  saliency_path = cell2mat([param.path.root ,'input/images/',param.listObj,'/ContrastSal/']);
    SP_path = param.path.superpixel;

List_file = getAllFiles(saliency_path);
  
 [~, name] = fileparts(label_str); 
 save_im_path  = fullfile(param.path.output,name); 
 if param.full ==1
    mkdir(save_im_path);
 end

for iIm = 1 : param.nPics
    
%     image       = param.imread(param.imFileList{iIm});
    image       = param.imread(List_file{iIm});
    
        
    i0 = mod(iIm,4)+4*(mod(iIm,4)==0);
    j0 = floor((iIm-1)/4);
    
    if j0~=oldFig
        oldFig=j0;
        set(gcf,'NextPlot','add');
        axes;
        h = title(titre);
        set(gca,'Visible','off');
        set(h,'Visible','on');
    end
    
    figure(nfig+j0)
    
    if i0==1
        clf 
    end
    
    subplot(2,4,i0)
%     box = Box_coords{iIm} ;
%     visualize(image,box);
    imshow (image,[0,255] );
    set(gca, 'YTick', [])
    set(gca, 'XTick', [])
    hold on
    
    subplot(2,4,i0+4)
    imagesc(output_labels{iIm});
%     imshow(output_labels{i});
    set(gca, 'YTick', [])
    set(gca, 'XTick', [])
    hold on
    if param.full ==1
        if mod(iIm,4)==0
            filename = [ num2str(i),'.jpg'] ;
            f_full_path = fullfile(save_im_path,filename);
            saveas(gcf, f_full_path, 'jpg')
            i = i+1;
        end
    end
end

% if param.full ==1 % if not dummy trial
%     save (label_str,'Class_labels_all_Im','All_Binary_im'); 
% end

set(gcf,'NextPlot','add');
axes;
h = title(titre);
set(gca,'Visible','off');
% set(h,'Visible','on');
if param.ViewOn==0
    close all;
end