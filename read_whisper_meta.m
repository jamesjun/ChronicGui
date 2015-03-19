function [S] = read_whisper_meta(vcFname)
S = [];

% Read file
if nargin < 1
    [FileName,PathName,FilterIndex] = uigetfile();
    vcFname = fullfile(PathName, FileName);
    if ~FilterIndex
        return; 
    end
end

try
    %Read Meta
    fid = fopen(vcFname, 'r');
    mcFileMeta = textscan(fid, '%s%s', 'Delimiter', '=',  'ReturnOnError', false);
    fclose(fid);
    csName = mcFileMeta{1};
    csValue = mcFileMeta{2};
    S = [];
    for i=1:numel(csName)
        try 
            eval(sprintf('%s = ''%s'';', csName{i}, csValue{i}));
            eval(sprintf('num = str2double(%s);', csName{i}));
            if ~isnan(num)
                eval(sprintf('%s = num;', csName{i}));
            end
            eval(sprintf('S = setfield(S, ''%s'', %s);', csName{i}, csName{i}));
        catch, disp(lasterr); end
    end
    
%     MAGIC_CONST = 384;  % Our best guess as to why Mladen's data are off
%     ADC_bits = 16; %number of bits of ADC [was 16 in Chongxi original]
    
    %Scale data
%     scale = ((S.rangeMax-S.rangeMin)/(2^ADC_bits))/S.auxGain;  %Volts
%     scale = scale * 1e6;  % from volts to microvolts
%     mrData = (mrData - MAGIC_CONST).*scale;
catch
    disp(lasterr);
end