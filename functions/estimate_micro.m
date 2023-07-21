function estimate_micro(pat, micro_to_macro_dist)

arguments
    pat
    micro_to_macro_dist {mustBeNumeric}
end

%% Read iElectrodes output txt
iel_dir = fullfile(pat.dir, 'iel');

[elec_fn, elec_dir] = uigetfile(fullfile(iel_dir, '*.txt'), ...
    'Select iElectrodes output txt');
data = readtable(fullfile(elec_dir, elec_fn));

%% Find electrode arrays
ch_col = string(data.Var1);
for i_ch = 1:length(ch_col)
    ch_name = char(ch_col(i_ch));
    % if channel name ends with digit or u
    if isstrprop(ch_name(end), 'digit') || strcmp(ch_name(end), 'u')
        ch_name = ch_name(1:end-1); % Strip the last char
    end
    array_col(i_ch) = string(ch_name);
end
[array_names, ~, array_idx] = unique(array_col);

%% If array lacks micro, estiamte with macro 1 and 2
no_u_count = 0;
for i_array = 1:length(array_names)
    array_name = array_names(i_array);
    micro_name = strcat(array_name, 'u');
    if ~ismember(micro_name, ch_col(array_idx == i_array))
        fprintf('No microwire found for %-8s Estimating... \n', array_name)
        no_u_count = no_u_count+1;

        macro1_name = strcat(array_name, '1');
        macro1_idx  = find(data.Var1 == macro1_name);
        macro1_xyz  = [data.Var2(macro1_idx) data.Var3(macro1_idx) data.Var4(macro1_idx)];

        macro2_name = strcat(array_name, '2');
        macro2_idx  = find(data.Var1 == macro2_name);
        macro2_xyz  = [data.Var2(macro2_idx) data.Var3(macro2_idx) data.Var4(macro2_idx)];

        % Compute unit vector using difference between macro 1 and 2
        diff_vec = macro1_xyz - macro2_xyz;
        unit_vec = diff_vec / sqrt(sum(diff_vec.^2));

        micro_xyz = round(macro1_xyz + unit_vec * micro_to_macro_dist, 5);
        new_micro = table({char(micro_name)}, micro_xyz(1), micro_xyz(2), micro_xyz(3), ...
            'VariableNames', {'Var1', 'Var2', 'Var3', 'Var4'});
        data = [data; new_micro];
    end
end

%% Save new txt if micro estimation happened
if no_u_count ~= 0
    data = sortrows(data, 'Var1');
    idx = strfind(elec_fn, '.');
    output_fn = fullfile(elec_dir, [elec_fn(1:idx-1), '_u', elec_fn(idx:end)]);
    writetable(data, output_fn, 'Delimiter', ' ', 'WriteVariableNames', false);
    fprintf('New txt saved: %s\n', output_fn)
else
    fprintf('%s already have microwire estimates. No further operation\n', fullfile(elec_dir, elec_fn))
end

end