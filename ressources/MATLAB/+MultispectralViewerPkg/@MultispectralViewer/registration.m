function outputCube = registration(nbFilters,inputCube)
%registration permet de recaler les images par algorithmes de corrélation
%et d'identification de points clés de la photo.
%   Utilisation de l'identification de points de control à l'aide de OpenSurf.
%   En cas de grosses difficultés de recalage, il peut être intéressant
%   d'effectuer un prétraitement du cube d'image avec ImageJ.
%   NbFilters = nombre de filtres sur la roue
%   inputCube = le cube à recaler

% functionname='OpenSurf.m';
% functiondir=which(functionname);
% functiondir=functiondir(1:end-length(functionname));
% addpath([functiondir '/WarpFunctions'])
% addpath([functiondir '/SubFunctions'])

outputCube = inputCube;


Options.upright = false();
Options.tresh = 0.0002;
Options.octaves = 5;
Options.init_sample = 2;
nb_pts_control = 30;

f = waitbar(0,'Recalage en cours');
for i = 1 : (nbFilters-1)
    booleanControlPointsValid = false();
    fixed = adapthisteq(inputCube(:,:,16));
    moving=imhistmatch(inputCube(:,:,i),fixed);
    
    while ~booleanControlPointsValid
        answer = questdlg('Souhaitez-vous sélectionner les points d''intérêt à la main ?','Points à la main?','Oui','Non','Non');
        if strcmp(answer,'Oui')
            booleanManualControlPoints = true();
        else
            booleanManualControlPoints = false();
        end
        if booleanManualControlPoints
            [selectedMovingPoints,selectedFixedPoints] = cpselect(moving,fixed,'Wait',true);
%             answer = questdlg('Souhaitez-vous ajuster les points d''intérêt par autocorrélation ?','Autocorrélation','Oui','Non','Non');
%             if strcmp(answer,'Oui')
%                 
%             end
            selectedMovingPoints = cpcorr(selectedMovingPoints,selectedFixedPoints,moving,fixed);
            Pos1 = [selectedMovingPoints(:,2) selectedMovingPoints(:,1)  ones(size(selectedMovingPoints,1),1)];
            Pos2 = [selectedFixedPoints(:,2) selectedFixedPoints(:,1) ones(size(selectedFixedPoints,1),1)];
        else
            % Parametrer l'identification
            prompts = {'"Non-rotation invariant result" (0 ou 1): ', 'Seuil (défaut = 0.0002) :', 'Nombre d''octaves à analyser (<=5) : ', 'Sous-échantillonnage (<=2) : ', 'Nombre de points de control max (<=30) : '};
            dlgTitle = 'Paramètres d''optimisation';
            dims = 1;
            defInput = {num2str(Options.upright), num2str(Options.tresh), num2str(Options.octaves), num2str(Options.init_sample), num2str(nb_pts_control)};
            answer = inputdlg(prompts,dlgTitle,dims,defInput);
            Options.upright = logical(str2double(answer{1}));
            Options.tresh = str2double(answer{2});
            Options.octaves = str2double(answer{3});
            Options.init_sample = str2double(answer{4});
            nb_pts_control = str2double(answer{5});
            
            % Get the Key Points
            Ipts1=OpenSurf(moving,Options);
            Ipts2=OpenSurf(fixed,Options);
            % Put the landmark descriptors in a matrix
            D1 = reshape([Ipts1.descriptor],64,[]);
            D2 = reshape([Ipts2.descriptor],64,[]);
            
            % Find the best matches
            err=zeros(1,length(Ipts1));
            cor1=1:length(Ipts1);
            cor2=zeros(1,length(Ipts1));
            for k=1:length(Ipts1)
                distance=sum((D2-repmat(D1(:,k),[1 length(Ipts2)])).^2,1);
                [err(k),cor2(k)]=min(distance);
            end
            
            % Sort matches on vector distance
            [err, ind]=sort(err);
            cor1=cor1(ind);
            cor2=cor2(ind);
            
            % Make vectors with the coordinates of the best matches
            Pos1=[[Ipts1(cor1).y]',[Ipts1(cor1).x]'];
            Pos2=[[Ipts2(cor2).y]',[Ipts2(cor2).x]'];
            if size(Pos1,1)<size(Pos2,1)
                maxpoints = size(Pos1,1);
            else
                maxpoints = size(Pos1,1);
            end
            if nb_pts_control > maxpoints
                nb_pts_control = maxpoints;
            end
            Pos1=Pos1(1:nb_pts_control,:);
            Pos2=Pos2(1:nb_pts_control,:);
            Pos1(:,3)=1; Pos2(:,3)=1;
        end
        % Show both images
        I = zeros([size(moving,1) size(moving,2)*2 size(moving,3)]);
        I(:,1:size(moving,2),:)=moving; I(:,size(moving,2)+1:size(moving,2)+size(fixed,2),:)=fixed;
        h=figure();
        imshow(I); hold on;
        
        % Show the best matches
        plot([Pos1(:,2) Pos2(:,2)+size(moving,2)]',[Pos1(:,1) Pos2(:,1)]','-');
        plot([Pos1(:,2) Pos2(:,2)+size(moving,2)]',[Pos1(:,1) Pos2(:,1)]','o');
        
        answer = questdlg('La selection de points de contrôle est elle satisfaisante ?','Points ok?','Oui','Non','Non');
        if strcmp(answer,'Oui')
            booleanControlPointsValid = true();
        end
        close(h);
    end
    % Warp the image
    M=Pos1'/Pos2';
    outputCube(:,:,i)=affine_warp(inputCube(:,:,i),M,4);
    waitbar(1/(nbFilters-1)*i,f);
end
waitbar(1,f,'Calcul terminé');
pause(0.5);
delete(f);
end

