function [W,e]=heterass(X,T,eta,it)
%USAGE [W,e]=heterass(X,T,eta,niter)
% calcule la matrice de poids W pour un hetero-associateur
% apres niter iterations
% I est le nombre de cellules d'entree,
% J est le nombre de cellules de sortie
% K est le nombre de stimuli
% X est la matrice I*K de stimuli
% T est la matrice J*K de reponses desirees
% eta est la constante d'apprentissage
% (valeur par defaut: .45)
% niter est le nombre d'iteration
[ni,nk]=size(X);
[nj,nkk]=size(T);
if nk~=nkk;error('X and T incompatible ');end
if nargin < 4;it=1;end
if nargin < 3;eta=.45;end

[P,d,Q]=paq(X);
l1=d(1)^2;
% svd 'compacte' de X
if (eta<0) || (eta > 2/l1);
   eta = 1 /l1;
   disp('ATTENTION');
   disp('eta trop grand (ou < 0) pour que la convergence se fasse');
   disp(['eta est change en: ',num2str(eta)]);
   disp(' ');
end;

[na,nl]=size(d);
un=ones(na,nl);
phi= (un./d).*(un- ( (un-eta*(d.^2)).^it) );
% cf formula p. 57
W=T*Q*diag(phi)*P';
% avec matlab 4.0 declarer diag(phi) comme sparse
% econimise de la memoire et du temps
if nargout > 1;% on veut l'historique d'erreur
   e=zeros(1,it);
   aa=T*Q;
   % calcul heuristique de phi
   for ii=1:it;
     phi= (un./d).*(un- ( (un-eta*(d.^2)).^ii) );
     phidel=phi.*d;
     e(ii)=sum(sum(  (aa*(diag(un-phidel)*Q')).^2 ) );
% Attention: c'est une heuristique de calcul:
%           (presque!) toujours juste...
   end;
end;
