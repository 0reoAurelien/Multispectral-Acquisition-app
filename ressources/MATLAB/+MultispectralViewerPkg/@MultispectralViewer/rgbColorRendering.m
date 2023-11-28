function rgbColorCube = rgbColorRendering(multispecCube,Qmatrix,pixelW,pixelH)
%RGBCOLORRENDERING permet de calculer le rendu en couleurs RGB a partir de
%la matrice QMatrix_color
%   Detailed explanation goes here
rgbColorCube = zeros(pixelH,pixelW,3);
f = waitbar(0,'Calcul de l''image en vraies couleur RGB en cours');
f.CloseRequestFcn = '';
for i = 1 : pixelH
    for j = 1 : pixelW
        rgbColorCube(i,j,:) = Qmatrix * squeeze(multispecCube(i,j,:));
    end
    waitbar(1/(pixelH)*i,f);
end
waitbar(1,f,'Recalage terminé');
pause(0.5);
delete(f);
end

