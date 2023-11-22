function mideface(config)

[t1_name, t1_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
    'Select pre-op T1 MRI image');
t1_path = fullfile(t1_dir, t1_name);

idx = strfind(t1_name, '.'); idx = idx(1);
output_path = fullfile(t1_dir, [t1_name(1:idx-1), '_deface', t1_name(idx:end)]);

bash_code = sprintf('%s; mideface --i %s --o %s; freeview -layout 1 -viewport 3d -v %s:isosurface=on', ...
    fs_setup_code(config), t1_path, output_path, output_path);

system(bash_code);

end