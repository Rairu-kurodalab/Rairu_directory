function v = get_bruker_param(txt, key, nextLine)
% Bruker パラメータファイル (method / acqp) の文字列 txt から "##$key=値" の値を文字列で取得 (無ければ '')
%   nextLine = true : 配列パラメータ "##$key=( ... )" の次の行 (値の本体) を取得
if nargin < 3
    nextLine = false;
end
if nextLine
    tk = regexp(txt, ['##\$' key '=[^\r\n]*\r?\n([^\r\n]*)'], 'tokens', 'once');
else
    tk = regexp(txt, ['##\$' key '=([^\r\n]*)'], 'tokens', 'once');
end
if isempty(tk)
    v = '';
else
    v = strtrim(tk{1});
end
end
