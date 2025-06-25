function el_elec_native(cfg, pat)

% Load FreeSurfer value-to-label lookup table
fs_lut_path = fullfile(cfg.dir_iel, 'priv', 'FreeSurferColorLUT.mat');
%load(fs_lut_path, 'values', 'labels')
temp = load(fs_lut_path);
values = table2array(temp.fs_labels(:,'values'));
labels = temp.fs_labels{:,'labels'};

% Define paths to output files
prefix = strcat('sub-', pat.id, '_space-ACPC_electrodes');
csv_path  = fullfile(pat.dir.el, strcat(prefix, '.csv'));
tsv_path  = fullfile(pat.dir.el_bids_ieeg, strcat(prefix, '.tsv'));
node_path = fullfile(pat.dir.el, strcat(prefix, '.node'));
reref_path = fullfile(pat.dir.el, strcat(prefix, '_bipolar-reref.csv'));

prefix = strcat('sub-', pat.id, '_acq-ACPCRender_photo');
gb_path   = fullfile(pat.dir.el_bids_ieeg, strcat(prefix, '.jpg'));

% List of atlases to read from
atlases = {'aparc.a2009s+aseg', 'aparc.DKTatlas+aseg', 'wmparc'};

% Get all info from iElectrodes
elec = [pat.elec.ch];
is_micro = [elec.is_micro]';
n_elec = length(elec);

name  = {elec.name}';
x     = [elec.x]';
y     = [elec.y]';
z     = [elec.z]';
group = {elec.group}';
type  = {elec.type}';

% Unknown columns required by BIDS
[size, material, manufacturer, hemisphere, impedance, dimension] = ...
    deal(repmat("n/a", n_elec, 1));

node_size = 2 * ones(length(name), 1); % Macro size : 2mm
node_size(is_micro) = 1.5;

color = ones(length(name), 1);
color(is_micro) = 2;

tbl = table( ...
    name, x, y, z, size, material, manufacturer, group, hemisphere, ...
    type, impedance, dimension);
tbl_node = table(x, y, z, color, node_size, name);

coord_nat = [x, y, z];

% Get label from atlases
for atlas = atlases

    atlas_name = string(atlas);
    atlas_path = fullfile(pat.dir.fs_mri, strcat(atlas, '.nii'));

    if ~exist(atlas_path, 'file')
        error(['%s not found\nPlease check if ' ...
            'recon-all and mgz2nii were successfully run.'], ...
            atlas_path)
    end

    coord_val = int16(mm2val(coord_nat, atlas_path));

    [~, label_idx] = ismember(coord_val, values);
    ch_labels = labels(label_idx);

    tbl.(atlas_name) = ch_labels;

end

% Separate virtual electrodes table
is_bipolar = strcmp(type,'bipolar');
tbl_reref = tbl(is_bipolar,:);
tbl(is_bipolar,:) = []; % Drop virtual electrodes from tables
tbl_node(is_bipolar,:) = []; 

%% Save
writetable(tbl, csv_path)
writetable(tbl, tsv_path, ...
    'FileType', 'text', 'Delimiter', '\t')
writetable(tbl_node, node_path, ...
    'FileType', 'text', 'Delimiter', 'space', ...
    'WriteVariableNames', false)
if ~isempty(tbl_reref)
    writetable(tbl_reref, reref_path)
end

%% Visualize with BrainNet Viewer
options = fullfile(cfg.dir_el, 'bnv_options.mat');
surf    = fullfile(pat.dir.el, 'bil_white.nv');

BrainNet_MapCfg(surf, node_path, options, gb_path);

%% Display
fprintf(['Electrode location (native ACPC space) saved:\n' ...
    '\t CSV:           %s\n' ...
    '\t TSV:           %s\n' ...
    '\t BrainNet node: %s\n' ...
    '\t Glass brain:   %s\n'], ...
    csv_path, tsv_path, node_path, gb_path)

end