function nos = align_water(nos, s)
% nosup スキャン (配列) の絶対周波数を sup スキャン s と比べられるようにする (fShift を設定して返す)
% ECC (Klose 法) をかけたスペクトルの中心は、そのスキャン自身の refscan の水の周波数になる (元の送信周波数
% からのずれの情報は消える)。そこで nosup と sup の refscan 同士の水の周波数差を求め、その分だけ nosup をずらす。
% ECC なし (refFid が空) のスキャンは 0 のまま (従来どおり送信周波数を基準に比べる)。
% 点数・SW が違って比べられない場合は NaN (その nosup は使えない)
for i = 1:numel(nos)
    nos(i).fShift = 0;
    if ~isempty(nos(i).refFid) && ~isempty(s.refFid)
        if nos(i).n == s.n && abs(nos(i).sw - s.sw) < 1e-6
            nos(i).fShift = ref_freq_diff(nos(i).refFid, s.refFid, s.sw);
        else
            nos(i).fShift = NaN;
        end
    end
end
end
