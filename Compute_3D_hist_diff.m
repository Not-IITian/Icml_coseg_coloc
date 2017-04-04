
Hist_diff_fg = 0;Hist_diff_bg = 0;
 for i = 1:param.nPics
     for j = 1:param.nPics
         if i>j
             aa = sum((Hist_fg_mat(:,i)-Hist_fg_mat(:,j)),2);
            Hist_diff_fg = Hist_diff_fg + aa^2;
            bb = sum((Hist_bg_mat(:,i)-Hist_bg_mat(:,j)),2);
            Hist_diff_bg = Hist_diff_bg + bb^2;
         end
     end
 end


%  dummy = cell(3,3);
% 
%  dummy(1,1) = eye(5);
%  dummy(1,2) = ones(5,10); dummy(1,3) = zeros(5,15); 
%  dummy{2}{1} = ones(10,5); dummy{2}{2} = eye(10); dummy{2}{3}= zeros(10,20);
%  
%  
%  aa = cell2mat(dummy);
 
 if param.useHist_col ==1 && param.useHist_vocab ==0 
        label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_hist_col',num2str(lapWght),'_',num2str(param.wt_hist_col),'_','lambda',num2str(lambda0),'.mat']);
    elseif  param.useHist_vocab ==1 &&param.useHist_col ==0
        label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_hist_sift',num2str(lapWght),'_',num2str(param.wt_hist_sift),'_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);
    elseif param.useHist_vocab ==1 && param.useHist_col ==1
         label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_hist_sift',num2str(lapWght),'_', '_col', num2str(param.wt_hist_sift),'_',num2str(param.wt_hist_col),'_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);
    else
        label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_armand_',num2str(lapWght),'.mat']);
    end