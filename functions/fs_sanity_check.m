function fs_sanity_check(config)

if isempty(config.dir_fs)
    error('Please specify FreeSurfer directory at %s', fullfile(elec_loc_dir, 'config.json'))
elseif ~exist(config.dir_fs, "dir")
    error('%s does not exist\nPlease re-specify FreeSurfer directory at %s', ...
        config.dir_fs, fullfile(elec_loc_dir, 'config.json'))
elseif ~exist(fullfile(config.dir_fs, 'SetUpFreeSurfer.sh'), 'file')
    error(['%s is not a valid FreeSurfer directory (SetUpFreeSurfer.sh not found)\n' ...
        'Please re-specify FreeSurfer directory at %s'], ...
        config.dir_fs, fullfile(elec_loc_dir, 'config.json'))
end

end