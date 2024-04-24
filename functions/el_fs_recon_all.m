function el_fs_recon_all(cfg, pat)

if ~exist(fullfile(pat.dir, 'mri'), 'dir')
    mkdir(fullfile(pat.dir, 'mri'))
end

pat.t1.orig_dir = fullfile(pat.dir, 'mri', 'orig');
if ~exist(fullfile(pat.dir, 'mri', 'orig'), 'dir')
    mkdir(fullfile(pat.dir, 'mri', 'orig'))
end

orig_mgz = fullfile(pat.t1.orig_dir, '001.mgz');

bash_code = sprintf( ...
    ['%s; ' ...
    'mri_convert %s %s; ' ...
    'recon-all -s %s -all'], ...
    fs_setup_code(cfg), ...
    pat.t1.final, orig_mgz, ...
    pat.id);

system(bash_code);

end