function el_elec_mni152(cfg, pat)

% Estimate native-to-MNI152 transformation matrix
nat_to_152 = nii_coreg('mni_T1', pat.t1.image);

% Define paths to output files
prefix = strcat('sub-', pat.id, '_space-MNI152Lin_electrodes');
csv_path  = fullfile(pat.dir.el, strcat(prefix, '.csv'));
tsv_path  = fullfile(pat.dir.el_bids_ieeg, strcat(prefix, '.tsv'));
node_path = fullfile(pat.dir.el, strcat(prefix, '.node'));

prefix = strcat('sub-', pat.id, '_acq-MNI152Render_photo');
gb_path   = fullfile(pat.dir.el_bids_ieeg, strcat(prefix, '.jpg'));

% Get all info from iElectrodes
elec = [pat.elec.ch];
is_micro = [elec.is_micro]';
n_elec = length(elec);

coord_nat = [[elec.x]', [elec.y]', [elec.z]', ones(n_elec, 1)];
coord_152 = nat_to_152 * coord_nat';

name = {elec.name}';
x = coord_152(1,:)';
y = coord_152(2,:)';
z = coord_152(3,:)';
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

%% Save
writetable(tbl, csv_path)
writetable(tbl, tsv_path, ...
    'FileType', 'text', 'Delimiter', '\t')
writetable(tbl_node, node_path, ...
    'FileType', 'text', 'Delimiter', 'space', ...
    'WriteVariableNames', false)

%% Visualize with BrainNet Viewer
options = fullfile(cfg.dir_el, 'bnv_options.mat');
surf    = fullfile(cfg.dir_bnv_templates, 'BrainMesh_ICBM152.nv');

BrainNet_MapCfg(surf, node_path, options, gb_path);

%% Display
fprintf(['Electrode location (MNI152 space) saved:\n' ...
    '\t CSV:           %s\n' ...
    '\t TSV:           %s\n' ...
    '\t BrainNet node: %s\n' ...
    '\t Glass brain:   %s\n'], ...
    csv_path, tsv_path, node_path, gb_path)

end