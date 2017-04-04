function visualize(Im, box_sol)
%% VISUALIZE RESULTING BOX FOR EACH IMAGE

% 	imshow(im_path);
imagesc(Im);
hold on;
	xmin = box_sol(1);
	ymin = box_sol(2);
	xmax = box_sol(3);
	ymax = box_sol(4);

	color = [0 1 0];
	linewidth = 3;

  %draw left line
	line([xmin xmin],[ymin ymax],'Color',color,'Linewidth',linewidth);
	
	%draw right line
	line([xmax xmax],[ymin ymax],'Color',color,'Linewidth',linewidth);
	
	%draw top line
	line([xmin xmax],[ymin ymin],'Color',color,'Linewidth',linewidth);
													   
	%draw bottom line
	line([xmin xmax],[ymax ymax],'Color',color,'Linewidth',linewidth);
