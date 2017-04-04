function plot_groups_original( param, labels, supPixIndices, nfig,titre)


color= [ ...
    [1  1  1];...
    [1 0 0];...
    [0 1 0];...
    [0 0 1];...
    [1 1 0];...
    [0 1 1];...
    [1 0 1];...
    [.5 0.5 0];...
    [0 1 1];...
    [1 0 1];...
    [0 0.5 .5];...
    [0.5 0 0];...
    [0.5 .5 .5];...
    ];
labels = (labels==repmat(max(labels,[],2),1,param.nClass));
pos = 1;
label_str = param.label_mat_str;
Class_labels_all_Im = cell(param.nPics,1);
sumlW = 0;oldFig =1;
All_Binary_im = cell(param.nPics,1);
 box_sol_inds = param.box_sol_inds;
 saliency_path = param.saliency_path;

for iIm = 1 : param.nPics   
    image       = param.imread(param.imFileList{iIm});   
    superPixIm  = importdata(param.supPixFileList{iIm}); 
    [dirN, baseFName] = fileparts(param.imFileList{iIm}); 
   
    sal_file = [saliency_path, baseFName, '_res.png'] ;
    
    image_sal = param.imread(sal_file);  
    %     figure,imagesc(superPixIm)   
    superPixIm(~ismember(superPixIm, supPixIndices{iIm})) = 0;    
    labelsForImage = labels(sumlW + 1 : sumlW + numel(supPixIndices{iIm}),:);    
    sumlW =  sumlW + numel(supPixIndices{iIm});  
    imageClass = ones(size(superPixIm));    
    for iClass = 1 : param.nClass
        imageClass(ismember(superPixIm, supPixIndices{iIm}(labelsForImage(:,iClass)==1) ) ) = iClass+1;
    end        
     %%%%% my code for evaluation %%%%
    Class_labels_all_Im{iIm} = imageClass;
    All_Binary_im{iIm} = reshape(color(imageClass,:),[size(imageClass) 3]);
    %%%%
    imagekk = imageClass;
    imageClass(imagekk(:,1:end-1)~=imagekk(:,2:end,:)) = 1;
    imagekk = imagekk';
    imageClass = imageClass';
    imageClass(imagekk(:,1:end-1)~=imagekk(:,2:end,:)) = 1;
    imageClass = imageClass';
        
    imageFinal = reshape(color(imageClass,:),[size(imageClass) 3]);
     imageFinal =  0.4*imageFinal + 0.6*double(image)./255;
    imageFinal = imageFinal.*repmat(imageClass~=1, [ 1 1 3]) + repmat(imageClass==1, [ 1 1 3]);
       
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
    visualize(image,box); % this was visualize(image, box) before, now instead of showin bbox on orig im, we show it over segmented image
    % replace this by boxes
%     imagesc( image );
    set(gca, 'YTick', [])
    set(gca, 'XTick', [])
    hold on
    
    subplot(2,4,i0+4)
    %imshow(image_sal) ; % it was before imagesc( imageFinal ), replaced with saliency file;
    imagesc( imageFinal )
    set(gca, 'YTick', [])
    set(gca, 'XTick', [])
    hold on
%     pause ;
%  if  mod(iIm,4) ==0
%       pause;
%  end
end
save (label_str,'Class_labels_all_Im'); 
 set(gcf,'NextPlot','add');
axes;
h = title(titre);
set(gca,'Visible','off');
set(h,'Visible','on');

