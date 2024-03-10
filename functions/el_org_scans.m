function pat = el_org_scans(pat, have_t2, org_mode)

arguments
    pat      struct
    have_t2  {mustBeNumericOrLogical}
    org_mode {mustBeMember(org_mode, {'i', 'r'})}
end

%% Folders and scans
if ~exist(pat.dir, 'dir')
    mkdir(pat.dir)
end

pat.dir_iel = fullfile(pat.dir, 'iel');
if ~exist(pat.dir_iel, 'dir')
    mkdir(pat.dir_iel)
end

sub_name = sprintf('sub-%s_', pat.id);

pat.t1.raw    = fullfile(pat.dir_iel, [sub_name, 'T1w_raw.nii']);
pat.t1.cent   = fullfile(pat.dir_iel, [sub_name, 'T1w_cent.nii']);
pat.t1.acpc   = fullfile(pat.dir_iel, [sub_name, 'T1w_cent_acpc.nii']);
pat.t1.deface = fullfile(pat.dir_iel, [sub_name, 'T1w_cent_acpc_deface.nii']);
pat.t1.final  = fullfile(pat.dir_iel, [sub_name, 'T1w.nii']);

pat.ct.raw    = fullfile(pat.dir_iel, [sub_name, 'CT_raw.nii']);
pat.ct.cent   = fullfile(pat.dir_iel, [sub_name, 'CT_cent.nii']);
pat.ct.coreg  = fullfile(pat.dir_iel, [sub_name, 'CT_cent_coreg.nii']);
pat.ct.deface = fullfile(pat.dir_iel, [sub_name, 'CT_cent_coreg_deface.nii']);
pat.ct.thres  = fullfile(pat.dir_iel, [sub_name, 'CT_cent_coreg_deface_thres.nii']);
pat.ct.final  = fullfile(pat.dir_iel, [sub_name, 'CT.nii']);

if have_t2
    pat.t2.raw    = fullfile(pat.dir_iel, [sub_name, 'T2w_raw.nii']);
    pat.t2.cent   = fullfile(pat.dir_iel, [sub_name, 'T2w_cent.nii']);
    pat.t2.coreg  = fullfile(pat.dir_iel, [sub_name, 'T2w_cent_coreg.nii']);
    pat.t2.deface = fullfile(pat.dir_iel, [sub_name, 'T2w_cent_coreg_deface.nii']);
    pat.t2.final  = fullfile(pat.dir_iel, [sub_name, 'T2w.nii']);
end

if have_t2
    dirs_files = [pat.t1.final; pat.ct.final; pat.t2.final];
else
    dirs_files = [pat.t1.final; pat.ct.final];
end

%% Read mode - check if final files exist
if strcmp(org_mode, 'r')

    for dir_file = dirs_files'
        if ~exist(dir_file{1})
            error( ...
                '%s does not exist. Please import/process scans', ...
                dir_file{1})
        end
    end

end

%% Import mode

if strcmp(org_mode, 'i')

    % Import T1
    [t1_name, t1_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
        'Select pre-op T1 MRI');
    cd(t1_dir)

    % Import CT
    [ct_name, ct_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
        'Select post-op CT');
    cd(ct_dir)

    % Import T2
    if have_t2
        [t2_name, t2_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
            'Select pre-op T2 MRI');
        cd(t2_dir)
        copyfile(fullfile(t2_dir, t2_name), pat.t2.raw)
    end

    copyfile(fullfile(t1_dir, t1_name), pat.t1.raw)
    copyfile(fullfile(ct_dir, ct_name), pat.ct.raw)

    % T1 preprocessing

    fprintf('**********PROCESSING T1**********\n\n')

    % Center, align to ACPC, and deface
    el_center(pat.t1.raw, pat.t1.cent, false);
    el_auto_acpc(pat.t1.cent, pat.t1.acpc);

    % Show deface instruction message box
    msg = msgbox(sprintf(['Next we will perform defacing.\n\n' ...
        'Once the computation is done, you will see the defaced (red) T1 scan ' ...
        'overlaid on top of the original scan (grayscale).\n\n' ...
        'If the result seems satisfactory, click "Overwrite the source file".\n\n' ...
        'If not, click "Bad result & disp file name"']), ...
        'T1 defacing', 'help');

    el_deface(pat.t1.acpc, pat.t1.deface);

    % CT preprocessing

    fprintf('**********PROCESSING CT**********\n\n')

    % Center, coregister, mask to deface
    el_center(pat.ct.raw, pat.ct.cent, false);
    el_coreg(pat.t1.acpc, pat.ct.cent, pat.ct.coreg);
    el_mask(pat.t1.deface, pat.ct.coreg, pat.ct.deface);

    % Determine optimal CT threshold
    nii_viewer(pat.ct.deface)
    opts.WindowStyle = 'normal';
    ct_thres = inputdlg('Enter optimal CT threshold to show only bones and electrodes', ...
        'CT thresholding', [1 40], {''}, opts);
    close all hidden

    % Threshold CT
    if ~isempty(ct_thres)
        el_thres(pat.ct.deface, pat.ct.thres, sprintf('i1.*(i1>%d)', str2double(ct_thres)))
    end

    % T2 preprocessing
    if have_t2

        fprintf('**********PROCESSING T2**********\n\n')

        % Center, coregister, mask to deface
        el_center(pat.t2.raw, pat.t2.cent, false);
        el_coreg(pat.t1.acpc, pat.t2.cent, pat.t2.coreg);
        el_mask(pat.t1.deface, pat.t2.coreg, pat.t2.deface);

    end

    % Check results in nii_viewer
    if have_t2

        nii_viewer( ...
            pat.t1.deface, ...
            {pat.t2.deface, pat.ct.thres})

    else

        nii_viewer( ...
            pat.t1.deface, ...
            {pat.ct.thres})

    end

    movefile(pat.t1.deface, pat.t1.final)
    movefile(pat.ct.thres, pat.ct.final)
    if have_t2
        movefile(pat.t2.deface, pat.t2.final)
    end

end

delete(fullfile(pat.dir_iel, sprintf('%s*_*.nii', sub_name)))

fprintf('Directories and files:\n')
disp(dirs_files)

end

