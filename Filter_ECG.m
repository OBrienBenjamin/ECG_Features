function [VarStruct] = Filter_ECG(VarStruct)

% % % filter
d1 = designfilt("bandpassfir", 'FilterOrder', 20, ...
    'CutoffFrequency1',0.05,'CutoffFrequency2',150, ...
    'SampleRate',500, 'StopbandAttenuation1', 40, 'StopbandAttenuation2', 60);

sig = VarStruct.ECG;
F = filtfilt(d1, sig);
VarStruct.Filt_ECG = F;

end

