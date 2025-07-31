function el_fs_recon_all(cfg, pat, hip_amy, thalamus)

orig_dir = fullfile(pat.dir.fs_mri, 'orig');
if ~exist(orig_dir, 'dir')
    mkdir(orig_dir)
end

orig_mgz = fullfile(orig_dir, '001.mgz');

bash_code = sprintf( ...
    ['%s; ' ...
    'mri_convert %s %s; ' ...
    'recon-all -s %s -all'], ...
    fs_setup_code(cfg), ...
    pat.t1.image, orig_mgz, ...
    pat.id);

if hip_amy
    bash_code = sprintf('%s; segmentHA_T1.sh %s', ...
        bash_code, pat.id);
    if isfield(pat, "t2")
        % segmentHA_T2.sh bert FILE_ADDITIONAL_SCAN ANALYSIS_ID USE_T1
        bash_code = sprintf('%s; segmentHA_T2.sh %s %s T2 1', ...
            bash_code, pat.id, pat.t2.image);
    end
end

if thalamus
    bash_code = sprintf('%s; segmentThalamicNuclei.sh %s', ...
        bash_code, pat.id);
end

system(bash_code);

end