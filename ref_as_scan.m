function w = ref_as_scan(s)
% sup スキャン s の refscan (ECC 後) を、水のスキャンとして扱うための構造体 (waterRef = 'refscan' 用)
% 時刻は撮像開始 (refscan は最初に取られる)
w = s;
w.spec = s.refSpec;
w.isWS = false;
w.src  = 'refscan';
w.tMid = s.time;
end
