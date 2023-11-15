function pat = fs_recon_all(config, pat)

[t1_name, t1_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
    'Select T1 scan');
t1_path = fullfile(t1_dir, t1_name);

bash_code = sprintf('%s; recon-all -s %s -i %s -all', ...
    fs_setup_code(config), pat.name, t1_path);

system(bash_code);

pat.dir  = fullfile(config.dir_fs_subjects, pat.name);

end