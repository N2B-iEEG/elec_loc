function nii_path = el_dcm2nii(pat, scan_name)

scan_dir = uigetdir('', ...
    sprintf('Select the folder containing DICOM files for %s', ...
    scan_name));

if isnumeric(scan_dir)
    error('No folder selected')
end

cd(scan_dir)

% Anonymize DICOM
anonymize_dicm(scan_dir, scan_dir, char(pat.id))

% Convert to NIFTI
dicm2nii(scan_dir, scan_dir, '.nii')

% Find the newest NIFTI
nii_files = dir(fullfile(scan_dir, '*.nii'));
[~, newest_idx] = max(datetime({nii_files.date}));
nii_file = nii_files(newest_idx);
nii_path = fullfile(scan_dir, nii_file.name);

% Visualizing scan
waitfor(msgbox(sprintf(['Converted scan saved at: %s\n\n' ...
    'Please inspect the scan in the following viewer.\n'], ...
    nii_path), 'Conversion complete'));

waitfor(nii_viewer(nii_path))

end