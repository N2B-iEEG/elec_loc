function pat = fs_find_subj(config)

pat_dir_filter = config.dir_fs_subjects;

pat.dir = uigetdir(pat_dir_filter, 'Select patient folder in FreeSurfer subjects directory');
pat_dir_parts = split(pat.dir, filesep);
pat.name = pat_dir_parts{end};

% Check if recon-all was complete using DKT atlas file
if ~exist(fullfile(pat.dir, 'mri', 'aparc.DKTatlas+aseg.mgz'), 'file')
    error(['%s is not a valid FreeSurfer subject directory (aparc.DKTatlas+aseg.mgz not found)\n' ...
        'Please make sure you have run FreeSurfer recon-all beforehand\n' ...
        'See more at https://surfer.nmr.mgh.harvard.edu/fswiki/recon-all'], pat.dir)
end
fprintf('Patient %s selected\n', pat.name)
fprintf('FreeSurfer folder at %s', pat.dir)

end