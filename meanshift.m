%% meanshift: meanshift call python
function [clu] = meanshift(fet)

odirectory = pwd;
directory = './';
py = [directory 'meanshiftPy.py'];
fetfile = [directory 'fet.mat']; 
clufile = [directory 'clu.mat'];
save(fetfile,'fet', '-v7');
% python = '/Users/Chongxi/Library/Enthought/Canopy_64bit/User/bin/python ';
python = 'python ';
cmd = sprintf('%s \"%s\" \"%s\" \"%s\"', python, py, fetfile, clufile);
disp(cmd);
system(cmd);
load(clufile);


%% getDirectory: get the current directory
function [directory] = getDirectory()
mfile = mfilename('fullpath');
caller = dbstack(1);
caller_func_name = caller.name;
directory = mfile(1:end - length(caller_func_name));
