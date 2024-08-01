function el_fs_recon_all(cfg, pat)

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

system(bash_code);

end