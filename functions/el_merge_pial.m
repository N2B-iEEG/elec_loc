function el_merge_pial(pat)

pial_l = fullfile(pat.dir, 'surf', 'lh.pial');
pial_r = fullfile(pat.dir, 'surf', 'rh.pial');
pial_m = fullfile(pat.dir, 'iel', 'merged.nv');

merge_pial(pial_l, pial_r, pial_m)

end