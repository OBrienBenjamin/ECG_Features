function [] = PlotECGFeatures(VarStruct, TYPE)
% % %  simplify var naming
sig = VarStruct.(TYPE);
time = VarStruct.Time;
fs = 1 / mean(diff(time));

% % % R, Q, S, T
R = VarStruct.R.(TYPE);
Q = VarStruct.Q.(TYPE);
S = VarStruct.S.(TYPE);
T = VarStruct.T.(TYPE);
Z = []; for i = 1:length(sig); Z = [Z, 0]; end;
figure()
plot(sig, 'b');
hold on
plot(Z,'k:', 'LineWidth', 2);
hold on
for l = 1:length(R.Peak)
    plot(round(R.PeakTime(l)*fs), R.Peak(l), 'kx', 'MarkerSize', 10);
    hold on
    plot([round(R.PeakTime(l)*fs) round(R.PeakTime(l)*fs)], [0 R.Peak(l)], 'k:', 'LineWidth', 2)
    hold on
    if Q.Flag(l) == 1
        plot(round(Q.StartTime(l)*fs), Q.Start(l), 'ro', 'MarkerSize', 10);
        hold on
        plot(round(Q.MinTime(l)*fs), Q.Min(l), 'r*', 'MarkerSize', 10);
        hold on
        plot(round(Q.EndTime(l)*fs), Q.End(l), 'ro', 'MarkerSize', 10);
        hold on
        
    end
    if S.Flag(l) == 1
        plot(round(S.StartTime(l)*fs), S.Start(l), 'go', 'MarkerSize', 10);
        hold on
        plot(round(S.MinTime(l)*fs), S.Min(l), 'g*', 'MarkerSize', 10);
        hold on
        plot(round(S.EndTime(l)*fs), S.End(l), 'go', 'MarkerSize', 10);
        hold on
        plot([round(S.MinTime(l)*fs) round(S.MinTime(l)*fs)], [0 S.Min(l)], 'k:', 'LineWidth', 2)
        hold on
    end
    if T.Flag(l) == 1
        plot(round(T.StartTime(l)*fs), T.Start(l), 'co', 'MarkerSize', 10);
        hold on
        plot(round(T.PeakTime(l)*fs), T.Peak(l), 'c*', 'MarkerSize', 10);
        hold on
        plot(round(T.EndTime(l)*fs), T.End(l), 'co', 'MarkerSize', 10);
        hold on
        plot([round(T.PeakTime(l)*fs) round(T.PeakTime(l)*fs)], [0 T.Peak(l)], 'k:', 'LineWidth', 2)
        hold on
    end
end
grid on
xlabel('Time (samples)'); ylabel('V');
set(gca, 'FontSize', 16)

if ~isempty(name)
    title([name, '*', phase, '*', type, '*', num2str(seg)]);
else
    title([phase, '*', type, '*', num2str(seg)]);
end
hold off

end