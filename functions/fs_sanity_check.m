function fs_sanity_check(cfg)

if isempty(cfg.dir_fs)
    error('Please specify FreeSurfer directory at %s', fullfile(elec_loc_dir, 'config.json'))
elseif ~exist(cfg.dir_fs, "dir")
    error('%s does not exist\nPlease re-specify FreeSurfer directory at %s', ...
        cfg.dir_fs, fullfile(elec_loc_dir, 'config.json'))
elseif ~exist(fullfile(cfg.dir_fs, 'SetUpFreeSurfer.sh'), 'file')
    error(['%s is not a valid FreeSurfer directory (SetUpFreeSurfer.sh not found)\n' ...
        'Please re-specify FreeSurfer directory at %s'], ...
        cfg.dir_fs, fullfile(elec_loc_dir, 'config.json'))
end

end