function sp = load_spectrum_ecc(folder, LB, eccMode)
% FID-A で読み込み → コイル結合 → 平均化 → (渦電流補正) → LB → 複素スペクトル
% (FID-A の警告表示を抑えるため evalc で実行)
%   eccMode = 'refscan' : fid.refscan の位相で渦電流補正 (Klose 法; ParaVision の Edc と同じ)
%   eccMode = 'none'    : 補正なし
[~, raw, ref] = evalc('io_loadspec_bruk(folder)');   % ref: 同じフォルダの fid.refscan (無ければ [])
[~, raw] = evalc('op_addrcvrs(raw, 1, ''w'')');
[~, raw] = evalc('op_averaging(raw)');
sp.refFid  = [];
sp.refSpec = [];
if strcmp(eccMode, 'refscan')
    % refscan (同じボクセル・同じシーケンスの水抑制なしの信号) の各時刻の位相を FID から引く。
    % 読み出し中の周波数の揺れ (渦電流) は水と代謝物に同じだけ加わるので、これで打ち消される。
    % 同時に refscan の水の周波数が基準 (スペクトルの中心) になり、各ピークは
    % 「refscan の水からの周波数差」の位置に出る (送信周波数からのずれではなくなる)
    if isempty(ref)
        error('fid.refscan がありません (eccMode = ''none'' なら読み込めます)');
    end
    rf = mean(ref.fids, 2);
    if numel(rf) ~= size(raw.fids, 1) || size(raw.fids, 2) ~= 1
        error('fid.refscan と rawdata の点数が合いません (eccMode = ''none'' なら読み込めます)');
    end
    ph = angle(rf);
    raw.fids  = raw.fids .* exp(-1i * ph);
    raw.specs = fftshift(ifft(raw.fids, [], 1), 1);
    sp.refFid  = rf;
    sp.refSpec = fftshift(ifft(abs(rf) .* exp(-pi * LB * raw.t(:))));   % ECC 後の refscan (= |FID|) に同じ LB
end
raw = op_filter(raw, LB);
sp.spec = raw.specs(:);
sp.sw   = raw.spectralwidth;
sp.n    = raw.sz(1);
% PPM軸は DFT の各点の周波数から作り直す (中心 = 4.65 ppm は FID-A と同じ)
% FID-A の raw.ppm は刻み幅が SW/(N−1) (正しくは SW/N) のため、ピーク間の差が N/(N−1) 倍
% (N = 2048 で約 0.05%) 大きくなり、Δ = 2.9 ppm では約 0.0014 ppm (≒ 0.13 °C) の誤差になる
f = (floor(sp.n / 2) - (0:sp.n - 1)') * sp.sw / sp.n;   % 送信周波数からのずれ [Hz] (FID-A と同じく高周波側から)
sp.ppm = 4.65 + f / (raw.txfrq / 1e6);
end
