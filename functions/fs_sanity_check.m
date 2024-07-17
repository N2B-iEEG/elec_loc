function fs_sanity_check(cfg)

if ~isfield(cfg, 'dir_fs')
    error('Please specify FreeSurfer directory as cfg.dir_fs')
elseif ~exist(cfg.dir_fs, "dir")
    error(['%s does not exist\n' ...
        'Please specify a valid FreeSurfer directory as cfg.dir_fs'], ...
        cfg.dir_fs)
elseif ~exist(fullfile(cfg.dir_fs, 'SetUpFreeSurfer.sh'), 'file')
    error(['%s is not a valid FreeSurfer directory (SetUpFreeSurfer.sh not found)\n' ...
        'Please specify a valid FreeSurfer directory as cfg.dir_fs'], ...
        cfg.dir_fs)
end

end