function coord_val = mm2val(coord_mm, nifti_file)

    % Load NIfTI header
    val  = niftiread(nifti_file);
    info = niftiinfo(nifti_file);

    center = -info.Transform.T(4, 1:3);

    for i = 1:size(coord_mm, 1)

        % Convert from mm to voxel indices using inverted transformation matrix
        coord_vox = coord_mm(i,:) + center;

        % Since FreeSurfer output is 1mm isotropic, rounding will do the job
        coord_vox = round(coord_vox) + 1;

        % Read intensity
        coord_val(i) = val(coord_vox(1), coord_vox(2), coord_vox(3));

    end

end
