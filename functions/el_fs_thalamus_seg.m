function el_fs_thalamus_seg(cfg, pat)

bash_code = fs_setup_code(cfg);

bash_code = sprintf('%s; segmentThalamicNuclei.sh %s', ...
        bash_code, pat.id);

system(bash_code);

end