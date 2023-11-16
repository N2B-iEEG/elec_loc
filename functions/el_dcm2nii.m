function el_dcm2nii(pat)

arguments
    pat struct
end

while true % Loop for conversions of multiple scans

    scan_dir = uigetdir('', ...
        'Select the folder containing DICOM files of the brain scan');

    if isnumeric(scan_dir)
        disp('No folder selected. Exiting.')
        break
    end

    cd(scan_dir)

    % Anonymize DICOM
    anonymize_dicm(scan_dir, scan_dir, char(pat.name))

    % Convert to NIFTI
    dicm2nii(scan_dir, scan_dir, '.nii')

    % Find the newest NIFTI
    nii_files = dir(fullfile(scan_dir, '*.nii'));
    [~, newest_idx] = max(datetime({nii_files.date}));
    nii_file = nii_files(newest_idx);

    % Ask whether to change name
    nii_new_name = inputdlg( ...
        'Enter NIFTI file name', ...
        'dcm2nii', ...
        1, ...
        {'.nii'});

    nii_new_path = fullfile(scan_dir, nii_new_name{1});

    % Rename NIFTI
    movefile( ...
        fullfile(scan_dir, nii_file.name), ...
        nii_new_path)

    fprintf('Converted scan saved at: %s\n', ...
        nii_new_path)

    % Visualizing scan
    waitfor(msgbox(sprintf(['Converted scan saved at: %s\n\n' ...
        'Please inspect the scan in the following viewer.'], ...
        nii_new_path), 'Conversion complete'));

    waitfor(nii_viewer(nii_new_path))

    % Ask if proceed to convert another
    proceed = questdlg( ...
        'Do you want to convert another scan?', ...
        'dcm2nii', ...
        'Yes', ...
        'No', ...
        'No');

    if strcmp(proceed, 'No')
        break
    end

end

end