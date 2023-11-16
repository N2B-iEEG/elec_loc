function el_auto_acpc(input_path, output_path)

% Create a copy with output name
copyfile(input_path, output_path)

% Automatic reorientation
auto_acpc_reorient(output_path)

end