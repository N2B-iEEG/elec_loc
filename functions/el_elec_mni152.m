function el_elec_mni152(cfg, pat)

% Estimate native-to-MNI152 transformation matrix
pat.t1.image = fullfile(pat.dir.el, sprintf('sub-%s_acq-preop_T1w.nii', pat.id));
mni_template_path = fullfile(cfg.dir_el, 'icbm_avg_152_t1_tal_lin.nii');
trans_matrix = nii_coreg(mni_template_path, pat.t1.image);

% Define paths to output files
prefix = strcat('sub-', pat.id, '_space-MNI152Lin_electrodes');
csv_path  = fullfile(pat.dir.el, strcat(prefix, '.csv'));
tsv_path  = fullfile(pat.dir.el_bids_ieeg, strcat(prefix, '.tsv'));
node_path = fullfile(pat.dir.el, strcat(prefix, '.node'));
reref_path = fullfile(pat.dir.el, strcat(prefix, '_bipolar-reref.csv'));

prefix = strcat('sub-', pat.id, '_acq-MNI152Render_photo');
gb_path   = fullfile(pat.dir.el_bids_ieeg, strcat(prefix, '.jpg'));

% Get all info from iElectrodes
elec = [pat.elec.ch];
is_micro = [elec.is_micro]';
n_elec = length(elec);

pos_nat = [[elec.x]', [elec.y]', [elec.z]', ones(n_elec, 1)];
pos_152 = trans_matrix * pos_nat';

name = {elec.name}';
x = pos_152(1,:)';
y = pos_152(2,:)';
z = pos_152(3,:)';
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
surf    = fullfile(cfg.dir_bnv_templates, 'BrainMesh_ICBM152.nv');

H = BrainNet_MapCfg(surf, node_path, options, gb_path);
close(H)

%% Display
fprintf(['Electrode location (MNI152 space) saved:\n' ...
    '\t CSV:           %s\n' ...
    '\t TSV:           %s\n' ...
    '\t BrainNet node: %s\n' ...
    '\t Glass brain:   %s\n'], ...
    csv_path, tsv_path, node_path, gb_path)

end