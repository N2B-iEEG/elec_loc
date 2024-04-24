function el_elec_native(cfg, pat, elec)

% Load FreeSurfer value-to-label lookup table
fs_lut_path = fullfile(cfg.dir_iel, 'priv', 'FreeSurferColorLUT.mat');
load(fs_lut_path, 'values', 'labels')

% Define paths to output files
prefix = strcat('sub-', pat.id, '_space-ACPC_electrodes');
csv_path  = fullfile(pat.dir_iel, strcat(prefix, '.csv'));
tsv_path  = fullfile(pat.dir_iel, strcat(prefix, '.tsv'));
node_path = fullfile(pat.dir_iel, strcat(prefix, '.node'));
gb_path   = fullfile(pat.dir_iel, strcat(prefix, '.jpg'));

% List of atlases to read from
atlases = {'aparc.a2009s+aseg', 'aparc.DKTatlas+aseg', 'wmparc'};

% Get all info from iElectrodes
chs = [elec.ch];
is_micro = [chs.is_micro]';

name = {chs.name}';
x    = [chs.x]';
y    = [chs.y]';
z    = [chs.z]';
coord_nat = [x, y, z];

size = 2 * ones(length(name), 1); % Macro size : 2mm
size(is_micro) = 1.5;

color = ones(length(name), 1);
color(is_micro) = 2;

tbl = table(name, x, y, z, size, is_micro);
tbl_node = table(x, y, z, color, size, name);

% Get label from atlases
for atlas = atlases

    atlas = string(atlas);
    atlas_path = fullfile(pat.dir, 'mri', strcat(atlas, '.nii'));

    if ~exist(atlas_path, 'file')
        error(['%s not found\nPlease check if' ...
            'recon-all and mgz2nii were successfully run.'], ...
            atlas_path)
    end

    coord_val = int16(mm2val(coord_nat, atlas_path));

    [~, label_idx] = ismember(coord_val, values);
    ch_labels = labels(label_idx);

    tbl.(atlas) = ch_labels;

end

%% Save
writetable(tbl, csv_path)
writetable(tbl, tsv_path, ...
    'FileType', 'text', 'Delimiter', '\t')
writetable(tbl_node, node_path, ...
    'FileType', 'text', 'Delimiter', 'space', ...
    'WriteVariableNames', false)

%% Visualize with BrainNet Viewer
options = fullfile(cfg.dir_el, 'bnv_options.mat');
surf    = fullfile(pat.dir_iel, 'bil_pial.nv');

BrainNet_MapCfg(surf, node_path, options, gb_path);

%% Display
fprintf(['Electrode location (native ACPC space) saved:\n' ...
    '\t CSV:           %s\n' ...
    '\t TSV:           %s\n' ...
    '\t BrainNet node: %s\n' ...
    '\t Glass brain:   %s\n'], ...
    csv_path, tsv_path, node_path, gb_path)

end