function el_elec_mni152(cfg, pat, elec)

% Estimate native-to-MNI152 transformation matrix
nat_to_152 = nii_coreg('mni_T1', pat.t1.final);

% Define paths to output files
prefix = strcat('sub-', pat.id, '_space-MNI152Lin_electrodes');
csv_path  = fullfile(pat.dir_iel, strcat(prefix, '.csv'));
tsv_path  = fullfile(pat.dir_iel, strcat(prefix, '.tsv'));
node_path = fullfile(pat.dir_iel, strcat(prefix, '.node'));
gb_path   = fullfile(pat.dir_iel, strcat(prefix, '.jpg'));

% Get all info from iElectrodes
chs = [elec.ch];
ismicro = endsWith({chs.name}, 'u');

name = {chs.name}';
is_micro = [chs.is_micro]';

coord_nat = [[chs.x]', [chs.y]', [chs.z]', ones(length(name), 1)];
coord_152 = nat_to_152 * coord_nat';
coord_152 = coord_152(1:3,:)';

x = coord_152(:,1);
y = coord_152(:,2);
z = coord_152(:,3);

size = 2 * ones(length(name), 1); % Macro size : 2mm
size(ismicro) = 1.5;

color = ones(length(name), 1);
color(ismicro) = 2;

tbl = table(name, x, y, z, size, is_micro);
tbl_node = table(x, y, z, color, size, name);

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