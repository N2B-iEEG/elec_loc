function label_native(config, pat)

lookup_tbl_path = fullfile(config.dir_fs, 'FreeSurferColorLUT.txt');
lookup_tbl_fid = fopen(lookup_tbl_path, 'r');

lookup_tbl = textscan(lookup_tbl_fid, '%s', 'Delimiter', '\n');
lookup_tbl = lookup_tbl{1};

iel_dir = fullfile(pat.dir, 'iel');

[elec_fn, elec_dir] = uigetfile(fullfile(iel_dir, '*.txt'), ...
    'Select iElectrodes output txt');
elec_path = fullfile(elec_dir, elec_fn);

output_path = fullfile(iel_dir, strcat(pat.name, '_elec_native.csv'));

% List of atlases to read from
atlases = {'aparc.a2009s+aseg', 'aparc.DKTatlas+aseg'};

% Open input and output file
elec_fid = fopen(elec_path, 'r');
output_fid = fopen(output_path, 'w');

% Write first line (header) of output file
columns = [{'channel'}, {'x_native'}, {'y_native'}, {'z_native'}, atlases(:)'];
header_txt = repmat('%s, ', 1, length(columns));
header_txt = header_txt(1:end-2);
fprintf(output_fid, [header_txt '\n'], columns{:});

% Read first line of elec file
elec_line = fgetl(elec_fid);

% Read the file line by line
while ischar(elec_line)

    parts = strsplit(elec_line, ' ');
    coord_mm = str2double(parts(2:4));

    % Initialize the output line with ID and coordinates
    output_line = join(parts, ', ');
    output_line = output_line{1};

    for atlas = atlases
        atlas_path  = fullfile(pat.dir, 'mri', strcat(atlas{1}, '.nii'));
        coord_val   = mm2val(coord_mm, atlas_path);

        for lookup_tbl_line = lookup_tbl'
            lookup_tbl_line_str = lookup_tbl_line{1};
            if startsWith(lookup_tbl_line_str, strcat(coord_val, " "))
                line_parts = strsplit(lookup_tbl_line_str, ' ');
                label = line_parts{2};
                output_line = strcat(output_line, ", ", label);
            end
        end
    end

    % Write new output line
    fprintf(output_fid, '%s\n', output_line);

    % Read the next line
    elec_line = fgetl(elec_fid);
end

% Close files
fclose(lookup_tbl_fid);
fclose(elec_fid);
fclose(output_fid);

fprintf('Electrode location (native space) table saved at: %s\n', output_path)

end