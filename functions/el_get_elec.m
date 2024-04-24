function elec = el_get_elec(pat)

[iel_fn, iel_dir] = uigetfile(fullfile(pat.dir_iel, '*.iel'), ...
    'Select iElectrodes project');
iel_path = fullfile(iel_dir, iel_fn);

iel_s = load(iel_path, '-mat');
elec_c = iel_s.s.electrodes;

elec = struct;
for i = 1:length(elec_c)
    elec(i).name = elec_c{i}.Name;
    elec(i).type = elec_c{i}.Type;
    for j = 1:elec_c{i}.nElectrodes
        elec(i).ch(j).name = elec_c{i}.ch_label{j};
        elec(i).ch(j).x    = elec_c{i}.x(j);
        elec(i).ch(j).y    = elec_c{i}.y(j);
        elec(i).ch(j).z    = elec_c{i}.z(j);
        elec(i).ch(j).is_micro = false;
    end
    fprintf('Electrode group: %s\n\t%s\n', ...
        elec(i).name, ...
        string(join({elec(i).ch.name}, ' | ')))
end

end