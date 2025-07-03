function el_coreg(ref_path, source_path, out_path)

fprintf('>> el_coreg\n\tREFERENCE: %s\n\tSOURCE: %s\n\tOUTPUT: %s\n', ...
    ref_path, source_path, out_path)

fprintf('>>>>>Coregistering %s to %s\n', ...
    source_path, ref_path)

% Load scans
t1_spm = spm_vol(char(ref_path));
other_spm = spm_vol(char(source_path));
other_img = spm_read_vols(other_spm);

% Estimate the transformation matrix
x = spm_coreg(t1_spm, other_spm);

% Update the transformation matrix in the other_spm structure
other_spm.mat = spm_matrix(x) \ other_spm.mat;
other_spm.fname = char(out_path);
spm_write_vol(other_spm, other_img);

fprintf('Done\n')

end