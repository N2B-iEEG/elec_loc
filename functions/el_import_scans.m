function pat = el_import_scans(pat)

arguments
    pat struct
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

pat.t1.cent   = fullfile(pat.dir_iel, ['temp_' sub_name, 'T1w_cent.nii']);
pat.t1.acpc   = fullfile(pat.dir_iel, ['temp_' sub_name, 'T1w_cent_acpc.nii']);
pat.t1.deface = fullfile(pat.dir_iel, ['temp_' sub_name, 'T1w_cent_acpc_deface.nii']);
pat.t1.final  = fullfile(pat.dir_iel, [sub_name, 'T1w.nii']);

pat.ct.cent   = fullfile(pat.dir_iel, ['temp_' sub_name, 'CT_cent.nii']);
pat.ct.coreg  = fullfile(pat.dir_iel, ['temp_' sub_name, 'CT_cent_coreg.nii']);
pat.ct.deface = fullfile(pat.dir_iel, ['temp_' sub_name, 'CT_cent_coreg_deface.nii']);
pat.ct.thres  = fullfile(pat.dir_iel, ['temp_' sub_name, 'CT_cent_coreg_deface_thres.nii']);
pat.ct.final  = fullfile(pat.dir_iel, [sub_name, 'CT.nii']);

pat.t2.cent   = fullfile(pat.dir_iel, ['temp_' sub_name, 'T2w_cent.nii']);
pat.t2.coreg  = fullfile(pat.dir_iel, ['temp_' sub_name, 'T2w_cent_coreg.nii']);
pat.t2.deface = fullfile(pat.dir_iel, ['temp_' sub_name, 'T2w_cent_coreg_deface.nii']);
pat.t2.final  = fullfile(pat.dir_iel, [sub_name, 'T2w.nii']);

% Check if final files exist
if ~exist(pat.t1.final, 'file') || ~exist(pat.ct.final, 'file')
    fprintf('%s preprocessed scans not found. Importing...\n', pat.id)
    import = true;
else
    % Ask whether to re-import
    import_quest = questdlg( ...
        'Preprocessed scans already exist. Re-import?', ...
        'el_org_scans', ...
        'Load existing scans', ...
        'Re-import from scratch', ...
        'Use existing scans');
    if strcmp(import_quest, 'Re-import from scratch')
        import = true;
    else
        import = false;
        have_t2 = exist(pat.t2.final, 'file');
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
        
        pat.t1.raw = el_dcm2nii(pat, 'T1');
        pat.ct.raw = el_dcm2nii(pat, 'CT');
        if have_t2
            pat.t2.raw = el_dcm2nii(pat, 'T2');
        end

    else
        % T1
        [t1_name, t1_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
            'Select pre-op T1 MRI');
        if isnumeric(t1_name)
            error('No file selected')
        end
        cd(t1_dir)
        pat.t1.raw = fullfile(t1_dir, t1_name);

        % CT
        [ct_name, ct_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
            'Select post-op CT');
        if isnumeric(ct_name)
            error('No file selected')
        end
        cd(ct_dir)
        pat.ct.raw = fullfile(ct_dir, ct_name);

        % T2
        if have_t2
            [t2_name, t2_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
                'Select pre-op T2 MRI');
            if isnumeric(t2_name)
                error('No file selected')
            end
            cd(t2_dir)
            pat.t2.raw = fullfile(t2_dir, t2_name);
        end

    end


    % T1 preprocessing

    fprintf('**********PROCESSING T1**********\n\n')

    % Center, align to ACPC, and deface
    el_center(pat.t1.raw, pat.t1.cent, false);
    el_auto_acpc(pat.t1.cent, pat.t1.acpc);

    % Show deface instruction message box
    msg = msgbox(sprintf(['Defacing of T1 is now in progress.\n\n' ...
        'Once the computation is done, you will see the defaced (red) T1 scan ' ...
        'overlaid on top of the original scan (grayscale).\n\n' ...
        'If the result seems satisfactory, click "Overwrite the source file".\n\n' ...
        'If not, click "Bad result & disp file name"']), ...
        'T1 defacing', 'help');
    msg.Units = 'normalized';
    msg.Position = [0 0.35 0.4 0.3];
    fontsize(msg, 12,"points")

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

    movefile(pat.t1.deface, pat.t1.final)
    movefile(pat.ct.thres, pat.ct.final)
    if have_t2
        movefile(pat.t2.deface, pat.t2.final)
    end

    delete(fullfile(pat.dir_iel, 'temp*.nii'))

end

% Check results in nii_viewer
if have_t2
    nii_viewer( ...
        pat.t1.final, ...
        {pat.t2.final, pat.ct.final})
else
    nii_viewer( ...
        pat.t1.final, ...
        {pat.ct.final})
end

files = dir(fullfile(pat.dir_iel, '*.nii'));
fprintf('Preprocessed files:\n')
for f = files'
    gzip(fullfile(pat.dir_iel, f.name))
    fprintf('\t%s\n', f.name)
end

end