function plot_fit_segment(ax, seg, toDisp, showLegend)
% 1つのフィット範囲 (seg) の図示: 位相補正後の 実部・虚部・絶対値 のデータ (実線) と複素フィット (破線)、
% 各ピーク (点線)、残差 (下にずらして表示)
%   toDisp : ppm (そのスキャンのPPM軸) → 表示用PPM軸 の関数ハンドル
hold(ax, 'on');
cRe = [0.00 0.45 0.74]; cReF = [0.00 0.15 0.45];
cIm = [0.93 0.50 0.10]; cImF = [0.60 0.10 0.00];
cAb = [0.62 0.45 0.80]; cAbF = [0.40 0.10 0.55];
xd = toDisp(seg.x);
dataAbs = hypot(seg.data, seg.dataIm);   % 絶対値 (位相によらない)
plot(ax, xd, dataAbs,     '-',  'Color', cAb,  'LineWidth', 1.0, 'DisplayName', '絶対値 (データ)');
plot(ax, xd, seg.dataIm,  '-',  'Color', cIm,  'LineWidth', 1.0, 'DisplayName', '虚部 (データ)');
plot(ax, xd, seg.data,    '-',  'Color', cRe,  'LineWidth', 1.2, 'DisplayName', '実部 (データ)');
plot(ax, xd, seg.modelAbs, '--', 'Color', cAbF, 'LineWidth', 1.6, 'DisplayName', '絶対値 (複素フィット)');
plot(ax, xd, seg.modelIm,  '--', 'Color', cImF, 'LineWidth', 1.6, 'DisplayName', '虚部 (複素フィット)');
plot(ax, xd, seg.model,    '--', 'Color', cReF, 'LineWidth', 1.8, 'DisplayName', '実部 (複素フィット)');
if size(seg.peaks, 2) > 1
    h = plot(ax, xd, seg.peaks, ':', 'Color', [0.30 0.30 0.30], 'LineWidth', 1.1);
    set(h, 'HandleVisibility', 'off');
end
yAll = [dataAbs; seg.dataIm; seg.data];
span = max(yAll) - min(yAll);
plot(ax, xd, seg.data - seg.model + min(yAll) - 0.15 * span, '-', 'Color', [0.6 0.6 0.6], ...
    'LineWidth', 0.8, 'HandleVisibility', 'off');
set(ax, 'XDir', 'reverse');
xlim(ax, [min(xd), max(xd)]);
grid(ax, 'on'); box(ax, 'on');
if nargin >= 4 && showLegend
    legend(ax, 'Location', 'northwest', 'FontSize', 7);
end
end
