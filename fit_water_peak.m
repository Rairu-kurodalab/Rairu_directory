function [wpk, wseg] = fit_water_peak(w, cplx)
% 水ピーク (水抑制なし / refscan のスキャン w: スペクトル全体の最大値の付近) の複素フィット
% 返り値の ppm は w のPPM軸の値。wseg は図示用
noiseW = max(w.ppm) - [2.0, 0.2];
[~, i] = max(abs(w.spec));
c0 = w.ppm(i);
[wpk, wseg] = fit_complex_peaks(w.ppm, w.spec, c0 + cplx.locWin * [-1 1], c0, cplx.waterMargin, cplx.waterMaxHW, noiseW);
end
