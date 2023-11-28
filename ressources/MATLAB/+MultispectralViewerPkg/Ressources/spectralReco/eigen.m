function [U,l] = eigen(X)
% USAGE: [U,l]=eigen(X)
% Calcule les valeurs et les vecteurs propres
% d'une matrice semi positive definie X
% U est la matrice des vecteurs propres
% l est le vecteur donnant les valeurs propres
% Les vecteurs propres sont normalises: U'*U=1
% Vecteurs et valeurs propres sont ordonnes
% par ordre decroissant (chauds)
% Les valeurs propres < epsilon =.000001
% (en particulier negatives) sont considerees nulles
    epsilon=.000001;
%  tolerance pour les valeurs propres
   [U,D]=eig(X);
   D=diag(D);
%  Ordonne les valeurs et vecteurs propres
   [l,k]=sort(D);
   n=length(k);
    l=l((n+1)-(1:n));
    U=U(:,k((n+1)-(1:n)));
% garde les valeurs propres positives (tolerance=epsilon)
  pos=find(any([l';l'] > epsilon ));
  l=l(pos);
  U=U(1:n,pos);
% Normalise U
  U=U./( ones(n,1) * sqrt(sum(U.^2) ) )  ;
%end;
