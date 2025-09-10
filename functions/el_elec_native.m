function el_elec_native(cfg, pat, seg_hipp, seg_thal)

% Lookup table (updated)
fs_lut_path = fullfile(cfg.dir_el, 'FreeSurferColorLUT.mat');

% Define paths to output files
prefix = strcat('sub-', pat.id, '_space-ACPC_electrodes');
csv_path  = fullfile(pat.dir.el, strcat(prefix, '.csv'));
tsv_path  = fullfile(pat.dir.el_bids_ieeg, strcat(prefix, '.tsv'));
node_path = fullfile(pat.dir.el, strcat(prefix, '.node'));
reref_path = fullfile(pat.dir.el, strcat(prefix, '_bipolar-reref.csv'));

prefix = strcat('sub-', pat.id, '_acq-ACPCRender_photo');
gb_path   = fullfile(pat.dir.el_bids_ieeg, strcat(prefix, '.jpg'));

% List of atlases to read from
atlases = {
    'aparc.a2009s+aseg', 'aparc.DKTatlas+aseg', 'wmparc', ...
    };
if seg_hipp
    atlases = [atlases, {'lh.hippoAmygLabels-T1.v22',...
                        'rh.hippoAmygLabels-T1.v22', ...
                        'lh.hippoAmygLabels-T1-T2.v22',...
                        'rh.hippoAmygLabels-T1-T2.v22'},...
                        ];
end
if seg_thal
    atlases = [atlases, {'ThalamicNuclei.v13.T1'},...
        ];
end

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

% Differentiate macro and micro by size and color
node_size = 2 * ones(length(name), 1);
node_size(is_micro) = 1.5;
color = ones(length(name), 1);
color(is_micro) = 2;

% Construct table
tbl = table( ...
    name, x, y, z, size, material, manufacturer, group, hemisphere, ...
    type, impedance, dimension);
tbl_node = table(x, y, z, color, node_size, name);

pos_nat = [x, y, z];

% Get label from atlases
n_atlas = 0;
for atlas = atlases

    atlas_name = string(atlas);
    atlas_path = char(fullfile(pat.dir.fs_mri, strcat(atlas, '.nii')));

    if exist(atlas_path, 'file')
        fprintf("Getting labels from atlas %s\n", atlas_name)
        n_atlas = n_atlas + 1;
    end

    [aLabel, ~, ~] = el_anatomicLabelFS( ...
        pos_nat, atlas_path, fs_lut_path, 0 ...
        );

    tbl.(atlas_name) = aLabel';

end
if n_atlas < 3
    error("Not enough atlases to read from. " + ...
        "Please check if recon-all and mgz2nii were run successfully.")
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

H = BrainNet_MapCfg(surf, node_path, options, gb_path);
close(H)

%% Display
fprintf(['Electrode location (native ACPC space) saved:\n' ...
    '\t CSV:           %s\n' ...
    '\t TSV:           %s\n' ...
    '\t BrainNet node: %s\n' ...
    '\t Glass brain:   %s\n'], ...
    csv_path, tsv_path, node_path, gb_path)