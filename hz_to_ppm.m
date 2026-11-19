function p = hz_to_ppm(s, fHz)
% 絶対周波数 [Hz] → スキャン s のPPM軸 (ppm_to_hz の逆変換)
p = 4.65 + (fHz - s.sfo1 * 1e6 - s.fShift) / s.bf1;
end
