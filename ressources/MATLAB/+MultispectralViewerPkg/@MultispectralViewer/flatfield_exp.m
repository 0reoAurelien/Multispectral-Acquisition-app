function corrected = flatfield_exp(acqui,white,black)
%flatfield_exp réalise une correction flatfield à partir de données
%expérimentales de bruit de fond et de fond blanc
%   acqui est le cube des acquisitions brutes
%   white est le cube des acquisitions de fond blanc
%   black est le cube des acquisitions du bruit de fond
c = mean(white - black,'all');
corrected = c*((acqui - black)./(white -black));
end

