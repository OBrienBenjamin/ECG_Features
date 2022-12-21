% % % % path
path = '/Users/benjiobrien/Desktop/example.csv';

PLOT = 0; % % % plot on (1) or off (0)

% % % DO NOT TOUCH
% % load data 
[Data] = LoadECG_csv(path);

% % % % filter
[Data] = Filter_ECG(Data);

% % find peaks
[Data] = FindPeaks_ECG(Data, 'ECG');
[Data] = FindPeaks_ECG(Data, 'Filt_ECG');

% % % % % % % % identify ECG markers
[Data] = FindMarkers_ECG(Data, 'ECG', PLOT);
[Data] = FindMarkers_ECG(Data, 'Filt_ECG', PLOT);
