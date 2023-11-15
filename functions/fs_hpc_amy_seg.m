function fs_hpc_amy_seg(config, pat, scan_to_use)

bash_code = fs_setup_code(config);

if strcmp(scan_to_use, 'T1')
    bash_code = sprintf('%s; segmentHA_T1.sh %s', ...
        bash_code, pat.name);

elseif strcmp(scan_to_use, 'T2')
    t2_coreg_path = fullfile(pat.dir, 't2', 't2_coreg_fs.nii');
    if ~exist(t2_coreg_path, "file")
        error('%s not found. Cannot use %s option', t2_coreg_path, )
    end
    bash_code = sprintf('%s; segmentHA_T2.sh %s %s T2 0', ...
        bash_code, pat.name, t2_coreg_path);

elseif strcmp(scan_to_use, 'T1+T2')
    t2_coreg_path = fullfile(pat.dir, 't2', 't2_coreg_fs.nii');
    bash_code = sprintf('%s; segmentHA_T2.sh %s %s T1_T2 1', ...
        bash_code, pat.name, t2_coreg_path);

end

system(bash_code);


end