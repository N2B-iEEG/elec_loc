function el_fs_hpc_amy_seg(config, pat, seg_option)

if strcmp(seg_option, 'None')
    return
end

bash_code = fs_setup_code(config);

if strcmp(seg_option, 'T1')

    bash_code = sprintf('%s; segmentHA_T1.sh %s', ...
        bash_code, pat.name);

elseif strcmp(seg_option, 'T2')

    % segmentHA_T2.sh bert FILE_ADDITIONAL_SCAN ANALYSIS_ID USE_T1
    bash_code = sprintf('%s; segmentHA_T2.sh %s %s T2 0', ...
        bash_code, pat.name, pat.t2.deface);

elseif strcmp(seg_option, 'T1+T2')

    bash_code = sprintf('%s; segmentHA_T2.sh %s %s T1_T2 1', ...
        bash_code, pat.name, pat.t2.deface);

end

system(bash_code);

end