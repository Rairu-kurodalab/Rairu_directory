function [pks, seg] = fit_complex_peaks(ppm, spec, ranges, inits, margin, maxHW, noiseRange)
% 複素ローレンツ (複数ピーク同時) + 0次・1次位相 + 1次の複素ベースライン  (fit_complex_lorentzian.m の拡張版)
%   M(x) = exp(i(φ0 + φ1 (x − xm))) × Σ A_k / (1 + i s (x − c_k) / w_k) + b0 + b1 (x − xm)
%   s = ±1 は周波数軸の向き (データの符号の約束) で、両方試して残差の小さい方を採用
%   位相の初期値は (最大点の位相 + 0, π/2, π, −π/2) の4通りを試す
% 入力:
%   ppm, spec  : スペクトル全体の ppm 軸と複素スペクトル
%   ranges     : 各ピーク中心の許容範囲 [ppm] (ピーク数 × 2)
%   inits      : 各ピーク中心の初期値 (ピーク数 × 1)
%   margin     : フィット範囲 = [ranges の最小 − margin, ranges の最大 + margin]
%   maxHW      : 半値半幅の上限 [ppm]
%   noiseRange : SNR 計算に使うノイズ領域 [ppm]
% 出力:
%   pks(k): ppm (中心), amp (吸収形の高さ), hwhm (半値半幅 [ppm]), snr, ok (フィット良否)
%   seg   : 図示用 (位相補正後の実部・虚部・モデル・位相 φ など)
nPk = size(ranges, 1);
idx = ppm > min(ranges(:)) - margin & ppm < max(ranges(:)) + margin;
x = ppm(idx);
y = spec(idx);
xm = mean(x);

lb = [-Inf, -40, -Inf, -Inf, -Inf, -Inf];   % φ0, φ1 [rad/ppm], b0 (実・虚), b1 (実・虚)
ub = [ Inf,  40,  Inf,  Inf,  Inf,  Inf];
p0 = zeros(1, 6);
for k = 1:nPk
    [~, j] = min(abs(x - inits(k)));
    lb = [lb, 0,   ranges(k, 1), 0.002]; %#ok<AGROW>
    ub = [ub, Inf, ranges(k, 2), maxHW]; %#ok<AGROW>
    p0 = [p0, abs(y(j)), inits(k), min(0.01, maxHW / 2)]; %#ok<AGROW>
end
[~, jm] = max(abs(y));
opts = optimset('Display', 'off');
best.rn = Inf;
for sgn = [1, -1]
    f = @(p, xx) cplx_stack(cplx_model(p, xx, xm, sgn, nPk));
    for dphi = [0, pi/2, pi, -pi/2]   % 位相の初期値 (最大点の位相 + dphi)
        p0(1) = angle(y(jm)) + dphi;
        [p, rn, ~, exitflag] = lsqcurvefit(f, p0, x, [real(y); imag(y)], lb, ub, opts);
        if rn < best.rn
            best = struct('p', p, 'rn', rn, 'sgn', sgn, 'exitflag', exitflag);
        end
    end
end

p = best.p;
[M, L, base, Phi] = cplx_model(p, x, xm, best.sgn, nPk);
rot = exp(-1i * Phi);
seg.x        = x;
seg.data     = real(y .* rot);   % 位相補正後の実部 (吸収)
seg.model    = real(M .* rot);
seg.base     = real(base .* rot);
seg.peaks    = real(L) + seg.base;
seg.dataIm   = imag(y .* rot);   % 位相補正後の虚部 (分散)
seg.modelIm  = imag(M .* rot);
seg.modelAbs = abs(M);           % 複素フィットの絶対値 (位相によらない)
seg.phi      = p(1:2);           % フィットで求めた位相 φ0, φ1
seg.xm       = xm;

z = spec(ppm > min(noiseRange) & ppm < max(noiseRange));
noise = std([real(z) - mean(real(z)); imag(z) - mean(imag(z))]);
pks = repmat(struct('ppm', NaN, 'amp', 0, 'hwhm', 0, 'snr', 0, 'ok', false), 1, nPk);
for k = 1:nPk
    q = p(6 + 3 * (k - 1) + (1:3));   % [A, c, w]
    tol = 0.02 * diff(ranges(k, :));
    atBound = abs(q(2) - ranges(k, 1)) < tol || abs(q(2) - ranges(k, 2)) < tol || q(3) > 0.9 * maxHW;
    pks(k) = struct('ppm', q(2), 'amp', q(1), 'hwhm', q(3), 'snr', q(1) / noise, 'ok', best.exitflag > 0 && ~atBound);
end
end

function [M, L, base, Phi] = cplx_model(p, x, xm, sgn, nPk)
% 複素ローレンツモデル。L: 位相をかける前の各ピーク
L = zeros(numel(x), nPk);
for k = 1:nPk
    q = p(6 + 3 * (k - 1) + (1:3));   % [A, c, w]
    L(:, k) = q(1) ./ (1 + 1i * sgn * (x(:) - q(2)) / q(3));
end
Phi  = p(1) + p(2) * (x(:) - xm);
base = (p(3) + 1i * p(4)) + (p(5) + 1i * p(6)) * (x(:) - xm);
M    = exp(1i * Phi) .* sum(L, 2) + base;
end

function v = cplx_stack(z)
% 複素数ベクトル → [実部; 虚部] (lsqcurvefit 用)
v = [real(z); imag(z)];
end
