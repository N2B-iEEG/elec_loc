function elec = el_est_micro(elec, micro_to_macro_dist)

%% If array lacks micro, estiamte with macro 1 and 2
no_u_count = 0;
for i = 1:length(elec)
    group_name = elec(i).name;
    ch.name = strcat(group_name, 'u');
    if ~ismember(ch.name, {elec(i).ch.name})
        fprintf('No microwire found for %-8s Estimating... \n', group_name)
        no_u_count = no_u_count + 1;

        macro1_name = strcat(group_name, '1');
        macro1_idx  = find(strcmp({elec(i).ch.name}, macro1_name));
        macro1_xyz  = [
            elec(i).ch(macro1_idx).x
            elec(i).ch(macro1_idx).y
            elec(i).ch(macro1_idx).z];
        
        macro2_name = strcat(group_name, '2');
        macro2_idx  = find(strcmp({elec(i).ch.name}, macro2_name));
        macro2_xyz  = [
            elec(i).ch(macro2_idx).x
            elec(i).ch(macro2_idx).y
            elec(i).ch(macro2_idx).z];

        % Compute unit vector using difference between macro 1 and 2
        diff_vec = macro1_xyz - macro2_xyz;
        unit_vec = diff_vec / sqrt(sum(diff_vec.^2));
        micro_xyz = macro1_xyz + unit_vec * micro_to_macro_dist;

        % Add microwire as a channel
        ch.x = micro_xyz(1);
        ch.y = micro_xyz(2);
        ch.z = micro_xyz(3);
        ch.group = ch.name;
        ch.type = 'microwire';
        ch.is_micro = true;

        elec(i).ch(end+1) = ch;
        fprintf('\t%s [%.2f, %.2f, %.2f]\n', ...
            ch.name, ch.x, ch.y, ch.z)
    end
end

%% Save new txt if micro estimation happened
if no_u_count ~= 0
    fprintf('%d microwire location estimated.\n', no_u_count)
else
    fprintf('Every bundle has microwire specified. No further operation.\n')
end

end