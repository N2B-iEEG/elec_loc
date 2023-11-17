function el_deface(t1_path, deface_path)

fprintf('>>>>>Defacing %s\n', t1_path)

% Create copy
copyfile(t1_path, deface_path)

% Defacing
nii_deface(deface_path)

fprintf('>>>>>Defaced scan saved at %s\n\n', deface_path)

end