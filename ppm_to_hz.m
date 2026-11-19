function f = ppm_to_hz(s, ppmRaw)
% スキャン s のPPM軸 (FID-A: 中心 = 4.65 ppm) → 絶対周波数 [Hz]
% s.fShift は ECC 後のスキャンを別のスキャンの基準に合わせるためのずれ (align_water 参照; ふつうは 0)
f = s.sfo1 * 1e6 + s.fShift + (ppmRaw - 4.65) * s.bf1;
end
