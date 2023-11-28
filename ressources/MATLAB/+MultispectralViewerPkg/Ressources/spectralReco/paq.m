function [P,a,Q]=paq(X,k)
%USAGE [P,a,Q]=paq(X,k);
% Decomposition (d'ordre k) en valeurs singuliere de la
% matrice X d'ordre I par J
% si k est absent alors k=min{I,J}
% si k est < min{I,J}, k=min{I,J}
% soit K le nombre de valeurs singulieres,
%  si k est > K alors k=K
% les vecteurs propres et valeurs singulieres
% sont ordonnees par ordre decroissants (chauds)
% P est la matrice de vecteurs propres de X'*X
% Q est la matrice de vecteurs propres de X*X'
% a est le vecteur de valeurs singulieres
% NOTE  a = sqrt(lambda)
% avec lambda etant les valeurs propres de X'* X et X*X'
%
[I,J]=size(X);
m=min(I,J);
if nargin==1 
   k=m;
	else if k > m
      k=m
   end
end
flip=0;
if I < J
   X=X';flip=1;
end
[Q,a]=eigen(X'*X);
l= max(size(a)); if k > l, k=l;end;
Q=Q(:,1:k);
a=a(1:k);
a=sqrt(a);
P=X*Q*inv(diag(a));
if flip==1,X=X';
   bidon=Q;Q=P;P=bidon;
end

% and that should be it !
