function pat = el_import_scans(pat)

%% Scans
sub_name = sprintf('sub-%s_', pat.id);

pat_t1.cent   = fullfile(pat.dir.el, ['temp_' sub_name, 'T1w_cent.nii']);
pat_t1.acpc   = fullfile(pat.dir.el, ['temp_' sub_name, 'T1w_cent_acpc.nii']);
pat_t1.deface = fullfile(pat.dir.el, ['temp_' sub_name, 'T1w_cent_acpc_deface.nii']);
pat.t1.image  = fullfile(pat.dir.el, [sub_name, 'acq-preop_T1w.nii']);

pat_ct.cent   = fullfile(pat.dir.el, ['temp_' sub_name, 'CT_cent.nii']);
pat_ct.coreg  = fullfile(pat.dir.el, ['temp_' sub_name, 'CT_cent_coreg.nii']);
pat_ct.deface = fullfile(pat.dir.el, ['temp_' sub_name, 'CT_cent_coreg_deface.nii']);
pat_ct.thres  = fullfile(pat.dir.el, ['temp_' sub_name, 'CT_cent_coreg_deface_thres.nii']);
pat.ct.image  = fullfile(pat.dir.el, [sub_name, 'acq-postop_CT.nii']);

pat_t2.cent   = fullfile(pat.dir.el, ['temp_' sub_name, 'T2w_cent.nii']);
pat_t2.coreg  = fullfile(pat.dir.el, ['temp_' sub_name, 'T2w_cent_coreg.nii']);
pat_t2.deface = fullfile(pat.dir.el, ['temp_' sub_name, 'T2w_cent_coreg_deface.nii']);
pat.t2.image  = fullfile(pat.dir.el, [sub_name, 'acq-preop_T2w.nii']);

% Check if final files exist
if ~exist(pat.t1.image, 'file') || ~exist(pat.ct.image, 'file')
    fprintf('%s preprocessed scans not found. Importing...\n', pat.id)
    import = true;
else
    % Ask whether to re-import
    import_quest = questdlg( ...
        'Preprocessed scans already exist. Re-import?', ...
        'el_org_scans', ...
        'Load existing scans', ...
        'Re-import from scratch', ...
        'Load existing scans');
    if strcmp(import_quest, 'Re-import from scratch')
        import = true;
    else
        import = false;
        have_t2 = exist(pat.t2.image, 'file');
    end
end

% Import mode
if import

    % Ask whether to import T2
    have_t2_quest = questdlg( ...
        'Import T2 scan?', ...
        'Import T2', ...
        'Yes', ...
        'No', ...
        'Yes');
    if strcmp(have_t2_quest, 'Yes')
        have_t2 = true;
    else
        have_t2 = false;
    end

    % Import DICOM or NIFTI
    dcm_nii_quest = questdlg( ...
        'What type of files to import?', ...
        'Import file type', ...
        'DICOM (a folder of .dcm)', ...
        'NIFTI (a single .nii file)', ...
        'DICOM (a folder of .dcm)');
    if strcmp(dcm_nii_quest, 'DICOM (a folder of .dcm)')
        dcm = true;
    else
        dcm = false;
    end

    if dcm

        pat_t1.raw = el_dcm2nii(pat, 'T1');
        pat_ct.raw = el_dcm2nii(pat, 'CT');
        if have_t2
            pat_t2.raw = el_dcm2nii(pat, 'T2');
        end

    else
        % T1
        [t1_name, t1_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
            'Select pre-op T1 MRI');
        if isnumeric(t1_name)
            error('No file selected')
        end
        cd(t1_dir)
        pat_t1.raw = fullfile(t1_dir, t1_name);

        % CT
        [ct_name, ct_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
            'Select post-op CT');
        if isnumeric(ct_name)
            error('No file selected')
        end
        cd(ct_dir)
        pat_ct.raw = fullfile(ct_dir, ct_name);

        % T2
        if have_t2
            [t2_name, t2_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
                'Select pre-op T2 MRI');
            if isnumeric(t2_name)
                error('No file selected')
            end
            cd(t2_dir)
            pat_t2.raw = fullfile(t2_dir, t2_name);
        end

    end


    % T1 preprocessing

    fprintf('**********PROCESSING T1**********\n\n')

    % Center, align to ACPC, and deface
    el_center(pat_t1.raw, pat_t1.cent, false);
    el_auto_acpc(pat_t1.cent, pat_t1.acpc);

    % Show deface instruction message box
    msg = msgbox(sprintf(['Defacing of T1 is now in progress.\n\n' ...
        'Once the computation is done, you will see the defaced (red) T1 scan ' ...
        'overlaid on top of the original scan (grayscale).\n\n' ...
        'If the result seems satisfactory, click "Overwrite the source file".\n\n' ...
        'If not, click "Bad result & disp file name"']), ...
        'T1 defacing', ...
        'help');

    el_deface(pat_t1.acpc, pat_t1.deface);

    % CT preprocessing

    fprintf('**********PROCESSING CT**********\n\n')

    % Center, coregister, mask to deface
    el_center(pat_ct.raw, pat_ct.cent, false);
    el_coreg(pat_t1.acpc, pat_ct.cent, pat_ct.coreg);
    el_mask(pat_t1.deface, pat_ct.coreg, pat_ct.deface);

    % Determine optimal CT threshold
    nii_viewer(pat_ct.deface)
    opts.WindowStyle = 'normal';
    ct_thres = NaN;
    while isnan(ct_thres)
        ct_thres = inputdlg('Enter optimal CT threshold to show only bones and electrodes', ...
            'CT thresholding', [1 40], "300", opts);
        ct_thres = str2double(ct_thres);
    end
    close all hidden

    % Threshold CT
    if ~isempty(ct_thres)
        el_thres(pat_ct.deface, pat_ct.thres, sprintf('i1.*(i1>%d)', ct_thres))
    end

    % T2 preprocessing
    if have_t2

        fprintf('**********PROCESSING T2**********\n\n')

        % Center, coregister, mask to deface
        el_center(pat_t2.raw, pat_t2.cent, false);
        el_coreg(pat_t1.acpc, pat_t2.cent, pat_t2.coreg);
        el_mask(pat_t1.deface, pat_t2.coreg, pat_t2.deface);

    end

    movefile(pat_t1.deface, pat.t1.image)
    gzip(pat.t1.image, pat.dir.el_bids_anat)
    movefile(pat_ct.thres, pat.ct.image)
    gzip(pat.ct.image, pat.dir.el_bids_anat)
    if have_t2
        movefile(pat_t2.deface, pat.t2.image)
        gzip(pat.t2.image, pat.dir.el_bids_anat)
    end

    delete(fullfile(pat.dir.el, 'temp*.nii'))

end

% Check results in nii_viewer
fprintf('Preprocessed files:\n')
fprintf('\t%s\n\t%s\n', pat.t1.image, pat.ct.image)
if have_t2
    fprintf('\t%s\n', pat.t2.image)
    nii_viewer( ...
        pat.t1.image, ...
        {pat.t2.image, pat.ct.image})
else
    nii_viewer( ...
        pat.t1.image, ...
        {pat.ct.image})
end

end