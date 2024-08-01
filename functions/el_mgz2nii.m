function el_mgz2nii(cfg, pat)

bash_code = fs_setup_code(cfg);
mgz = dir(fullfile(pat.dir.fs_mri, '*.mgz'));

for i_mgz = 1:length(mgz)
    if startsWith(mgz(i_mgz).name, {'aparc.DKTatlas+aseg', 'aparc.a2009s+aseg', 'wmparc'})
        i_mgz_path = fullfile(mgz(i_mgz).folder, mgz(i_mgz).name);
        i_nii_path = fullfile(mgz(i_mgz).folder, [mgz(i_mgz).name(1:end-3) 'nii']);
        bash_code = sprintf('%s; mri_convert --in_type mgz --out_type nii --out_orientation RAS %s %s', ...
            bash_code, i_mgz_path, i_nii_path);
    end
end

fprintf(['Converting .mgz to .nii in %s\n' ...
    '================================================================================\n'], ...
    pat.dir.fs_mri)

system(bash_code);

fprintf(['mgz2nii conversion completed\n' ...
    '================================================================================\n'])

end