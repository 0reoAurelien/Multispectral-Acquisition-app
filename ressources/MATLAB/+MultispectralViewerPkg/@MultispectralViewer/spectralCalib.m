function [QMatrix, QMatrix_Color] = spectralCalib(spectralRef,spectralWlgt,pixelH,pixelW,multispecRef,appFilePath,spectralFolder)
%spectralCalib permet de caliber l'estimation spectrale à partir d'une mire
%de couleur et des spectres des patchs associés
%   spectralRef est la matrice de spectres de la mire de couleur
%   spectralWlgt est le vecteur des longueurs d'onde de ces spectres
%   pixelH est la hauteur de l'image en pixels
%   pixelH est la largeur de l'image en pixels
%   multispecRef est le cube multispectral de la mire de couleur

% functionname='heterass.m';
% functiondir=which(functionname);
% functiondir=functiondir(1:end-length(functionname));
% addpath(functiondir);

NbPatchs = size(spectralRef,2);
NbFilters = size(multispecRef,3);
% Création ou chargement de la matrice d'observations
% multispectrales U
figure(10);
displayedFalseImgCalib = zeros(pixelH,pixelW,3);
displayedFalseImgCalib(:,:,3) = multispecRef(:,:,2);
displayedFalseImgCalib(:,:,2) = multispecRef(:,:,6);
displayedFalseImgCalib(:,:,1) = multispecRef(:,:,13);
imshow(displayedFalseImgCalib);
title("Rendu RGB fausses couleurs de la mire de la calibration");


answer = questdlg('Voulez vous charger un fichier de matrices d''observation?','Chargement matrice U','Non','Oui','Non');
if strcmp(answer,'Oui')
    [FileName, Filepath] = uigetfile(appFilePath,"Selectionner le fichier de matrice d'observation Umatrix");
    load([Filepath '/' FileName]);
else
    figure(10);
    % Selection de chaque zone d'intérêt
    msginfo=msgbox('Selectionner le centre de chaque patch de couleur','Selection des zones d''intéret','help','modal');
    waitfor(msginfo);
    figure(10);
    [x_24,y_24] = ginput(NbPatchs);
    % Selection de la taille de la zone moyennée
    msginfo=msgbox('Ajuster la taille de la zone moyennée','Selection de la zone moyennée','help','modal');
    waitfor(msginfo);
    answ = 'Non';
    nb_pix_moy = 10;
    while (strcmp(answ,'Non'))
        figure(10);
        hold on;
        for i = 1 : NbPatchs
            rectangle('Position',[round(x_24(i)-nb_pix_moy) round(y_24(i)-nb_pix_moy) 2*nb_pix_moy+1 2*nb_pix_moy+1],'EdgeColor','g');
        end
        answ = questdlg('La taille de la zone moyennée est-elle valide ?', 'Taille zone moyennée','Oui','Non','Oui');
        if strcmp(answ,'Non')
            nb_pix_moy=str2double(inputdlg('Veuillez saisir la nouvelle dimension de zone','Taille de la zone',1,{num2str(nb_pix_moy)}));
        else
            answ = 'Oui';
        end
    end
    % Création de la matrice des observations
    Umatrix = zeros(NbFilters-1,NbPatchs);
    for i = 1 : NbFilters-1
        for j = 1 : NbPatchs
            zone_interet = squeeze(multispecRef(round(y_24(j)-nb_pix_moy):round(y_24(j)+nb_pix_moy),round(x_24(j)-nb_pix_moy):round(x_24(j)+nb_pix_moy),i));
            Umatrix(i,j) = mean(zone_interet,'all');
        end
    end
    close(figure(10));
    answer=questdlg('Voulez vous sauvegarder la matrice?', 'Save', 'Oui','Non','Oui');
    if strcmp(answer,'Oui')
        uisave('Umatrix',[appFilePath 'RefXXX_Umatrix.mat']);
    end
end

% Estimation de la matrice Q par mémoire hétéroassociative/SVD
% (CSC) et Vérification
QMatrix = heterass(255*Umatrix,255*spectralRef,1.2e-9,1000000);
ColorCheckerReco = QMatrix*Umatrix;
figure(11);
xnplot = ceil(sqrt(NbPatchs));
ynplot = ceil(NbPatchs/xnplot);
for i = 1 : NbPatchs
    subplot(xnplot,ynplot,i);
    plot(spectralWlgt,spectralRef(:,i),'-');
    hold on;
    plot(spectralWlgt,ColorCheckerReco(:,i),'--');
    axis([spectralWlgt(1) spectralWlgt(end) 0 1]);
    legend('Spectrum','Reco');
    title(['Patch n°' num2str(i)]);
    hold off;
end
waitfor(figure(11));

answ = questdlg('Souhaitez-vous calibrer une matrice de transformation Multispectral/RGB ?','Calib RGB', 'Oui','Non','Non');
if strcmp(answ,'Oui')
    [FileName, Filepath] = uigetfile(spectralFolder,"Selectionner le fichier de données RGB de la mire");
    load([Filepath '/' FileName]);
    QMatrix_Color = heterass(255*Umatrix,rgb,1.2e-9,1000000);
    ColorCheckerReco = QMatrix_Color*Umatrix;
    figure(12);
    subplot(2,1,1);squareColorSwatches(rgb'/255);
    subplot(2,1,2);squareColorSwatches(ColorCheckerReco');
    waitfor(figure(12));
else
    QMatrix_Color = [];
end
end

