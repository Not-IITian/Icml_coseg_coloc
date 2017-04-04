 
              
 oldFig = 1 ; titre = 'random best box' ;
 nfig = 1;
 for iIm = 1 : param.nPics
    
    image       = param.imread(param.imFileList{iIm});
        
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
%       box = Box_coords{iIm} ;
    
    box = param.boxes(iIm).coords(box_sol_inds(iIm),:);
			box(1:4) = round(box(1:4));
    visualize(image,box);
%     imagesc( image );
    set(gca, 'YTick', [])
    set(gca, 'XTick', [])
    hold on
    
    subplot(2,4,i0+4)
    
     imagesc(image);

%     imshow(output_labels{iIm});
    set(gca, 'YTick', [])
    set(gca, 'XTick', [])
    hold on
    if param.full
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