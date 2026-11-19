function df = ref_freq_diff(refA, refB, sw)
% 2つの refscan (水抑制なしの参照スキャンの FID) の水の周波数の差 A − B [Hz]
% (それぞれの送信周波数からのずれの差)
% A × conj(B) の位相の傾きを、振幅で重み付けした直線フィットで求める。渦電流による位相の揺れは A と B で
% ほぼ同じなので打ち消し合い、周波数の差だけが直線の傾きとして残る
z = refA(:) .* conj(refB(:));
a = abs(z);
last = find(a > 0.1 * max(a), 1, 'last');   % 信号が十分ある範囲だけ使う
idx = (1:last)';
p = unwrap(angle(z(idx)));
c = lscov([(idx - 1) / sw, ones(last, 1)], p, a(idx));
df = c(1) / (2 * pi);
end
