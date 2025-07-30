filename = 'FreeSurferColorLUT.txt';
fileID = fopen(filename, 'r');
data = textscan(fileID, '%s', 'Delimiter', '\n');
fclose(fileID);

% Extract data starting from the line after the header
dataLines = data{1};

% Initialize arrays to store the data
values = [];
labels = {};
R = [];
G = [];
B = [];

% Loop through the data lines and extract the values
for i = 1:length(dataLines)
    line = dataLines{i};
    line = strtrim(line);

    % Skip empty lines or lines starting with '#' (comments)
    if isempty(line) || startsWith(line, '#')
        continue;
    end

    % Split the line into fields using spaces as delimiters
    fields = strsplit(line, ' ');
    
    % Remove empty fields
    fields = fields(~cellfun('isempty', fields));
    
    % Extract the values
    values = [values str2double(fields{1})];
    labels = [labels {strjoin(fields(2:end-4), ' ')}]; %Handles labels with spaces
    R = [R str2double(fields{end-3})];
    G = [G str2double(fields{end-2})];
    B = [B str2double(fields{end-1})];
end

values = values';
labels = labels';
RGB = [R' G' B'];

save("../../FreeSurferColorLUT.mat", "values", "labels", "RGB")