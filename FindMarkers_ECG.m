function [VarStruct] = FindMarkers_ECG(VarStruct, TYPE, PLOT)

FEAT = {'Start', 'Min', 'End'};
TFEAT = {'Start', 'Peak', 'End'};

sig = VarStruct.(TYPE);

TIME = VarStruct.Time;
FS = 1 / mean(diff(TIME));

SAMP.FS = FS;
SAMP.MAX = 0.5 / 1000;
SAMP.MIN = 0.2;
SAMP.WIN = 0.35 / 1000;

% % % find R peaks
[R, Rlocs, ~, ~] = findpeaks(sig, SAMP.FS, 'MinPeakHeight', SAMP.MAX, 'MinPeakDistance', SAMP.WIN);
VarStruct.R.(TYPE).Peak = R;
VarStruct.R.(TYPE).PeakTime = Rlocs;
VarStruct.R.(TYPE).Flag = [];
for l = 1:length(R)
    VarStruct.R.(TYPE).Flag = [VarStruct.R.(TYPE).Flag, 1];
end

% % % find Q
[Q] = FindQFeatures(sig, R, Rlocs, SAMP);

VarStruct.Q.(TYPE).Flag = Q.Flag;
for l = 1:length(FEAT)
    VarStruct.Q.(TYPE).(FEAT{l}) = Q.(FEAT{l});
    VarStruct.Q.(TYPE).([FEAT{l}, 'Time']) = Q.([FEAT{l},'Time']);
end

% % % find S
[S] = FindSFeatures(sig, R, Rlocs, SAMP);

VarStruct.S.(TYPE).Flag = S.Flag;
for l = 1:length(FEAT)
    VarStruct.S.(TYPE).(FEAT{l}) = S.(FEAT{l});
    VarStruct.S.(TYPE).([FEAT{l}, 'Time']) = S.([FEAT{l},'Time']);
end

% % % find T
[T] = FindTFeatures(sig, S, SAMP);
VarStruct.T.(TYPE).Flag = T.Flag;
for l = 1:length(TFEAT)
    VarStruct.T.(TYPE).(TFEAT{l}) = T.(TFEAT{l});
    VarStruct.T.(TYPE).([TFEAT{l}, 'Time']) = T.([TFEAT{l},'Time']);
end

if PLOT
    PlotECGFeatures(VarStruct, TYPE);
end

end

function [Q] = FindQFeatures(sig, R, Rlocs, Samp)
Q = []; FEAT = {'Start', 'Min', 'End'};
Q.Flag = [];
for l = 1:length(FEAT); Q.(FEAT{l}) = [];  Q.([FEAT{l}, 'Time']) = [];end
for l = 1:length(R)
    % % % check that there is enough signal
    start = round(Rlocs(l) * Samp.FS);
    win = round(Samp.MIN * Samp.FS);
    mloc = NaN; QFLAG = 0;
    QMIN = NaN; QMINLOC = NaN; QSTART = NaN; QSTARTLOC = NaN; QEND = NaN; QENDLOC = NaN;
    if (start - win) >= 1
        % % % find minimum
        for m = start:-1:(start - win)
            if sig(m) > sig(m+1)
                mloc = m;
                break
            end
        end
        % % % if minimum exists, . . .
        if ~isnan(mloc)
            % % % set minimum
            QFLAG = 1;
            QMIN = sig(mloc);
            QMINLOC = mloc / Samp.FS;
            
            % % % find start
            for m = mloc:-1:1
                if sig(m) < sig(m+1)
                    QSTART = sig(m);
                    QSTARTLOC = m / Samp.FS;
                    break
                end
            end
            
            % % % find end
            for m = mloc:length(sig)
                if sig(m) >= QSTART
                    QEND = sig(m);
                    QENDLOC = m / Samp.FS;
                    break
                end
            end
        end
    end
    Q.Flag = [Q.Flag, QFLAG];
    Q.Start = [Q.Start, QSTART];
    Q.StartTime = [Q.StartTime, QSTARTLOC];
    Q.Min = [Q.Min, QMIN];
    Q.MinTime = [Q.MinTime, QMINLOC];
    Q.End = [Q.End, QEND];
    Q.EndTime = [Q.EndTime, QENDLOC];
