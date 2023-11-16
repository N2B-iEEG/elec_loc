function other_coreg_path = el_coreg(t1_path, other_path)

other_coreg_path = strrep(other_path, '.nii', '_coreg.nii');

% Center the other image
t1_spm = spm_vol(char(t1_path));
other_spm = spm_vol(char(other_path));
other_img = spm_read_vols(other_spm);

% Estimate the transformation matrix
x = spm_coreg(t1_spm, other_spm);

% Update the transformation matrix in the other_spm structure
other_spm.mat = spm_matrix(x) \ other_spm.mat;
other_spm.fname = char(other_coreg_path);
spm_write_vol(other_spm, other_img);

end