function [cfg, pat] = el_init(cfg, pat)

% Add warning for missing toolboxes
if license('test', 'Signal_Toolbox') ~= 1
    error('iElectrodes requires Signal Processing Toolbox')
end
if license('test', 'Statistics_Toolbox') ~= 1
    error('iElectrodes requires Statistics Toolbox')
end

% Check iElectrodes installation
iel_info = dir(fullfile(cfg.dir_el, 'iElectrodes*'));
if isempty(iel_info)
    error(['iElectrodes toolbox not detected. ' ...
        'Please download iElectrods from\n%s\n' ...
        'And move the unzipped folder to %s'], ...
        'https://sourceforge.net/projects/ielectrodes/files/ielectrodes/', ...
        cfg.dir_el)
end
cfg.dir_iel = fullfile(cfg.dir_el, iel_info(1).name);
addpath(genpath(cfg.dir_iel))

% Add path to external packages
addpath(fullfile(cfg.dir_el, 'external/spm12'))
addpath(fullfile(cfg.dir_el, 'external/spm12/toolbox/OldNorm/'))
addpath(fullfile(cfg.dir_el, 'external/auto_acpc_reorient/'))
addpath(genpath(fullfile(cfg.dir_el, 'external/dicm2nii')))

% Add path to BrainNet Viewer
cfg.dir_bnv = fullfile(cfg.dir_el, 'external', 'BrainNet-Viewer');
cfg.dir_bnv_templates = fullfile(cfg.dir_bnv, 'Data', 'SurfTemplate');
addpath(cfg.dir_bnv)

% Sanity check if FreeSurfer directory is valid
if isunix
    fs_sanity_check(cfg)
end

pat.dir.fs = fullfile(cfg.dir_fs_subjects, pat.id);
pat.dir.fs_mri = fullfile(pat.dir.fs, 'mri');
pat.dir.fs_surf = fullfile(pat.dir.fs, 'surf');
pat.dir.el = fullfile(pat.dir.fs, 'elec_loc');
pat.dir.el_bids = fullfile(pat.dir.el, 'BIDS_outputs');
pat.dir.el_bids_anat = fullfile(pat.dir.el_bids, 'anat');
pat.dir.el_bids_ieeg = fullfile(pat.dir.el_bids, 'ieeg');

for field = fieldnames(pat.dir)'
    if ~exist(pat.dir.(char(field)), 'dir')
        mkdir(pat.dir.(char(field)))
    end
end