end

end

function [S] = FindSFeatures(sig, R, Rlocs, Samp)
S = []; FEAT = {'Start', 'Min', 'End'};
S.Flag = [];
for l = 1:length(FEAT); S.(FEAT{l}) = [];  S.([FEAT{l}, 'Time']) = [];end
for l = 1:length(R)
    % % % check that there is enough signal
    start = round(Rlocs(l) * Samp.FS) + 1;
    SFLAG = 0;
    SSTART = NaN; SSTARTLOC = NaN; SMIN = NaN; SMINLOC = NaN; SEND = NaN; SENDLOC = NaN;
    
    % % % find start
    for m = start+1:length(sig)
        if sig(m) <= 0
            SSTART = sig(m);
            SSTARTLOC = m / Samp.FS;
            s_start = m;
            break
        end
    end
    
    % % % find end
    for m = s_start+1:length(sig)
        if sig(m) >= 0
            SFLAG = 1;
            SEND = sig(m);
            SENDLOC = m / Samp.FS;
            s_fini = m;
            break
        end
    end
    
    % % % find peak
    if ~isnan(SEND)
        [SMIN, SMINLOC] = findpeaks(-1*sig(s_start:s_fini));
        [M, I] = max(SMIN);
        SMIN = -1*M;
        SMINLOC = (s_start + SMINLOC(I)) / Samp.FS;
    end
    
    S.Flag = [S.Flag, SFLAG];
    S.Start = [S.Start, SSTART];
    S.StartTime = [S.StartTime, SSTARTLOC];
    S.Min = [S.Min, SMIN];
    S.MinTime = [S.MinTime, SMINLOC];
    S.End = [S.End, SEND];
    S.EndTime = [S.EndTime, SENDLOC];
end

end

function [T] = FindTFeatures(sig, S, Samp)
WIN = round(Samp.MIN * Samp.FS); % % % sample domain
T = []; FEAT = {'Start', 'Peak', 'End'};
T.Flag = [];
for l = 1:length(FEAT); T.(FEAT{l}) = [];  T.([FEAT{l}, 'Time']) = [];end
for l = 1:length(S.Flag)
    if S.Flag(l) && ~isnan(S.End(l))
        % % % set T start time to S end time
        TSTART = S.End(l); TSTARTLOC = S.EndTime(l); TFLAG = 1;
        TPEAK = NaN; TPEAKLOC = NaN; TEND = NaN; TENDLOC = NaN;
        
        % % % find peak
        start = round(TSTARTLOC * Samp.FS);
        if (start + WIN) > length(sig); WIN = length(sig) - start; end
        if WIN > 3 % % % can't find a peak without 3 points
            [PEAKS, LOCS] = findpeaks(sig(start:start+WIN));
            [M, I] = max(PEAKS);
            if ~isempty(M)
                TPEAK = M;
                TPEAKLOC = (start + LOCS(I)) / Samp.FS;
                
                % % % find end;
                peak = round(TPEAKLOC * Samp.FS);
                for m = peak:length(sig)
                    if sig(m) <= 0
                        TEND = sig(m);
                        TENDLOC = m / Samp.FS;
                        break
                    end
                end
                
                % % % check peak
                [PEAKS, LOCS] = findpeaks(sig(start:m));
                [M, I] = max(PEAKS);
                if M > TPEAK;
                    TPEAK = M;
                    TPEAKLOC = (start + LOCS(I)) / Samp.FS;
                end
            else
                TFLAG = 0;
            end
        else
            TFLAG = 0;
        end
    else
        TFLAG = 0; TSTART = NaN; TSTARTLOC = NaN;
        TPEAK = NaN; TPEAKLOC = NaN; TEND = NaN; TENDLOC = NaN;
    end
    T.Flag = [T.Flag, TFLAG];
    T.Start = [T.Start, TSTART];
    T.StartTime = [T.StartTime, TSTARTLOC];
    T.Peak = [T.Peak, TPEAK];
    T.PeakTime = [T.PeakTime, TPEAKLOC];
    T.End = [T.End, TEND];
    T.EndTime = [T.EndTime, TENDLOC];
end
end
