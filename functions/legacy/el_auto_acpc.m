function el_auto_acpc(input_path, output_path)

fprintf('>>>>>Aligning %s to AC-PC\n\n', input_path)

% Create a copy with output name
copyfile(input_path, output_path)

% Automatic reorientation
auto_acpc_reorient(output_path)

fprintf('\n>>>>>Aligned scan saved at %s\n\n', output_path)

end