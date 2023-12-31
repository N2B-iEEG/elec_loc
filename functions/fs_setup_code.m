function fs_setup_code = fs_setup_code(config)

if isempty(config.dir_fs_subjects) % if FreeSurfer SUBJECTS_DIR was not specified
    fs_setup_code = sprintf( ...
        'export FREESURFER_HOME=%s && source $FREESURFER_HOME/SetUpFreeSurfer.sh', ...
        config.dir_fs, config.dir_fs_subjects);
else
    fs_setup_code = sprintf( ...
        'export FREESURFER_HOME=%s && export SUBJECTS_DIR=%s && source $FREESURFER_HOME/SetUpFreeSurfer.sh', ...
        config.dir_fs, config.dir_fs_subjects);
end

end