function mgz2nii(config, pat)

bash_code = fs_setup_code(config);
pat_mri_dir = fullfile(pat.dir, 'mri');
mgz = dir(fullfile(pat_mri_dir, '*.mgz'));
for i_mgz = 1:length(mgz)
    if startsWith(mgz(i_mgz).name, {'orig', 'nu', 'T1', 'brain', 'ribbon', 'aseg', 'aparc'})
        i_mgz_path = fullfile(mgz(i_mgz).folder, mgz(i_mgz).name);
        i_nii_path = fullfile(mgz(i_mgz).folder, [mgz(i_mgz).name(1:end-3) 'nii']);
        bash_code = sprintf('%s; mri_convert --in_type mgz --out_type nii --out_orientation RAS %s %s', ...
            bash_code, i_mgz_path, i_nii_path);
    end
end
fprintf('Converting .mgz to .nii in %s\n================================================================================\n', ...
    pat_mri_dir)

system(bash_code);

fprintf('mgz2nii conversion completed\n================================================================================\n')

end