function t1_ct_coreg(config, pat, method)

t1_path = fullfile(pat.dir, 'mri', 'orig.nii');
ct_dir  = fullfile(pat.dir, 'ct');
ct_path = fullfile(ct_dir, 'postop_ct.nii');
if ~exist(ct_path, 'file')
    error('CT scan not found. Please provide a postop_ct.nii file in %s', ct_dir)
end

%% Coregister CT to original MRI
if strcmp(method, 'freesurfer')

    ct_coreg_path = fullfile(ct_dir, 'postop_ct_coreg_fs.nii');
    ct2t1_lta_path = fullfile(ct_dir, 'ct2t1.lta');
    ct2t1_dat_path = fullfile(ct_dir, 'ct2t1.dat');
    bash_code = sprintf(['%s; ' ...
        'mri_coreg --mov %s --targ %s --reg %s --lta %s; ' ... % Estimate
        'mri_vol2vol --mov %s --targ %s --lta %s --o %s'], ... % Reslice
        fs_setup_code(config), ct_path, t1_path, ct2t1_dat_path, ct2t1_lta_path, ...
        ct_path, t1_path, ct2t1_lta_path, ct_coreg_path);
    system(bash_code);

elseif strcmp(method, 'spm')

    ct_coreg_path = fullfile(ct_dir, 'postop_ct_coreg_spm.nii');
    t1_spm = spm_vol(t1_path);
    ct_spm = spm_vol(ct_path);

    % Estimate and save transformation matrix
    x = spm_coreg(t1_spm, ct_spm);
    save(fullfile(ct_dir, 'ct2t1.mat'), "x")

    % Reslice CT
    ct_spm.mat = spm_matrix(x) \ ct_spm.mat;
    spm_reslice(ct_spm, struct('prefix', 'coreg_'));

    spm_output = fullfile(ct_dir, 'coreg_postop_ct.nii');
    movefile(spm_output, ct_coreg_path)

    % Clean mean* file
    mean_file = dir(fullfile(ct_dir, 'mean*'));
    for f = mean_file
        delete(fullfile(f.folder, f.name))
    end

else
    fprintf("co-registration method cannot be %s. Choose between 'freesurfer' and 'spm'\n", method)
end

fprintf('\nCoregistered CT saved at %s\n\n', ct_coreg_path)

%% Visualize coreg results in freeview
bash_code = fs_setup_code(config);
bash_code = sprintf('%s; freeview -v %s -v %s:colormap=jet', ...
    bash_code, t1_path, ct_coreg_path);
fprintf(['Visualizing T1-CT coregistration with freeview\n' ...
    '================================================================================\n'])
system(bash_code);

end