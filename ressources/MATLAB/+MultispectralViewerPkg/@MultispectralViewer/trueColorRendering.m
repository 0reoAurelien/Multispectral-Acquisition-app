function trueColorCube = trueColorRendering(multispecCube,Qmatrix,spectralWvlgt,pixelW,pixelH,meanWidth,meanHeight)
%trueColorRendering permet de calculer le cube RGB de l'image
%multispectrale à partir des spectres de chaque pixel. Attention le calcul
%peut être long selon le nombre de pixels utilisés pour le moyennage local
%   multispecCube le cube multispectral initial
%   Qmatrix la matrice de liaison multispectral/spectral
%   spectralWvlgt est le vecteur des longueurs d'ondes du spectre
%   reconstruit
%   pixelW le nb de pixels en largeur
%   pixelH le nb de pixels en hauteur
%   meanWidth le nb de pixels utilisé pour le moyennage sur la largeur
%   meanHeight le nb de pixels utilisé pour le moyennage sur la hauteur

nbItWidth = pixelW/meanWidth;
nbItHeight = pixelH/meanHeight;
trueColorCube = zeros(pixelH,pixelW,3);

f = waitbar(0,'Calcul de l''image en vraies couleur RGB en cours');
f.CloseRequestFcn = '';
%f.WindowStyle = 'modal';
for i = 1 : nbItHeight
    for j = 1 : nbItWidth
        spectrum = Qmatrix * squeeze(mean(multispecCube((i-1)*meanHeight+1:i*meanHeight,(j-1)*meanWidth+1:j*meanWidth,:),[1 2]));
        XYZ = rspd2xyz(spectralWvlgt,spectrum*100);
        RGB = xyz2rgb(XYZ);
        trueColorCube((i-1)*meanHeight+1:i*meanHeight,(j-1)*meanWidth+1:j*meanWidth,1) = RGB(1);
        trueColorCube((i-1)*meanHeight+1:i*meanHeight,(j-1)*meanWidth+1:j*meanWidth,2) = RGB(2);
        trueColorCube((i-1)*meanHeight+1:i*meanHeight,(j-1)*meanWidth+1:j*meanWidth,3) = RGB(3);
    end
    waitbar(1/(nbItHeight)*i,f);
end
waitbar(1,f,'Calcul terminé');
pause(0.5);
delete(f);
end

