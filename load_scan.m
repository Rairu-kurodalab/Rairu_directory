function sc = load_scan(folder, LB, eccMode)
% スキャンフォルダの読み込み: パラメータ (method / acqp) と複素スペクトル
% MRS以外のスキャン (PVM_WsMode が無い) や method / acqp の無いフォルダは [] を返す
% eccMode = 'refscan' なら fid.refscan の位相で渦電流補正 (load_spectrum_ecc 参照)
sc = [];
if ~isfile(fullfile(folder, 'method')) || ~isfile(fullfile(folder, 'acqp'))
    return;
end
mt = fileread(fullfile(folder, 'method'));
at = fileread(fullfile(folder, 'acqp'));
wsMode = get_bruker_param(mt, 'PVM_WsMode');
if isempty(wsMode)
    return;
end
sp = load_spectrum_ecc(folder, LB, eccMode);

t = get_bruker_param(at, 'ACQ_time');   % 撮像開始の時刻 (例: <2026-10-06T15:01:04,938+0900>)
if numel(t) >= 20
    acqTime = datetime(t(2:20), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
else
    acqTime = NaT;
end
% 撮像中央の時刻 = 開始 + ダミースキャン + 撮像時間の半分 (パラメータが無ければ 0 とみなす)
dummyMs = str2double(get_bruker_param(mt, 'PVM_DummyScansDur'));
scanMs  = str2double(get_bruker_param(mt, 'PVM_ScanTime'));
tMid = acqTime + milliseconds(sum([dummyMs, scanMs / 2], 'omitnan'));
% 撮像中 (ダミースキャンの後〜終了) の時間帯
tAcq = acqTime + milliseconds(sum(dummyMs, 'omitnan') + [0, sum(scanMs, 'omitnan')]);

% ボクセルのサイズと位置 (同じボクセル同士かの確認用)
voxSize = get_bruker_param(mt, 'PVM_VoxArrSize', true);
voxPos  = get_bruker_param(mt, 'PVM_VoxArrPosition', true);

% src: 水のスキャンとして図・表に出すときの種類 ('nosup' / 'refscan'; ref_as_scan 参照)
% refFid・refSpec: ECC に使った refscan の FID と、その ECC 後のスペクトル (eccMode = 'none' では空)
% fShift: 絶対周波数のずれ [Hz] (align_water が設定; ふつうは 0)
[~, name] = fileparts(folder);
isWS = ~strcmp(wsMode, 'NO_SUPPRESSION');
sc = struct('scan', str2double(name), 'time', acqTime, 'tMid', tMid, 'tAcq', tAcq, ...
    'isWS', isWS, 'wsMode', wsMode, 'src', if_else_str(isWS, 'sup', 'nosup'), ...
    'sfo1', str2double(get_bruker_param(at, 'SFO1')), 'bf1', str2double(get_bruker_param(at, 'BF1')), 'fShift', 0, ...
    'voxel', strjoin(split(voxSize)', 'x'), 'geom', [voxSize ' @ ' voxPos], ...
    'ppm', sp.ppm, 'spec', sp.spec, 'sw', sp.sw, 'n', sp.n, 'refFid', sp.refFid, 'refSpec', sp.refSpec);
end
