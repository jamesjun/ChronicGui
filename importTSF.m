% interpolating and scaling?

function [mrWav, Sfile] = importTSF(fname, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
    'readDuration', []);

% fname = './all_cell_extracellular.tsf';
fid = fopen(fname, 'r');
header = fread(fid, 16, 'char*1=>char');
iformat = fread(fid, 1, 'int');
SampleFrequency = fread(fid, 1, 'int');
n_electrodes = fread(fid, 1, 'int');
n_vd_samples = fread(fid, 1, 'int');
vscale_HP = fread(fid, 1, 'single');
Siteloc = fread(fid, [2,56], 'int16');

if ~isempty(P.readDuration)
    readLim = ceil(SampleFrequency * P.readDuration);
    if numel(readLim) == 1
        readLim = [0, readLim];
    end
    fseek(fid, readLim(1)*2, 'bof');
    n_vd_samples = diff(readLim);
end
mrWav = fread(fid, [n_vd_samples,n_electrodes], 'int16');
fclose(fid);

Sfile = struct('header', header, 'iformat', iformat, ...
    'sRateHz', SampleFrequency, 'nChans', n_electrodes, ...
    'n_vd_samples', n_vd_samples, 'vscale_HP', vscale_HP, ...
    'Siteloc', Siteloc, 'tLoaded', n_vd_samples/SampleFrequency);

%% data structure irregularity

%% threshold bin

% 2.1 hrs

%      = struct.unpack('i',fin.read(4))[0]             #
%      = struct.unpack('i',fin.read(4))[0]     #Sample frequency, currently 10KHz
%      = struct.unpack('i',fin.read(4))[0]        #No. of electrodes, currently 8, Buzsaki H32 single shank
%      = struct.unpack('i',fin.read(4))[0]        #No. of samples (varries)
%      = struct.unpack('f',fin.read(4))[0]           #Scaling of int2 values below to save space, currently 0.1
%      = np.zeros((2*56), dtype=np.int16)              #Location of electrodes, curently tapered H32 single shank
%      = struct.unpack(str(2*56)+'h', fin.read(2*56*2)) 
%      = np.zeros((n_electrodes, n_vd_samples), dtype=np.int16)
%     #This can be loaded in single step + reshaping of np array;
%     for i in range(n_electrodes):
%         print "Loading electrode: ", i
%         ec_traces[i] = struct.unpack(str(n_vd_samples)+'h', fin.read(n_vd_samples*2)) #Data, int2 to save space
% 
% #Plot first 10000 steps from channel 0
% plt.plot(ec_traces[0][0:10000], 'r-', color='black',linewidth=1)
% plt.show()
