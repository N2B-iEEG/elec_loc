function el_center(in_path, out_path, demean)

fprintf('>> el_center\n\tINPUT: %s\n\tOUTPUT: %s\n', in_path, out_path)

% Load the scan
scan_spm = spm_vol(char(in_path));

% Read the 3D image data
scan_img = spm_read_vols(scan_spm);

% Demean data
if demean
    scan_img = scan_img - round(mean(scan_img, 'all'));
end

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
scan_spm.fname = char(out_path);
spm_write_vol(scan_spm, scan_img);

fprintf('Done\n')

end