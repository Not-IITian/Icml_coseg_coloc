 param.useHist_mr =0 ;   param.useHist_col =0;

if param.useHist_col ==1 && param.useHist_vocab ==0 && param.useHist_mr ==0 && param.wt_disc && param.useSaliency==0
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_disc_col',num2str(lapWght),'_',num2str(param.wt_hist_col),'_','lambda',num2str(lambda0),'.mat']);
        
    elseif param.useHist_col ==1 && param.useHist_vocab ==0 && param.useHist_mr ==0 && param.wt_disc == 0 && param.useSaliency==0
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_col_only','_',num2str(lapWght),'_',num2str(param.wt_hist_col),'_','lambda',num2str(lambda0),'.mat']);
            
    elseif  param.useHist_vocab ==1 && param.useHist_col ==0 && param.useHist_mr ==0 && param.wt_disc && param.useSaliency==0
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_disc_sift',num2str(lapWght),'_',num2str(param.wt_hist_sift),'_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);
        
    elseif  param.useHist_vocab ==1 && param.useHist_col ==0 && param.useHist_mr ==0 && param.wt_disc == 0 && param.useSaliency==0
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_sift_only',num2str(param.wt_hist_sift),'_',num2str(param.dict_length),'_',num2str(lapWght),'_','lambda',num2str(lambda0),'.mat']);
   
    elseif  param.useHist_vocab ==0 && param.useHist_col ==1 && param.useHist_mr ==1 && param.wt_disc && param.useSaliency==0
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_disc_col_text',num2str(lapWght),'_',num2str(param.wt_hist_col),'_',num2str(param.wt_hist_mr),'_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);
      
    elseif  param.useHist_vocab ==0 && param.useHist_col ==0 && param.useHist_mr ==1  && param.wt_disc
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'disc_text',num2str(lapWght),'_',num2str(param.wt_hist_mr),'_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);
    
    elseif  param.useHist_vocab ==0 && param.useHist_col ==0 && param.useHist_mr ==1  && param.wt_disc == 0
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'text_only',num2str(param.wt_hist_mr),'_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);
    
    elseif  param.useHist_vocab ==1 && param.useHist_col ==0 && param.useHist_mr ==1  && param.wt_disc && param.useSaliency==0
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_disc_sift_text',num2str(lapWght),'_',num2str(param.wt_hist_sift),'_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);   
    
    elseif param.useHist_vocab ==1 && param.useHist_col ==1 && param.useHist_mr ==0 && param.wt_disc && param.useSaliency==0
         param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_sift',num2str(lapWght),'_', 'col', num2str(param.wt_hist_sift),'_',num2str(param.wt_hist_col),'_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);
      
    elseif  param.useHist_vocab ==1 && param.useHist_col ==1 && param.useHist_mr ==1 && param.wt_disc && param.useSaliency==0
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_sift_col_text',num2str(lapWght),'_',num2str(param.wt_hist_sift),'_',num2str(param.wt_hist_col),'_',num2str(param.wt_hist_mr),'_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);
%         workspace_str = cell2mat([param.path.root,typeObj,'_sift_col_text',num2str(lapWght),'_',num2str(param.wt_hist_sift),'_',num2str(param.wt_hist_col),'_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);
    elseif  param.useHist_vocab ==1 && param.useHist_col ==0 && param.useHist_mr ==0 && param.wt_disc && param.useSaliency 
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_disc_sift_sal_box',num2str(param.wt_disc),'_',num2str(lapWght),'_',num2str(param.wt_hist_sift),num2str(param.wt_saliency),'_','_',num2str(param.dict_length),'_','lambda',num2str(lambda0),'.mat']);
    
    elseif  param.useHist_vocab ==0 && param.useHist_col && param.useHist_mr ==0 && param.wt_disc && param.useSaliency 
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_disc_col_sal',num2str(param.wt_disc),'_',num2str(lapWght),'_',num2str(param.wt_hist_col),'_',num2str(param.wt_saliency),'_','lambda',num2str(lambda0),'.mat']);
        
    elseif  param.useHist_vocab ==0 && param.useHist_col ==0 && param.useHist_mr ==0 && param.wt_disc == 0 && param.useSaliency
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_sal_only','_','lambda',num2str(lambda0),'.mat']);
        
    elseif  param.useHist_vocab && param.useHist_col ==0 && param.useHist_mr ==0 && param.wt_disc == 0 && param.useSaliency
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_sal_sift','_',num2str(param.wt_hist_sift),'_',num2str(param.wt_saliency),'_','lambda',num2str(lambda0),'.mat']);
     
    elseif  param.useHist_vocab ==0 && param.useHist_col ==0 && param.useHist_mr ==0 && param.wt_disc  && param.useSaliency
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_disc_sal_box',num2str(param.wt_disc),'_',num2str(param.wt_saliency),'_',num2str(lapWght),'_',num2str(param.noBoxes),'_','lambda',num2str(lambda0),'.mat']);
        
    elseif  param.useHist_vocab==0 && param.useHist_col && param.useHist_mr ==0 && param.wt_disc == 0 && param.useSaliency
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_sal_col','_',num2str(param.wt_hist_col),'_',num2str(param.wt_saliency),'_','lambda',num2str(lambda0),'.mat']);
         
    else
        param.label_mat_str = cell2mat([param.path.root,'eval/', typeObj,'/',typeObj,'_armand_',num2str(lapWght),'.mat']);
%         workspace_str = cell2mat([param.path.root,typeObj,'_armand_',num2str(lapWght),'.mat']);
    end
    %%%%