function [A, B] = calib_coef(ref, mode)
% 温度校正式ごとの係数 (T [°C] = A − B × Δ,  Δ = 水 − 参照ピーク [ppm])
switch mode
    case 'cady2011'
        A = ref.cadyA;
        B = ref.cadyB;
    case 'zhu2008'   % T = 36 + α (Δ − F0)  →  A = 36 − α F0, B = −α
        A = 36 - ref.zhuAlpha * ref.zhuF0;
        B = -ref.zhuAlpha;
    case 'aqueous'
        A = 96.9 * (7.83 - ref.shift) - 273.15;
        B = 96.9;
    otherwise
        error('校正式 ''%s'' は未対応です (''cady2011'' / ''zhu2008'' / ''aqueous'')。', mode);
end
end
