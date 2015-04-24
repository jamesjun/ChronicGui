%% KCluster: Wrapper of MaskedKlustaKwik
% Prerequisite:
% 1. Download, compile KlustaKwik from: http://klusta-team.github.io/klustakwik/
% 2. The wfet.py has to be in the same folder
% 3. The MaskedKlustaKwik has to be in the same folder
% Example: clu = Kcluster(fet)
% clu: n*1
% fet: n*p  n is #observation; p is #dimension of each observation


function clu = KCluster(fet)
    fJJJ = 1; %JJJ, do not clean
    
    if fJJJ
        delete FET.fet.1
        delete FET.klg.1
        delete FET.temp.clu.1
        delete FET.clu.1
    end
    
    odirectory = pwd;   % pwd is MATLAB built-in to identify current folder
    mfile = mfilename('fullpath');
    [ST,~] = dbstack('-completenames'); % gets this function's name (so you can change the name of this function and not worry)
    func_name = ST.name;    % this extra step is necessary b/c MATLAB won't evaluate length(ST.name) if KCluster called by another function
    directory = mfile(1:end - length(func_name)); 
    cd(directory);  % jump to the folder containing this function (KCluster.m)

    disp(['0. Jump to folder: ' directory]);

    disp('1. KCluster starts... KlustaKwik runs as core');

    num_fets = size(fet,2);

    % KlustaKwik will look for a file called "FET.fet.1"
    file_name = 'FET.fet.1';
    
    disp(['2. MATLAB writing fet file for KlustaKwik']);
    % open the file to write to
    fet_file = fopen(file_name, 'w');
    
    % get the right number of %f statements
    fstr = '';
    for i = 1:(num_fets - 1)
       fstr = strcat(fstr, {'%f '}); 
    end
    fstr = strcat(fstr, {'%f\n'});
    
    % print number of dimensions - a scalar
    %fprintf(fet_file, '%f\n', strcat(num2str(fet_ct),{'\n'}));
    %fprintf(fet_file, '%f\n', num2str(num_fets));
    fprintf(fet_file, '%f\n', num_fets);
    
    % t = fstr{1};
    
    % print the dimensions - a matrix
    % have to transpose it because MATLAB prints columnwise by default
    fprintf(fet_file, fstr{1}, fet');
    
    fclose(fet_file);

    % Generate 'FET.fet.1' for KlustaKwik
    %

    %save('FET','fet','nFet');
    %system(['python wfet.py FET']);
    %delete FET.mat

    % Prameters 
    % http://klusta-team.github.io/klustakwik/ for details about parameters
    % para = ['-MinClusters 15 ' ...
    % 		'-MaxClusters 35 ' ...
    % 		'-MaxPossibleClusters 100 ' ...
    % 		'-PenaltyK 0 ' ...
    % 		'-PenaltyKLogN 1 ' ...
    % 		'-Screen 0 ' ...
    % 		% '-SplitFirst 20 ' ...
    % 		% '-SplitEvery 100 ' ...
    % 		% '-UseDistributional 1 ' ...
    % 		% '-MaskStarts 300 ' ...
    % 		];
    
%   chongxi
%     params = ['-SplitEvery 10 ' ...
%             '-SplitFirst 20 ' ...
%             '-MinClusters 12 ' ...
%             '-MaxClusters 28 ' ...
%             '-MaxPossibleClusters 50 ' ...
%             '-Screen 0 ' ...
%             ];

    params = ['-SplitEvery 10 ' ...
            '-SplitFirst 20 ' ...
            '-MinClusters 12 ' ...
            '-MaxClusters 28 ' ...
            '-MaxPossibleClusters 50 ' ...
            '-Screen 0 ' ...
            '-UseDistributional 0 ' ...
            ];

%   klustakwik default: https://github.com/klusta-team/klustakwik
%     params = [' -DropLastNFeatures 1 ' ...
%         '-MaskStarts 300 ' ...
%         '-MaxPossibleClusters 500 ' ...
%         '-PenaltyK 0.0 ' ...
%         '-PenaltyKLogN 1.0 ' ...
%         '-SplitFirst 20 ' ...
%         '-SplitEvery 100 ' ...
%         '-UseDistributional 0 ' ...
%         '-Verbose 0 ' ...
%         '-Screen 0 ',];
    
    % KlustaKwik for clustering
    disp(['3. KlustaKwik is running.  This could take 5 minutes or more ...']);
    tic
    %system(['klustakwik FET 1 ' params]);
    switch lower(computer('arch'))
        case 'maci64'
            vcCmd = ['./KlustaKwik FET 1 ' params]; %KlustaKwik
        case 'win64'
            vcCmd = ['.\klustakwik FET 1 ' params];
        otherwise
            vcCmd = '';
    end
    disp(vcCmd);
    system(vcCmd);
        
    % Read back the clu
    disp('4. Clustering done, read clu from KlustaKwik');
    clu = dlmread('FET.clu.1');
    clu(1) = [];
    %nClu = length(unique(clu));
    %fprintf('   #Clu = %d\n',nClu);
    toc
    % Clean
    if ~fJJJ
        delete FET.fet.1
        delete FET.klg.1
        delete FET.temp.clu.1
        delete FET.clu.1
    end

    cd(odirectory); % jump back to original folder
    
end
% Test: show the results
% scatter(fet(:,1),fet(:,2),8,clu) 