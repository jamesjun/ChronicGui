function [t, muadata, lfpdata, indata, filename, filesize] = read_tritrode_data(varargin)
% Read 3 channel of maladen ground truth muadata (*.abf)
% [t, muadata, indata] = read_tritrode_data
% [t, muadata, indata] = read_tritrode_data(filename)
% t: time axis
% muadata: extracellular raw recording n*nCh   [300 - 3000]Hz
% lfpdata: local field potential               [0   -  300]Hz
% indata: intracellular raw recording

% target the file, get the filename
if nargin == 0, filename = ''; 
else filename = varargin{1};
end
if isempty(filename)
    [file, path] = uigetfile('*.abf','Select a .abf file','MultiSelect', 'off');
    filename = [path,file];
end

fileinfo = dir(filename);

%  pick one file
if length(fileinfo) == 1
	filesize = fileinfo.bytes;
	d=abfload(filename);
    fs = 20000;
    dt = 1/fs;
	nPoints = size(d,1);
	t = linspace(0,nPoints*dt,nPoints)'; 
    d(t<=2,:) = [];
    t(t<=2) =[];
    for channel = [1 2 4]
        [b, a]=ellip(4, 0.1, 80, [300 3000]/(fs/2));
        muadata(:,channel) = filtfilt(b, a, d(:,channel)) * 1000; % convert to microvolts;
        [b, a]=ellip(8, 4, 80, 300/(fs/2));
        lfpdata(:,channel) = filtfilt(b, a, d(:,channel)) * 1000; % convert to microvolts;        
    end
    indata = d(:,3);
    muadata(:,3) = [];
    lfpdata(:,3) = [];
    
% a batch of files
elseif length(fileinfo) > 1
    k = 1;
    foldername = filename;
    filename = {}; filesize = 0;
    t = [];
    muadata = [];
    lfpdata =[];
    indata = [];
    fs = 20000;
    dt = 1/fs;
    for i = 1:length(fileinfo)
        if fileinfo(i).bytes > 12005376 - 10
            filesize = filesize + fileinfo(i).bytes;
			filename{k} = [foldername fileinfo(i).name];
			d = abfload(filename{k});
            fs = 20000;
            dt = 1/fs;
            nPoints = size(d,1);
            t_ = linspace(0,nPoints*dt,nPoints)'; 
% cut RC --------------------------------------------------------------------------
            d(t_<=2,:) = [];                      % get rid of the first 2 sec for every file because that is RC
%----------------------------------------------------------------------------------
            for channel = [1 2 4]
                [b, a]=ellip(4, 0.1, 80, [300 3000]/(fs/2));
                mua_d(:,channel) = filtfilt(b, a, d(:,channel)) * 1000; % convert to microvolts;
                [b, a]=ellip(8, 4, 80, 300/(fs/2));
                lfp_d(:,channel) = filtfilt(b, a, d(:,channel)) * 1000; % convert to microvolts;    
            end
            inter_connection = zeros(5,3);
			muadata = [muadata; inter_connection; mua_d(:,[1,2,4]) * 1000]; % convert to microvolts
            lfpdata = [lfpdata; inter_connection; lfp_d(:,[1,2,4]) * 1000]; % convert to microvolts
            inter_connection = zeros(5,1);
			indata = [indata; inter_connection; d(:,3)];     % convert to microvolts
            k = k + 1;
        end
    end
    nPoints = size(muadata,1);
    t = linspace(0,nPoints*dt,nPoints)';
    filename = ['folder: ' foldername];
elseif isempty(fileinfo)
    disp('wrong folder, no file has been chosen');
    return;
end

end