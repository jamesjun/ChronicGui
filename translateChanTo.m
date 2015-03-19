function viChanTo = translateChanTo(vcChanTo, viChanFrom, vcChanFrom)
% translateChan(vcChanTo, viChanFrom, offsetWhisper)
%[input]
%   vcChanTo: {'imecii', 'whisper0', 'whisper1', 'nlx'}: vector of characters(vc...)
%   vcChanFrom: {'whisper0', 'whisper1', imecii, 'nanozeven', 'nanozodd', 'nlx'};
%   viChanFrom: channel numbers: vector of indicies (vi...)
%   fZero = ~vcChanFrom if vcChanFrom is logical and default is 
%   Created by James Jun, Janelia, APIG, 2014 Nov 3, junj10@janelia.hhmi.org

% Parse input
if nargin < 3, vcChanFrom = 1; end
if isnumeric(vcChanFrom)
    fZero = (vcChanFrom == 0); 
    %infer vcChanFrom
    switch lower(vcChanTo)
        case {'hires', 'tpa', 'pedot', 'imec', 'imecii'}
            vcChanFrom = sprintf('whisper%d', 1-fZero);
        case 'whisper'
            vcChanFrom = 'imecii';
            vcChanTo = sprintf('whisper%d', 1-fZero);
        case {'whisper0', 'whisper1'}
            vcChanFrom = 'imecii';
        case {'nanozeven', 'nanozodd'}
            vcChanFrom = 'imecii';
    end
elseif strcmpi(vcChanFrom, 'whisper')
    vcChanFrom = 'whisper1';
end

% Determine fZero flag
if strcmpi(vcChanTo, 'whisper0'), fZero = 1; end
if strcmpi(vcChanTo, 'whisper1'), fZero = 0; end 
if strcmpi(vcChanFrom, 'whisper0'), fZero = 1; end
if strcmpi(vcChanFrom, 'whisper1'), fZero = 0; end

nChan = 128;

viImecii_to_Whisper1 = 1 + [ ...
40 103 39	104	41	102	38	105	42	101	37	106	43	100	36	107 ...
44	99	35	108	45	98	34	109	46	97	33	110	47	96	32	111 ...
48	127	63	112	49	126	62	113	50	125	61	114	51	124	60	115	...
52	116	59	123	53	117	58	122	54	118	57	121	55	119	56	120	...
8	71	7	72	9	70	6	73	10	74	5	69	11	75	4	68 ...	
12	76	3	67	13	77	2	66	14	78	1	65	15	79	0	64 ...	
16	80	31	95	17	81	30	94	18	82	29	93	19	83	28	92 ...	
20	84	27	91	21	85	26	90	22	86	25	89	23	87	24	88];
viWhisper1_to_Imecii = zeros(1, nChan); %reverse routing table
viWhisper1_to_Imecii(viImecii_to_Whisper1) = 1:nChan;
                
viNanozEven_to_Imecii = [ ...
4     2     8     6    12    16    10    14    20    24    18    26    28    32    22    30 ...
68    66    72    70    74    78    76    82    84    90    88    80    92    94    96    86 ...
106   100    98   104   116   108   102   112   110   120   114   118   124   122   128   126 ...
34    42    36    40    38    46    44    48    52    56    50    54    60    58    64    62];
viNanozOdd_to_Imecii = [ ...
1     3     5     7     9    13    11    15    17    21    19    27    25    29    23    31 ...
65    67    69    71    73    77    75    81    83    89    87    79    91    93    95    85 ...
105    99    97   103   115   107   101   111   109   119   113   117   123   121   127   125 ...
35    43    33    37    39    47    41    45    51    55    49    53    59    57    63    61];
viImecii_to_Nanoz = zeros(1, nChan); %reverse routing table
viImecii_to_Nanoz(viNanozEven_to_Imecii) = 1:64;
viImecii_to_Nanoz(viNanozOdd_to_Imecii) = 1:64;

viHires_to_Whisper1 = 1 + [...
   54 57 55 56 52 59 53 58 51 61 50 60 49 63 48 62 ...
   9 6 8 7 11 4 10 5 12 2 13 3 14 0 15 1 ...
   25 22 24 23 27 20 26 21 29 19 28 18 31 17 30 16 ...
   38 41 39 40 36 43 37 42 34 44 35 45 32 46 33 47];
viWhisper1_to_Hires = zeros(1, 64); %reverse routing table
viWhisper1_to_Hires(viHires_to_Whisper1) = 1:64;

viPedot_to_Whisper1 = 1 + [...
   16 31 17 30 18 29 26 19 22 28 25 20 23 27 24 21 ...
   5 11 2 4 14 12 1 3 15 13 0  nan nan nan nan nan ...
   45 33 46 32 47 63 60 48 51 62 59 49 52 61 58 50 ...
   39 40 36 38 43 41 35 37 44 42 34 nan nan nan nan nan];
viWhisper1_to_Pedot = zeros(1, 64); %reverse routing table
viSelect = find(~isnan(viPedot_to_Whisper1));
viPedot = 1:64;
viWhisper1_to_Pedot(viPedot_to_Whisper1(viSelect)) = viPedot(viSelect);

