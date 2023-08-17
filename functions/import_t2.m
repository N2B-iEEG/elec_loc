function import_t2(config, pat)

t2_dir = fullfile(pat.dir, 't2');
if ~exist(t2_dir, 'dir'), mkdir(t2_dir), end
t2_t_path = fullfile(t2_dir, 't2.nii');

[t2_s_name, t2_s_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
    'Select T2 scan');
t2_s_path = fullfile(t2_s_dir, t2_s_name);

if endsWith(t2_s_path, '.nii')

    % Copy to T2 subfolder
    copyfile(t2_s_path, t2_t_path)
    fprintf('T2 image copied to %s', t2_t_path)

else % Convert to .nii if in another format

    bash_code = sprintf('%s; mri_convert %s %s', ...
        fs_setup_code(config), t2_s_path, t2_t_path);

    system(bash_code);

end

end