function import_ct(config, pat)

ct_dir = fullfile(pat.dir, 'ct');
if ~exist(ct_dir, 'dir'), mkdir(ct_dir), end
ct_t_path = fullfile(ct_dir, 'postop_ct.nii');

[ct_s_name, ct_s_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
    'Select post-op CT image');
ct_s_path = fullfile(ct_s_dir, ct_s_name);

if endsWith(ct_s_path, '.nii')

    % Copy to CT subfolder
    copyfile(ct_s_path, ct_t_path)
    fprintf('CT image copied to %s', ct_t_path)

else % Convert to .nii if in another format

    bash_code = sprintf('%s; mri_convert %s %s', ...
        fs_setup_code(config), ct_s_path, ct_t_path);

    system(bash_code);

end

end