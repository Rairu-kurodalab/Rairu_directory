function [pks, segs, rpk, rseg] = fit_ref_peaks(s, waterInSup, refs, cplx)
% 参照ピーク (NAA・Cr・Cho; sup スキャン s) の複素フィット
%   waterInSup : 水の位置を s のPPM軸に換算した値 [ppm]
%   NAA (anchor = 'water') : 水 − search の範囲の最大点 ± cplx.locWin で中心を探す
%   Cr・Cho (anchor = 'NAA') : NAA + search の範囲に中心を制限 (複数ピーク同時フィット)
% 返り値の ppm は s のPPM軸の値。segs は図示用 (基準ごと)
% rpk / rseg : sup の残留水 (診断用; 水の位置 ± 0.3 ppm の最大ピーク)
noiseRange = waterInSup + [3.0, 5.0];

refNames = {refs.name};
pks = repmat(struct('ppm', NaN, 'amp', 0, 'hwhm', 0, 'snr', 0, 'ok', false), 1, numel(refs));
done = false(1, numel(refs));
segs = {};
anchors = unique({refs.anchor}, 'stable');
for a = 1:numel(anchors)
    sel = find(strcmp({refs.anchor}, anchors{a}));
    if strcmp(anchors{a}, 'water')
        ranges = sort(waterInSup - vertcat(refs(sel).search), 2);
        % 水基準のピーク (NAA): 探索範囲の最大点 ± locWin の範囲で中心を探す
        inits = zeros(numel(sel), 1);
        for j = 1:numel(sel)
            in = find(s.ppm > ranges(j, 1) & s.ppm < ranges(j, 2));
            [~, im] = max(abs(s.spec(in)));
            inits(j) = s.ppm(in(im));
        end
        ranges = inits + cplx.locWin * [-1 1];
    else
        ia = find(strcmp(refNames, anchors{a}));
        if isempty(ia) || ~done(ia)
            error('''%s'' の基準 ''%s'' は、それより前の基準でフィットされるピークである必要があります。', refs(sel(1)).name, anchors{a});
        end
        ranges = pks(ia).ppm + vertcat(refs(sel).search);
        % 他のピーク基準 (Cr, Cho): 文献値の差を初期値とし、中心は探索範囲内に制限
        inits = min(max(pks(ia).ppm + [refs(sel).shift]' - refs(ia).shift, ranges(:, 1)), ranges(:, 2));
    end
    [pk, sg] = fit_complex_peaks(s.ppm, s.spec, ranges, inits, cplx.margin, cplx.maxHW, noiseRange);
    pks(sel) = pk;
    segs{end+1} = sg; %#ok<AGROW>
    done(sel) = true;
end

% sup の残留水 (診断用): 水の位置 ± 0.3 ppm の最大ピークを水と同じ方法でフィット
in = find(abs(s.ppm - waterInSup) < 0.3);
[~, im] = max(abs(s.spec(in)));
c0 = s.ppm(in(im));
[rpk, rseg] = fit_complex_peaks(s.ppm, s.spec, c0 + cplx.locWin * [-1 1], c0, cplx.waterMargin, cplx.waterMaxHW, noiseRange);
end
