function elec = el_bipolar(elec)
%el_bipolar Calculates the location of a bipolar montage from depth electrodes
%   Detailed explanation goes here

for i = 1:length(elec)
    group_name = elec(i).name;

    % Get the data of electrodes that are not micro
    depth_loc = find(~vertcat(elec(i).ch.is_micro));

    % Generate the names of bipolar electrodes
    names = {elec(i).ch.name};
    elec_idx = regexp(names, '(\d+)$', 'tokens');
    % Check that no electrode number is larger than 10
    if str2double(elec_idx{1}{1}{1}) > 10
        for j = 1:length(elec_idx)
            if isempty(elec_idx{j})
                continue
            end
            elec_idx{j}{1}{1} = elec_idx{j}{1}{1}(2:end);
        end
    end

    name_bipolar = {};
    for j = 1:(length(depth_loc)-1)
        idx = depth_loc(j);
        name_bipolar{j} = strcat(elec(i).ch(idx).group,...
                                elec_idx{idx}{1}{1},...
                                '-',...
                                elec_idx{idx+1}{1}{1});
    end

    % Calculate the mean location for adjacent contacts
    x_locs = horzcat(elec(i).ch(depth_loc).x);
    x_bipolar = num2cell(mean([x_locs(1:end-1); x_locs(2:end)]));

    y_locs = horzcat(elec(i).ch(depth_loc).y);
    y_bipolar = num2cell(mean([y_locs(1:end-1); y_locs(2:end)]));

    z_locs = horzcat(elec(i).ch(depth_loc).z);
    z_bipolar = num2cell(mean([z_locs(1:end-1); z_locs(2:end)]));

    group = repmat(strcat(group_name, '_bipolar'), length(depth_loc)-1, 1);
    type = repmat('bipolar', length(depth_loc)-1, 1);
    is_micro = logical(zeros(length(depth_loc)-1, 1));

    all_cell = [name_bipolar;...
                x_bipolar;...
                y_bipolar;...
                z_bipolar;...
                cellstr(group)';...
                cellstr(type)';...
                num2cell(is_micro)'];
    fields = {'name';...
                'x';...
                'y';...
                'z';...
                'group';...
                'type';...
                'is_micro'};
    
    ch = cell2struct(all_cell,fields)';
    elec(i).ch = [elec(i).ch, ch];
    
    fprintf('Estimated location for depth electrode \t%s\n', ...
            group_name)
end
    
end