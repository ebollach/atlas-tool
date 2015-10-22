function view_WSS_vectors

global mrstruct_mask
global Wss_point_cloud
global mrStruct

clc, clear%, close all
currDir = pwd;
[FileName,MrstructPath,FilterIndex] = uigetfile(currDir,'Select the mag_struct file of your patient');
try
    cd(MrstructPath);
catch
    warndlg('File not found!');
    return;
end
load mask_struct_aorta.mat
load Wss_point_cloud_aorta

mask2 = mrstruct_mask.dataAy;
mask2_vox = mrstruct_mask.vox;

L2 = (mask2 ~= 0);
contours = zeros(size(L2));
contours(L2==0) = -1;
contours(L2==1) = 1;
[F,V] = isosurface(contours,0); % make a surface from the detected contours
V = V .* (ones(size(V,1),1) * mask2_vox(1:3));

WSS_all = Wss_point_cloud; clear Wss_point_cloud
% WSS for timestep 3 (peak systole)
WSS = WSS_all{3};
wss_m = sqrt(WSS(:,1).^2 + WSS(:,2).^2 + WSS(:,3).^2);

% f=figure('Name','WSS vectors')
% a = [2 15];
% c = [ ];
% patch('Faces',F,'Vertices',V, ...
%     'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',1);
% hold on
% [F2,V2,C2]=quiver3Dpatch(V(:,1),V(:,2),V(:,3),WSS(:,1),WSS(:,2),WSS(:,3),c,a);
% patch('Faces',F2,'Vertices',V2,'CData',C2,'FaceColor','flat','EdgeColor','none','FaceAlpha',1);
% caxis([0 1.5])
% axis equal;axis off; axis ij
% view([-180 -90])
% 
% f=figure('Name','WSS vectors - multiple views')
% subplot(1,3,1);
% a = [2 15];
% c = [ ];
% patch('Faces',F,'Vertices',V, ...
%     'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',1);
% hold on
% [F2,V2,C2]=quiver3Dpatch(V(:,1),V(:,2),V(:,3),WSS(:,1),WSS(:,2),WSS(:,3),c,a);
% patch('Faces',F2,'Vertices',V2,'CData',C2,'FaceColor','flat','EdgeColor','none','FaceAlpha',1);
% caxis([0 1.5])
% axis equal;axis off; axis ij
% view([-180 -90])
% subplot(1,3,2);
% a = [2 15];
% c = [ ];
% patch('Faces',F,'Vertices',V, ...
%     'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',1);
% hold on
% [F2,V2,C2]=quiver3Dpatch(V(:,1),V(:,2),V(:,3),WSS(:,1),WSS(:,2),WSS(:,3),c,a);
% patch('Faces',F2,'Vertices',V2,'CData',C2,'FaceColor','flat','EdgeColor','none','FaceAlpha',1);
% caxis([0 1.5])
% axis equal;axis off; axis ij
% view([0 90])
% subplot(1,3,3);
% a = [2 15];
% c = [ ];
% patch('Faces',F,'Vertices',V, ...
%     'EdgeColor','none','FaceColor',[0.5 0.5 0.5],'FaceAlpha',1);
% hold on
% [F2,V2,C2]=quiver3Dpatch(V(:,1),V(:,2),V(:,3),WSS(:,1),WSS(:,2),WSS(:,3),c,a);
% patch('Faces',F2,'Vertices',V2,'CData',C2,'FaceColor','flat','EdgeColor','none','FaceAlpha',1);
% caxis([0 1.5])
% axis equal;axis off; axis ij
% view([-180 0])
% 
% [a,ind]=find(MrstructPath=='\');
% set(gcf,'NextPlot','add');
% axes;
% h = title(MrstructPath(ind(end-3)+1:ind(end-1)-1));
% set(gca,'Visible','off');
% set(h,'Visible','on');
% 
% print(f,'-djpeg','-r600',strcat(MrstructPath,'\systWSS'));

% Regional analysis
% figure, patch('Faces',F,'Vertices',V, ...
%     'EdgeColor','none','FaceColor',[1 0 0],'FaceAlpha',1);
mask2_vox = mrstruct_mask.vox;
x = V(:,1)/mask2_vox(1);
y = V(:,2)/mask2_vox(2);
z = V(:,3)/mask2_vox(3);
figure, patch('Faces',F,'Vertices',[x y z], ...
    'EdgeColor','none','FaceColor',[1 0 0],'FaceAlpha',1);
axis equal;axis off; axis ij
view([-180 -90])

gray_colormap = colormap(gray);
color3(1,:) = [0 0 1];
color3(2,:) = [1 0 0];
color3(3,:) = [0.5 0.5 0.5];
color3(4:64,:) = gray_colormap(4:64,:);
colormap(color3);
caxis([0 64]);
axis equal; axis ij; axis off;
aspectRatio = 1./mask2_vox;
set(gca,'dataaspectRatio',aspectRatio(1:3))
view([-180 -90]);
load mag_struct
magnitude = flipdim(double(mrStruct.dataAy(:,:,:,3)),3);
magnitude(magnitude == 0) = 3;
magnitude(magnitude == 1) = 3;
magnitude(magnitude == 2) = 3;
hold on
s4 = surf(1:size(magnitude,2),1:size(magnitude,1),ones([size(magnitude,1) size(magnitude,2)]) .* size(magnitude,3)/2,magnitude(:,:,size(magnitude,3)/2),'EdgeColor','none');
title({'Draw 1)proximal AAo inner, 2)proximal AAo outer, 3)distal AAo inner, 4)distal AAo outer,';'5)arch inner, 6)arch outer, 7)proximal DAo inner, 8)proximal DAo outer,';'9)distal DAo inner and 10)distal DAo outer regions';'then double-click and press space'})

uicontrol('Style','text',...
    'Position',[10 200 120 70],...
    'String','Please choose using the slider the magnitude slice')
uicontrol('Style','text',...
    'Position',[10 75 120 20],...
    'String','Slice slider')
sl1 = uicontrol('Style', 'slider',...
    'Min',1,'Max',size(magnitude,3),'Value',size(magnitude,3)/2,...
    'Position', [10 50 120 20],...
    'SliderStep',[1/(size(magnitude,3)-1) 10/(size(magnitude,3)-1)],...
    'Callback', {@move_slice3,gca});

mkdir(strcat(MrstructPath, '..'),'regional_masks')

choice = questdlg('Do you want to draw new ROIs or load a previous one?', ...
	'ROIs creation', ...
	'Draw new','Load existing','Draw new');
% Handle response
switch choice
    case 'Draw new'
        
        for i = 1:10
            %Polygon and mask
            polyAAo = impoly;
            wait(polyAAo);
            region = getPosition(polyAAo);
            %mask = inpolygon(x, y, AAo(:,1), AAo(:,2));
            
            disp('saving, pausing')
            save(strcat([MrstructPath '..' '\regional_masks\mask' num2str(i)]),'region');
            pause
        end
        
        % compute WSS in the 10 regional ROIs
        load(strcat(MrstructPath,'..','\regional_masks\mask1'));
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask_proxAAo_inner = wss_m(mask_wss);
        load(strcat(MrstructPath,'..','\regional_masks\mask2'));
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask_proxAAo_outer = wss_m(mask_wss);
        load(strcat(MrstructPath,'..','\regional_masks\mask3'));
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask_distAAo_inner = wss_m(mask_wss);
        load(strcat(MrstructPath,'..','\regional_masks\mask4'));
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask_distAAo_outer = wss_m(mask_wss);
        load(strcat(MrstructPath,'..','\regional_masks\mask5'));
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask_arch_inner = wss_m(mask_wss);
        load(strcat(MrstructPath,'..','\regional_masks\mask6'));
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask_arch_outer = wss_m(mask_wss);
        load(strcat(MrstructPath,'..','\regional_masks\mask7'));
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask_proxDAo_inner = wss_m(mask_wss);
        load(strcat(MrstructPath,'..','\regional_masks\mask8'));
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask_proxDAo_outer = wss_m(mask_wss);
        load(strcat(MrstructPath,'..','\regional_masks\mask9'));
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask_distDAo_inner = wss_m(mask_wss);
        load(strcat(MrstructPath,'..','\regional_masks\mask10'));
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask_distDAo_outer = wss_m(mask_wss);
        
        save(strcat(MrstructPath,'..','\regional_masks\wss_values'),'wss_mask_proxAAo_inner','wss_mask_proxAAo_outer','wss_mask_distAAo_inner','wss_mask_distAAo_outer','wss_mask_arch_inner','wss_mask_arch_outer','wss_mask_proxDAo_inner','wss_mask_proxDAo_outer',...
            'wss_mask_distDAo_inner','wss_mask_distDAo_outer');
        
        % compute quantitative indices
        indices{1,1} = '';
        indices{2,1} = 'mean';
        indices{3,1} = 'median';
        indices{4,1} = 'max';
        indices{5,1} = 'min';
        indices{6,1} = 'std';
        indices{7,1} = 'max5percent';
        indices{8,1} = 'max2percent';
        indices{9,1} = 'min5percent';
        indices{10,1} = 'min2percent';
        
        indices{1,2} = 'proxAAo_inner';
        indices{2,2} = mean(wss_mask_proxAAo_inner);
        indices{3,2} = median(wss_mask_proxAAo_inner);
        indices{4,2} = max(wss_mask_proxAAo_inner);
        indices{5,2} = min(wss_mask_proxAAo_inner);
        indices{6,2} = std(wss_mask_proxAAo_inner);
        WSS_sorted = sort(wss_mask_proxAAo_inner);
        indices{7,2} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        indices{8,2} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        indices{9,2} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        indices{10,2} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        indices{1,3} = 'proxAAo_outer';
        indices{2,3} = mean(wss_mask_proxAAo_outer);
        indices{3,3} = median(wss_mask_proxAAo_outer);
        indices{4,3} = max(wss_mask_proxAAo_outer);
        indices{5,3} = min(wss_mask_proxAAo_outer);
        indices{6,3} = std(wss_mask_proxAAo_outer);
        WSS_sorted = sort(wss_mask_proxAAo_outer);
        indices{7,3} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        indices{8,3} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        indices{9,3} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        indices{10,3} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        indices{1,4} = 'distAAo_inner';
        indices{2,4} = mean(wss_mask_distAAo_inner);
        indices{3,4} = median(wss_mask_distAAo_inner);
        indices{4,4} = max(wss_mask_distAAo_inner);
        indices{5,4} = min(wss_mask_distAAo_inner);
        indices{6,4} = std(wss_mask_distAAo_inner);
        WSS_sorted = sort(wss_mask_distAAo_inner);
        indices{7,4} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        indices{8,4} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        indices{9,4} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        indices{10,4} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        indices{1,5} = 'distAAo_outer';
        indices{2,5} = mean(wss_mask_distAAo_outer);
        indices{3,5} = median(wss_mask_distAAo_outer);
        indices{4,5} = max(wss_mask_distAAo_outer);
        indices{5,5} = min(wss_mask_distAAo_outer);
        indices{6,5} = std(wss_mask_distAAo_outer);
        WSS_sorted = sort(wss_mask_distAAo_outer);
        indices{7,5} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        indices{8,5} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        indices{9,5} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        indices{10,5} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        indices{1,6} = 'arch_inner';
        indices{2,6} = mean(wss_mask_arch_inner);
        indices{3,6} = median(wss_mask_arch_inner);
        indices{4,6} = max(wss_mask_arch_inner);
        indices{5,6} = min(wss_mask_arch_inner);
        indices{6,6} = std(wss_mask_arch_inner);
        WSS_sorted = sort(wss_mask_arch_inner);
        indices{7,6} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        indices{8,6} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        indices{9,6} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        indices{10,6} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        indices{1,7} = 'arch_outer';
        indices{2,7} = mean(wss_mask_arch_outer);
        indices{3,7} = median(wss_mask_arch_outer);
        indices{4,7} = max(wss_mask_arch_outer);
        indices{5,7} = min(wss_mask_arch_outer);
        indices{6,7} = std(wss_mask_arch_outer);
        WSS_sorted = sort(wss_mask_arch_outer);
        indices{7,7} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        indices{8,7} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        indices{9,7} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        indices{10,7} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        indices{1,8} = 'proxDAo_inner';
        indices{2,8} = mean(wss_mask_proxDAo_inner);
        indices{3,8} = median(wss_mask_proxDAo_inner);
        indices{4,8} = max(wss_mask_proxDAo_inner);
        indices{5,8} = min(wss_mask_proxDAo_inner);
        indices{6,8} = std(wss_mask_proxDAo_inner);
        WSS_sorted = sort(wss_mask_proxDAo_inner);
        indices{7,8} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        indices{8,8} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        indices{9,8} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        indices{10,8} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        indices{1,9} = 'proxDAo_outer';
        indices{2,9} = mean(wss_mask_proxDAo_outer);
        indices{3,9} = median(wss_mask_proxDAo_outer);
        indices{4,9} = max(wss_mask_proxDAo_outer);
        indices{5,9} = min(wss_mask_proxDAo_outer);
        indices{6,9} = std(wss_mask_proxDAo_outer);
        WSS_sorted = sort(wss_mask_proxDAo_outer);
        indices{7,9} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        indices{8,9} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        indices{9,9} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        indices{10,9} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        indices{1,10} = 'distDAo_inner';
        indices{2,10} = mean(wss_mask_distDAo_inner);
        indices{3,10} = median(wss_mask_distDAo_inner);
        indices{4,10} = max(wss_mask_distDAo_inner);
        indices{5,10} = min(wss_mask_distDAo_inner);
        indices{6,10} = std(wss_mask_distDAo_inner);
        WSS_sorted = sort(wss_mask_distDAo_inner);
        indices{7,10} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        indices{8,10} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        indices{9,10} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        indices{10,10} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        indices{1,11} = 'distDAo_outer';
        indices{2,11} = mean(wss_mask_distDAo_outer);
        indices{3,11} = median(wss_mask_distDAo_outer);
        indices{4,11} = max(wss_mask_distDAo_outer);
        indices{5,11} = min(wss_mask_distDAo_outer);
        indices{6,11} = std(wss_mask_distDAo_outer);
        WSS_sorted = sort(wss_mask_distDAo_outer);
        indices{7,11} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        indices{8,11} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        indices{9,11} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        indices{10,11} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        currDir=pwd;
        cd(strcat(MrstructPath,'..','\regional_masks'))
        % save in an Excel sheet
        xlswrite('wss_indices.xls',indices);
        cd(currDir)
        h1 = msgbox('WSS indices were calculated and saved in the regional_masks folder');
    case 'Load existing'
        
        [FileName,MrstructPath,FilterIndex] = uigetfile(currDir,'Select the ROI you want to load');
        masks=ls(MrstructPath);
        for i=3:12
            load(strcat(MrstructPath,masks(i,:)));
            hold on, plot([region(:,1);,region(1,1)],[region(:,2);region(1,2)])
            clear region
        end
        
        load(strcat(MrstructPath,FileName));
        
        polyAAo = impoly(gca,region);
        wait(polyAAo);
        region = getPosition(polyAAo);
        disp('saving, pausing')
        save(strcat(MrstructPath,FileName),'region');
        pause
        
        mask_wss = inpolygon(V(:,1),V(:,2), region(:,1), region(:,2));
        wss_mask = wss_m(mask_wss);
        save(strcat([MrstructPath 'wss_values_new' FileName]),'wss_mask');
        
        new_indices{1,1} = mean(wss_mask);
        new_indices{2,1} = median(wss_mask);
        new_indices{3,1} = max(wss_mask);
        new_indices{4,1} = min(wss_mask);
        new_indices{5,1} = std(wss_mask);
        WSS_sorted = sort(wss_mask);
        new_indices{6,1} = mean(WSS_sorted(end-5/100*ceil(length(WSS_sorted)):end));
        new_indices{7,1} = mean(WSS_sorted(end-2/100*ceil(length(WSS_sorted)):end));
        new_indices{8,1} = mean(WSS_sorted(1:5/100*ceil(length(WSS_sorted))));
        new_indices{9,1} = mean(WSS_sorted(1:2/100*ceil(length(WSS_sorted))));
        
        currDir=pwd;
        cd(MrstructPath)
        % save in an Excel sheet
%         col = char(str2num(FileName(end-4))+'A');
        indMask = strfind(FileName, 'mask');
        indMat = strfind(FileName, '.mat');
        col = char(str2num(FileName(indMask+4:indMat-1))+'A');
        xlRange = strcat([col '2:' col '10']);
        xlswrite('wss_indices.xls',new_indices,xlRange);
        cd(currDir)
        h1 = msgbox('WSS indices in the new ROI were calculated and saved in the regional_masks folder');
        
end

function move_slice3(hObj,event,ax) % Emilie: for manual interaction to chose magnitude slice on which RPA can be visualized
	sliceobj = findobj(s4);
	delete(sliceobj)
	slice = round(get(hObj,'Value'));
	s4 = surf(1:size(magnitude,2),1:size(magnitude,1),ones([size(magnitude,1) size(magnitude,2)]).*(size(magnitude,3)-(slice-1)),magnitude(:,:,slice),'EdgeColor','none');
end

end