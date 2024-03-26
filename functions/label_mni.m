function label_mni(pat)

% Transformation matrix from native space to fsaverage
nat_to_fsavg_path = fullfile(pat.dir, 'mri/transforms/talairach.xfm');
nat_to_fsavg_fid = fopen(nat_to_fsavg_path, 'r');
nat_to_fsavg_text = textscan(nat_to_fsavg_fid, '%s', 'Delimiter', '\n');
fclose(nat_to_fsavg_fid);

nat_to_fsavg_text = nat_to_fsavg_text{1}(end-2:end);
nat_to_fsavg_mat = zeros(3, 4);
for i_row = 1:size(nat_to_fsavg_text, 1)
    row = nat_to_fsavg_text{i_row};
    row_parts = strsplit(row, ' ');
    if i_row == 3
        row_parts{4} = row_parts{4}(1:end-1);
    end
    row = str2double(row_parts);
    nat_to_fsavg_mat(i_row, :) = row;
end

% Transformation matrix from fsaverage to MNI152
% Source: https://surfer.nmr.mgh.harvard.edu/fswiki/CoordinateSystems (8)
mat_fsavg_to_152 = [
    0.9975   -0.0073    0.0176   -0.0429
    0.0146    1.0009   -0.0024    1.5496
    -0.0130   -0.0093    0.9971    1.1840];

iel_dir = fullfile(pat.dir, 'iel');

[elec_fn, elec_dir] = uigetfile(fullfile(iel_dir, '*.txt'), ...
    'Select iElectrodes output txt');
elec_path = fullfile(elec_dir, elec_fn);

csv_fsavg_path  = fullfile(iel_dir, strcat('sub-', pat.id, '_space-fsaverage_electrodes.csv'));
node_fsavg_path = fullfile(iel_dir, strcat('sub-', pat.id, '_space-fsaverage_electrodes.node'));
csv_152_path    = fullfile(iel_dir, strcat('sub-', pat.id, '_space-MNI152Lin_electrodes.csv'));
node_152_path   = fullfile(iel_dir, strcat('sub-', pat.id, '_space-MNI152Lin_electrodes.node'));

% Open input and output file
elec_fid = fopen(elec_path, 'r');
csv_fsavg_fid  = fopen(csv_fsavg_path, 'w');
node_fsavg_fid = fopen(node_fsavg_path, 'w');
csv_152_fid  = fopen(csv_152_path, 'w');
node_152_fid = fopen(node_152_path, 'w');

% Write first line (header) of output file
hdr_txt = repmat('%s, ', 1, 4);
hdr_txt = hdr_txt(1:end-2);
columns = [{'name'}, {'x'}, {'y'}, {'z'}];
fprintf(csv_fsavg_fid, [hdr_txt '\n'], columns{:});
fprintf(csv_152_fid, [hdr_txt '\n'], columns{:});

% Read first line of elec file
elec_line = fgetl(elec_fid);

% Read the file line by line
while ischar(elec_line)

    parts = strsplit(elec_line, ' ');
    ch_name = parts{1};

    if strcmp(ch_name(end), 'u')
        node_size = 0.5;
    else
        node_size = 1;
    end

    % Compute coordinate in fsaverage and MNI152 using two transformations
    coord_nat = str2double(parts(2:4));
    coord_fsavg = nat_to_fsavg_mat * [coord_nat, 1]';
    coord_152 = mat_fsavg_to_152 * [coord_fsavg; 1];

    % Append fsaverage coordinates to output line
    csv_fsavg_line  = strcat(ch_name, ',', {' '}, join(string(coord_fsavg'), ', '));
    node_fsavg_line = strcat(join(string(coord_fsavg'), ' '), {' '}, ...
        '1', {' '}, string(node_size), {' '}, ch_name);

    % Append MNI152 coordinates to output line
    csv_152_line  = strcat(ch_name, ',', {' '}, join(string(coord_152'), ', '));
    node_152_line = strcat(join(string(coord_152'), ' '), {' '}, ...
        '1', {' '}, string(node_size), {' '}, ch_name);

    % Write new output line
    fprintf(csv_fsavg_fid, '%s\n', csv_fsavg_line);
    fprintf(node_fsavg_fid, '%s\n', node_fsavg_line);
    fprintf(csv_152_fid, '%s\n', csv_152_line);
    fprintf(node_152_fid, '%s\n', node_152_line);

    % Read the next line
    elec_line = fgetl(elec_fid);
end

% Close files
fclose(elec_fid);
fclose(csv_fsavg_fid);
fclose(node_fsavg_fid);
fclose(csv_152_fid);
fclose(node_152_fid);

fprintf('Electrode location (fsaverage space) table saved at: %s\n', csv_fsavg_path)
fprintf('Electrode location (MNI152 space) table saved at: %s\n', csv_152_path)
fprintf('Electrode location (fsaverage space) node saved at: %s\n', node_fsavg_path)
fprintf('Electrode location (MNI152 space) node saved at: %s\n', node_152_path)

end