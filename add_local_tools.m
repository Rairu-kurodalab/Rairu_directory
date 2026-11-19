function add_local_tools(here)
% FID-A-master と padarray.m を、スクリプトのフォルダ → 1つ上のフォルダ の順に探してパスの先頭に追加する
% (Osprey 同梱の旧版 FID-A より優先させるため)
for base = {here, fileparts(here)}
    if isfolder(fullfile(base{1}, 'FID-A-master'))
        addpath(genpath(fullfile(base{1}, 'FID-A-master')));
        break;
    end
end
for base = {here, fileparts(here)}
    if isfile(fullfile(base{1}, 'padarray.m'))
        addpath(base{1});
        break;
    end
end
if ~exist('io_loadspec_bruk', 'file')
    error('FID-A-master が見つかりません。スクリプトと同じフォルダか1つ上のフォルダに置いてください。');
end
if ~exist('padarray', 'file')
    error('padarray が見つかりません (Image Processing Toolbox、または MRS フォルダの padarray.m が必要です)。');
end
end
