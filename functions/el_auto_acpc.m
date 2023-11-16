function scan_acpc_path = el_auto_acpc(scan_path)

% Create a copy with "_acpc" suffix
scan_acpc_path = strrep(scan_path, '.nii', '_acpc.nii');
copyfile(scan_path, scan_acpc_path)

% Automatic reorientation
auto_acpc_reorient(scan_acpc_path)

end