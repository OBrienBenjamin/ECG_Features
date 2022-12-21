function [VarStruct] = FindPeaks_ECG(VarStruct, TYPE)
Fs = 1000; % % % sampling rate
maxi = 0.5 / Fs; % % % maximum peak height
mini = 0.2; % % % minimum window size
val = 0.35 / Fs; % % % minimum window size

sig = VarStruct.(TYPE);

% % % find R peaks
[R, Rlocs, ~, ~] = findpeaks(sig, Fs, 'MinPeakHeight', maxi, 'MinPeakDistance', val);
VarStruct.R.(TYPE).Peaks = R;
VarStruct.R.(TYPE).Times = Rlocs;

% % % find Q
Q = []; Qlocs = []; Qflag = [];
for l = 1:length(R)
    % % % check that there is enough signal
    LLIMIT = Rlocs(l) - mini;
    mloc = NaN; Q_VAL = NaN; Q_LOC = NaN; QF = 0;
    if 1 <= LLIMIT * Fs
        for m = Rlocs(l):-0.001:(Rlocs(l)-mini)
            id = round(m * Fs);
            if sig(id) > sig(id+1)
                mloc = id;
                break
            end
        end
        if ~isnan(mloc)
            for m = mloc:-1:1
                if sig(m) < sig(m+1)
                    Q_VAL = sig(m);
                    Q_LOC = m / Fs;
                    QF = 1;
                    break
                end
            end
        end
    end
    Q = [Q, Q_VAL];
    Qlocs = [Qlocs, Q_LOC];
    Qflag = [Qflag, QF];
end
VarStruct.Q.(TYPE).Peaks = Q;
VarStruct.Q.(TYPE).Times = Qlocs;
VarStruct.Q.(TYPE).Flags = Qflag;

% % % find S
S = []; Slocs = []; Sflag = [];
for l = 1:length(R)
    % % % check that there is enough signal
    ULIMIT = Rlocs(l) + mini;
    mloc = NaN; S_VAL = NaN; S_LOC = NaN; SF = 0;
    if length(sig) >= ULIMIT * Fs
        for m = (Rlocs(l)+0.001):0.001:(Rlocs(l)+mini)
            id = round(m * Fs);
            if sig(id) < sig(id+1)
                mloc = id;
                break
            end
        end
        if ~isnan(mloc)
            for m = mloc:(length(sig)-1)
                if sig(m) > sig(m+1)
                    S_VAL = sig(m);
                    S_LOC = m / Fs;
                    SF = 1;
                    break
                end
            end
        end
    end
    
    S = [S, S_VAL];
    Slocs = [Slocs, S_LOC];
    Sflag = [Sflag, SF];
end
VarStruct.S.(TYPE).Peaks = S;
VarStruct.S.(TYPE).Times = Slocs;
VarStruct.S.(TYPE).Flags = Sflag;

end

