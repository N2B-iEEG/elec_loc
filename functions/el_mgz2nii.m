function el_mgz2nii(cfg, pat)

% Set up FreeSurfer
bash_code = fs_setup_code(cfg);

% Get all .mgz files in the mri folder
mgz_files = dir(fullfile(pat.dir.fs_mri, '*.mgz'));

for mgz = mgz_files'

    is_aparc = startsWith(mgz.name, {'aparc.DKTatlas+aseg', 'aparc.a2009s+aseg', 'wmparc'});
    is_thalamic = startsWith(mgz.name, 'ThalamicNuclei');
    is_hippo = ~isempty(regexp(mgz.name, 'hippoAmygLabels.*\.v\d+\.mgz$', 'once'));

    if is_aparc || is_hippo || is_thalamic
        i_mgz_path = fullfile(mgz.folder, mgz.name);
        i_nii_path = fullfile(mgz.folder, [mgz.name(1:end-3) 'nii']);
        bash_code = sprintf('%s; mri_convert -it mgz -ot nii --out_orientation RAS %s %s', ...
            bash_code, i_mgz_path, i_nii_path);

    end
end

% Execute the code through bash
system(bash_code);

fprintf('All atlases converted to NIFTI\n')

end