function t1_t2_coreg(config, pat, method)

t1_path = fullfile(pat.dir, 'mri', 'orig.nii');
t2_dir  = fullfile(pat.dir, 't2');
t2_path = fullfile(t2_dir, 't2.nii');
if ~exist(t2_path, 'file')
    error('T2 scan not found. Please provide a t2.nii file in %s', t2_dir)
end

%% Coregister t2 to original MRI
if strcmp(method, 'freesurfer')

    t2_coreg_path = fullfile(t2_dir, 't2_coreg_fs.nii');
    t2_to_t1_lta_path = fullfile(t2_dir, 't2_to_t1.lta');
    t2_to_t1_dat_path = fullfile(t2_dir, 't2_to_t1.dat');
    bash_code = sprintf(['%s; ' ...
        'mri_coreg --mov %s --targ %s --reg %s --lta %s; ' ... % Estimate
        'mri_vol2vol --mov %s --targ %s --lta %s --o %s'], ... % Reslice
        fs_setup_code(config), t2_path, t1_path, t2_to_t1_dat_path, t2_to_t1_lta_path, ...
        t2_path, t1_path, t2_to_t1_lta_path, t2_coreg_path);
    system(bash_code);

elseif strcmp(method, 'spm')

    t2_coreg_path = fullfile(t2_dir, 't2_coreg_spm.nii');
    t1_spm = spm_vol(t1_path);
    t2_spm = spm_vol(t2_path);

    % Estimate and save transformation matrix
    x = spm_coreg(t1_spm, t2_spm);
    save(fullfile(t2_dir, 't2_to_t1.mat'), "x")

    % Reslice t2
    t2_spm.mat = spm_matrix(x) \ t2_spm.mat;
    spm_reslice(t2_spm, struct('prefix', 'coreg_'));

    spm_output = fullfile(t2_dir, 'coreg_t2.nii');
    movefile(spm_output, t2_coreg_path)

    % Clean mean* file
    mean_file = dir(fullfile(t2_dir, 'mean*'));
    for f = mean_file
        delete(fullfile(f.folder, f.name))
    end

else
    fprintf("co-registration method cannot be %s. Choose between 'freesurfer' and 'spm'\n", method)
end

fprintf('\nCoregistered T2 saved at %s\n\n', t2_coreg_path)

%% Visualize coreg results in freeview
fprintf(['Visualizing T1-T2 coregistration with freeview\n' ...
    '================================================================================\n'])

bash_code = fs_setup_code(config);
bash_code = sprintf('%s; freeview -layout 2 -v %s -v %s:colormap=jet', ...
    bash_code, t1_path, t2_coreg_path);

system(bash_code);

end