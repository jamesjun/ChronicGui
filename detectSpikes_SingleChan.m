function [mrSpkWav, viSpk, thresh] = detectSpikes_SingleChan(vrWav, thresh, limSpk, nRefrac)
%no inversion. assumes that mrSpk is positive going first. computational
%optimization if no flip
% http://www.scholarpedia.org/article/Spike_sortinge
% imaxSpkWav: index of the maximum to be aligned
% mrSpk: nChan x nData
% nChanThresh: # chan to cross over the threshold
MIN_LEN = 2;

if nargin < 2, thresh = []; end
if nargin < 3, limSpk = [-1 30]; end
if nargin < 4, nRefrac = 32; end
if isempty(thresh)
    thresh = 5 * median(abs(vrWav))/0.6745;  % default methods
end
mrSpkWav = [];
viSpk = [];

vnWav = diff(vrWav < -abs(thresh));
viRise = find(vnWav > 0)+1;
viFall = find(vnWav < 0)+1;
if isempty(viRise) || isempty(viFall), return; end
    
if viRise(1) > viFall(1)
    viFall(1) = [];
end
if numel(viRise) > numel(viFall)
    viRise = viRise(1:numel(viFall));
end

% Length-based edit
vnLen = viFall - viRise; %num element should be equal
vlKill = (vnLen < MIN_LEN);
% vnLen(vlKill) = [];
% viFall(vlKill) = [];
viRise(vlKill) = [];

% refractory based edit
viKill = find(diff(viRise) < nRefrac) + 1;
% vnLen(vlKill) = [];
% viFall(vlKill) = [];
viRise(viKill) = [];

% step through spikes
nSpk = numel(viRise);
viRange = (limSpk(1):limSpk(2));
nSpkWav = numel(viRange);
mrSpkWav = zeros(nSpkWav, nSpk); %spike table
viKill = [];
for iSpk = 1:nSpk
    try
        mrSpkWav(:,iSpk) = vrWav(viRise(iSpk) + viRange);
    catch
        viKill(end+1) = iSpk;
    end
end
mrSpkWav(:,viKill) = [];
viRise(viKill) = [];
if ~isempty(viRise)
    [vpSpkVn, viSpkVn] = min(mrSpkWav); 
    viSpk = viRise + viSpkVn' + limSpk(1) - 1;
end

if size(viSpk,2) == 1 && size(viSpk,1) > 1, viSpk=viSpk'; end