function [VarStruct] = LoadECG_csv(path)
fprintf('\tLoading ECG data . . . \n');
Time = []; ECG = [];
fid = fopen(path);
tline = fgetl(fid);
while ~feof(fid)
    tline = fgetl(fid);
    d = strsplit(tline, ',');
    Time = [Time, str2num(d{1})];
    ECG = [ECG, str2num(d{2})];
end
fclose(fid);
VarStruct.Time = Time;
VarStruct.ECG = ECG;

end