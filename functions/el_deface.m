function el_deface(t1_path, deface_path)

% Create copy
copyfile(t1_path, deface_path)

% Defacing
nii_deface(deface_path)

fprintf('De-faced T1 saved at: %s\n', deface_path)

end