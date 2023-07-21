function label_mni(pat)

% Transformation matrix from native space to MNI305
nat_to_305_path = fullfile(pat.dir, 'mri/transforms/talairach.xfm');
nat_to_305_fid = fopen(nat_to_305_path, 'r');
nat_to_305_text = textscan(nat_to_305_fid, '%s', 'Delimiter', '\n');
fclose(nat_to_305_fid);

nat_to_305_text = nat_to_305_text{1}(end-2:end);
nat_to_305_mat = zeros(3, 4);
for i_row = 1:size(nat_to_305_text, 1)
    row = nat_to_305_text{i_row};
    row_parts = strsplit(row, ' ');
    if i_row == 3
        row_parts{4} = row_parts{4}(1:end-1);
    end
    row = str2double(row_parts);
    nat_to_305_mat(i_row, :) = row;
end

% Transformation matrix from MNI305 to MNI152
% Source: https://surfer.nmr.mgh.harvard.edu/fswiki/CoordinateSystems (8)
mat_305_to_152 = [
    0.9975   -0.0073    0.0176   -0.0429
    0.0146    1.0009   -0.0024    1.5496
    -0.0130   -0.0093    0.9971    1.1840];

iel_dir = fullfile(pat.dir, 'iel');

[elec_fn, elec_dir] = uigetfile(fullfile(iel_dir, '*.txt'), ...
    'Select iElectrodes output txt');
elec_path = fullfile(elec_dir, elec_fn);

csv_305_path = fullfile(iel_dir, strcat(pat.name, '_elec_mni305.csv'));
node_305_path = fullfile(iel_dir, strcat(pat.name, '_elec_mni305.node'));
csv_152_path = fullfile(iel_dir, strcat(pat.name, '_elec_mni152.csv'));
node_152_path = fullfile(iel_dir, strcat(pat.name, '_elec_mni152.node'));

% Open input and output file
elec_fid = fopen(elec_path, 'r');
csv_305_fid  = fopen(csv_305_path, 'w');
node_305_fid = fopen(node_305_path, 'w');
csv_152_fid  = fopen(csv_152_path, 'w');
node_152_fid = fopen(node_152_path, 'w');

% Write first line (header) of output file
header_txt = repmat('%s, ', 1, 4);
header_txt = header_txt(1:end-2);
columns = [{'channel'}, {'x_mni305'}, {'y_mni305'}, {'z_mni305'}];
fprintf(csv_305_fid, [header_txt '\n'], columns{:});
columns = [{'channel'}, {'x_mni152'}, {'y_mni152'}, {'z_mni152'}];
fprintf(csv_152_fid, [header_txt '\n'], columns{:});

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

    % Get channel name
    csv_305_line = ch_name;
    csv_152_line = ch_name;

    % Compute coordinate in MNI305 and MNI152 using two transformations
    coord_nat = str2double(parts(2:4));
    coord_305 = nat_to_305_mat * [coord_nat, 1]';
    coord_152 = mat_305_to_152 * [coord_305; 1];

    % Append MNI305 coordinates to output line
    csv_305_line  = strcat(csv_305_line, ',', {' '}, join(string(coord_305'), ', '));
    node_305_line = strcat(join(string(coord_305'), ' '), {' '}, ...
        '1', {' '}, string(node_size), {' '}, ch_name);

    % Append MNI152 coordinates to output line
    csv_152_line  = strcat(csv_152_line, ',', {' '}, join(string(coord_152'), ', '));
    node_152_line = strcat(join(string(coord_152'), ' '), {' '}, ...
        '1', {' '}, string(node_size), {' '}, ch_name);

    % Write new output line
    fprintf(csv_305_fid, '%s\n', csv_305_line);
    fprintf(node_305_fid, '%s\n', node_305_line);
    fprintf(csv_152_fid, '%s\n', csv_152_line);
    fprintf(node_152_fid, '%s\n', node_152_line);

    % Read the next line
    elec_line = fgetl(elec_fid);
end

% Close files
fclose(elec_fid);
fclose(csv_305_fid);
fclose(node_305_fid);
fclose(csv_152_fid);
fclose(node_152_fid);

fprintf('Electrode location (MNI305 space) table saved at: %s\n', csv_305_path)
fprintf('Electrode location (MNI152 space) table saved at: %s\n', csv_152_path)
fprintf('Electrode location (MNI305 space) node saved at: %s\n', node_305_path)
fprintf('Electrode location (MNI152 space) node saved at: %s\n', node_152_path)

end