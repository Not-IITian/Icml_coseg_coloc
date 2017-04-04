function plot_groups_coloc( param, folder_name, accuracy_file_name, nfig,titre)
eval_path = ['eval_coloc_files/'];
pos = 1;
sumlW = 0;oldFig =1;
saliency_path = param.saliency_path;
 box_sol_inds = param.box_sol_inds;

for iIm = 1 : param.nPics   
    
    image       = param.imread(param.imFileList{iIm}); 
    [dirN, baseFName] = fileparts(param.imFileList{iIm}); 
    
    sal_file = [saliency_path, baseFName, '_res.png'] ;
    
    image_sal = param.imread(sal_file);   
    
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
%         pause ;
    end   
    
    subplot(2,4,i0)
    box = param.boxes(iIm).coords(box_sol_inds(iIm),:);
	box(1:4) = round(box(1:4));
    visualize(image,box);
    % replace this by boxes
%     imagesc( image );
    set(gca, 'YTick', [])
    set(gca, 'XTick', [])
    hold on
    
    subplot(2,4,i0+4)
    imshow( image_sal );
    set(gca, 'YTick', [])
    set(gca, 'XTick', [])
    hold on
%     pause ;
 if  mod(iIm,4) ==0
     file_name = [folder_name, '/',accuracy_file_name, '_', num2str(pos)];
     saveas(gcf,file_name,'png') ;
     pos = pos+1 ;
     
     end

 
     end
% save (label_str,'Class_labels_all_Im'); 
 set(gcf,'NextPlot','add');
axes;
h = title(titre);
set(gca,'Visible','off');
set(h,'Visible','on');

