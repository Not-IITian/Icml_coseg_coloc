function plot_groups( param, labels, supPixIndices, nfig,titre)

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

%%%%% my code for evaluation %%%%
Class_labels_all_Im = cell(param.nPics,1); All_Binary_im = cell(param.nPics,1);

%%%%%%%%%%%%%%%%%%5
label_str = param.label_mat_str;
 labels = (labels==repmat(max(labels,[],2),1,param.nClass));
 [~, name] = fileparts(label_str); 
 save_im_path  = fullfile(param.path.output,name); % name of the folder
 
 if param.full ==1
    mkdir(save_im_path);
 end
 
pos = 1;

sumlW = 0; oldFig =1; i =1;

for iIm = 1 : param.nPics
    
    image       = param.imread(param.imFileList{iIm});
%     im = param.imread(param.imFileList{iIm});
     box = param.boxes(iIm).coords(param.box_sol_inds(iIm),:);
     box(1:4) = round(box(1:4));
        
    %     superPixIm  = importdata(param.supPixFileList{iIm});
       superPixIm_Struct  = load(param.supPixFileList{iIm},'supPixIm') ; % this extra step cos now I save both supPix and color in file
       superPixIm = superPixIm_Struct.supPixIm;
    
    %     figure,imagesc(superPixIm)
    
    superPixIm(~ismember(superPixIm, supPixIndices{iIm})) = 0;
    labelsForImage = labels(sumlW + 1 : sumlW + numel(supPixIndices{iIm}),:);
    sumlW =  sumlW + numel(supPixIndices{iIm}) ;
    imageClass = ones(size(superPixIm));
    
    for iClass = 1 : param.nClass
        imageClass(ismember(superPixIm, supPixIndices{iIm}(labelsForImage(:,iClass)==1))) = iClass+1;   % first find all supPix, which are 1 for a particular class, 
    
    end                                                                         % thenall those pixels whose id match with those supPix id
   
    %%%%% my code for evaluation %%%%
    Class_labels_all_Im{iIm} = imageClass;
    All_Binary_im{iIm} = reshape(color(imageClass,:),[size(imageClass) 3]);
    
    %%%%%
    % extra thing for box extraction
%     if param.useBox
%         dummy = 3*ones(size(imageClass));
%         box = param.boxes(iIm).coords(param.box_sol_inds(iIm),:);
% 	    box(1:4) = round(box(1:4));
%         dummy(box(2):box(4),box(1):box(3)) = imageClass(box(2):box(4),box(1):box(3));
%         imageClass = dummy;
%     end
    % 
    imagekk = imageClass;
    imageClass(imagekk(:,1:end-1)~=imagekk(:,2:end,:)) = 1;  % comparing neighbouring pixels and putting them to one when they are not equal but why?
    imagekk = imagekk';
    imageClass = imageClass';
    imageClass(imagekk(:,1:end-1)~=imagekk(:,2:end,:)) = 1;
    
    imageClass = imageClass';
    
      [width, height] = size(imageClass)  ;
      
      for x = 1:width
          for y = 1:height
              if x<box(2) || x>box(4)
                  imageClass(x,y) = 3;
              end
                  if y<box(1) || y>box(3)
      
                        imageClass(x,y) = 3;
                  end
              
          end
      end
%     
    
    imageFinal = reshape(color(imageClass,:),[size(imageClass) 3]); %% this is two color image which tells segmentation
    
    imageFinal =  0.4*imageFinal + 0.6*double(image)./255;  %% this is for superimposing the two colors on the original image for visualisation
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
 
    end
    
    subplot(2,4,i0)
%     imagesc( image );
    visualize(image,box);
    set(gca, 'YTick', [])
    set(gca, 'XTick', [])
    hold on
    
    subplot(2,4,i0+4)
    imagesc( imageFinal );
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

if param.full ==1 % if not dummy trial
    save (label_str,'Class_labels_all_Im','All_Binary_im'); 
end

set(gcf,'NextPlot','add');
axes;
h = title(titre);
set(gca,'Visible','off');
set(h,'Visible','on');
if param.ViewOn==0
    close all;
end
