function scan_center_path = el_center(scan_path)

% Create a copy with "_cent" suffix
scan_center_path = strrep(scan_path, '.nii', '_cent.nii');

% Load the scan
scan_spm = spm_vol(char(scan_path));

% Read the image data
scan_img = spm_read_vols(scan_spm);

% Calculate the center of the volume
[nx, ny, nz] = size(scan_img);
center_voxel = [(nx+1)/2, (ny+1)/2, (nz+1)/2];

% Calculate the translation needed to bring the center to the origin
% in the coordinate space (0,0,0)
translation = scan_spm.mat * [center_voxel, 1]';
translation = translation(1:3);

% Update the transformation matrix with the translation
translation_matrix = eye(4);
translation_matrix(1:3, 4) = -translation;
scan_spm.mat = translation_matrix * scan_spm.mat;

% Save the centered scan
scan_spm.fname = char(scan_center_path);
spm_write_vol(scan_spm, scan_img);

end