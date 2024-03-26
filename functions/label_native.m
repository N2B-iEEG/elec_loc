function label_native(config, pat)

lookup_tbl_path = fullfile(config.dir_fs, 'FreeSurferColorLUT.txt');
lookup_tbl_fid = fopen(lookup_tbl_path, 'r');

lookup_tbl = textscan(lookup_tbl_fid, '%s', 'Delimiter', '\n');
lookup_tbl = lookup_tbl{1};

iel_dir = fullfile(pat.dir, 'iel');

[elec_fn, elec_dir] = uigetfile(fullfile(iel_dir, '*.txt'), ...
    'Select iElectrodes output txt');
elec_path = fullfile(elec_dir, elec_fn);

csv_path  = fullfile(iel_dir, strcat('sub-', pat.id, '_space-ACPC_electrodes.csv'));
node_path = fullfile(iel_dir, strcat('sub-', pat.id, '_space-ACPC_electrodes.node'));

% List of atlases to read from
atlases = {'aparc.a2009s+aseg', 'aparc.DKTatlas+aseg'};

% Open input and output file
elec_fid = fopen(elec_path, 'r');
csv_fid = fopen(csv_path, 'w');
node_fid = fopen(node_path, 'w');

% Write first line (header) of output file
columns = [{'name'}, {'x'}, {'y'}, {'z'}, {'size'}, atlases(:)'];
hdr_txt = repmat('%s, ', 1, length(columns));
hdr_txt = hdr_txt(1:end-2);
fprintf(csv_fid, [hdr_txt '\n'], columns{:});

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

    coord_nat = str2double(parts(2:4));

    % Initialize the output line with ID and coordinates
    csv_line = join(parts, ', ');
    csv_line = csv_line{1};
    csv_line = strcat(csv_line, ', 1');

    node_line = strcat(join(string(coord_nat'), ' '), {' '}, ...
        '1', {' '}, string(node_size), {' '}, ch_name);

    % Get label from atlases
    for atlas = atlases
        atlas_path  = fullfile(pat.dir, 'mri', strcat(atlas{1}, '.nii'));
        coord_val   = mm2val(coord_nat, atlas_path);

        for lookup_tbl_line = lookup_tbl'
            lookup_tbl_line_str = lookup_tbl_line{1};
            if startsWith(lookup_tbl_line_str, strcat(coord_val, " "))
                line_parts = strsplit(lookup_tbl_line_str, ' ');
                label = line_parts{2};
                csv_line = strcat(csv_line, ", ", label);
            end
        end
    end

    % Write new output line
    fprintf(csv_fid, '%s\n', csv_line);
    fprintf(node_fid, '%s\n', node_line);

    % Read the next line
    elec_line = fgetl(elec_fid);
end

% Close files
fclose(lookup_tbl_fid);
fclose(elec_fid);
fclose(csv_fid);
fclose(node_fid);

fprintf('Electrode location (native space) table saved at: %s\n', csv_path)
fprintf('Electrode location (native space) node saved at: %s\n', node_path)

end