viImec_to_Whisper1 = 1 + [...
   24 25 26 27 28 29 3 30 4 31 5 0 6 1 7 2 ...
   22 21 16 20 15 19 14 18 13 17 12 nan nan nan nan nan...
   35 36 37 38 39 51 45 50 44 49 43 48 42 47 41 46 ...
   56 57 62 58 63 59 32 60 33 61 34 nan nan nan nan nan];
viWhisper1_to_Imec = zeros(1, 64); %reverse routing table
viSelect = find(~isnan(viImec_to_Whisper1));
viImec = 1:64;
viWhisper1_to_Imec(viImec_to_Whisper1(viSelect)) = viImec(viSelect);

viTpa_to_Whisper1 = 1 + [...
   18 20 19 22 17 21 16 23 ...
   24 28 31 30 25 29 27 26 ...
   5 4 2 6 1 0 3 7 ...
   8 14 10 15 9 12 11 13];
nChan = numel(viTpa_to_Whisper1);
viWhisper1_to_Tpa = zeros(1, nChan); %reverse routing table
viWhisper1_to_Tpa(viTpa_to_Whisper1) = 1:nChan;

%neuralynx
viNlx_to_Whisper1 = 1 + [ ...
2 7 1 6 0 5 31 4 30 3 29 28 27 26 25 24 ...
12 17 13 18 14 19 15 20 16 21 22 23 8 9 10 11 ...
46 41 47 42 48 43 49 44 50 45 51 39 38 37 36 35 ...
34 61 33 60 32 59 63 58 62 57 56 40 52 53 54 55];
nChan = numel(viNlx_to_Whisper1);
viWhisper1_to_Nlx = zeros(1, nChan); %reverse routing table
viWhisper1_to_Nlx(viNlx_to_Whisper1) = 1:nChan;

try
    fError = 0;
    switch lower(vcChanTo)
        case {'whisper0', 'whisper1'}
            switch lower(vcChanFrom)
                case {'imecii', 'whisper1'} %default param
                    viChanTo = viImecii_to_Whisper1(viChanFrom) - fZero;
                case 'nanozeven'
                    viChanTo = viImecii_to_Whisper1(viNanozEven_to_Imecii(viChanFrom)) - fZero;
                case 'nanozodd'
                    viChanTo = viImecii_to_Whisper1(viNanozOdd_to_Imecii(viChanFrom)) - fZero;
                case 'hires'
                    viChanTo = viHires_to_Whisper1(viChanFrom) - fZero;
                case 'tpa'
                    viChanTo = viTpa_to_Whisper1(viChanFrom) - fZero;
                case 'pedot'
                    viChanTo = viPedot_to_Whisper1(viChanFrom) - fZero;
                case 'imec'
                    viChanTo = viImec_to_Whisper1(viChanFrom) - fZero;
                case 'nlx'
                    viChanTo = viNlx_to_Whisper1(viChanFrom) - fZero;
                otherwise
                    fError = 1;
            end
        case 'imecii' %inverse lookup
            switch lower(vcChanFrom)
                case {'whisper0', 'whisper1'}
                    viChanTo = viWhisper1_to_Imecii(viChanFrom + fZero);          
                case 'nanozeven'
                    viChanTo = viNanozEven_to_Imecii(viChanFrom);
                case 'nanozodd'
                    viChanTo = viNanozOdd_to_Imecii(viChanFrom);
                otherwise
                    fError = 1;
            end

        case {'nanozeven', 'nanozodd', 'nanoz'}
            switch lower(vcChanFrom)
                case {'imec', 'imecii'} %default param
                    viChanTo = viImecii_to_Nanoz(viChanFrom);
                case {'whisper0', 'whisper1'}
                    viChanTo = viImecii_to_Nanoz(viWhisper1_to_Imecii(viChanFrom + fZero));
                otherwise
                    fError = 1; % vcChanFrom error
            end

        case 'hires'
            switch lower(vcChanFrom)
                case {'whisper0', 'whisper1'}
                    viChanTo = viWhisper1_to_Hires(viChanFrom + fZero);
                otherwise
                    fError = 1; % vcChanFrom error
            end

        case 'tpa'
            switch lower(vcChanFrom)
                case {'whisper0', 'whisper1'}
                    viChanTo = viWhisper1_to_Tpa(viChanFrom + fZero);
                otherwise
                    fError = 1; % vcChanFrom error
            end

        case 'pedot'
            switch lower(vcChanFrom)
                case {'whisper0', 'whisper1'}
                    viChanTo = viWhisper1_to_Pedot(viChanFrom + fZero);
                otherwise
                    fError = 1; % vcChanFrom error
            end

        case 'imec'
            switch lower(vcChanFrom)
                case {'whisper0', 'whisper1'}
                    viChanTo = viWhisper1_to_Imec(viChanFrom + fZero);
                otherwise
                    fError = 1; % vcChanFrom error
            end
            
        case 'nlx'
            switch lower(vcChanFrom)
                case {'whisper0', 'whisper1'}
                    viChanTo = viWhisper1_to_Nlx(viChanFrom + fZero);
                otherwise
                    fError = 1; % vcChanFrom error
            end
            
        otherwise
            fError = 2; % vcChanTo error
    end
catch
    fError = 3;
    viChanTo = [];
end

switch fError
    case 1
        error('translateChanTo: unknown type for vcChanFrom: %s', vcChanFrom);
    case 2
        error('translateChanTo: unknown type for vcChanTo: %s', vcChanTo);
    case 3
        error('translateChanTo: invalud channel number');
end