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

if ~exist(fullfile(pat.dir, 'mri'), 'dir')
    mkdir(fullfile(pat.dir, 'mri'))
end

pat.t1.orig_dir = fullfile(pat.dir, 'mri', 'orig');
if ~exist(pat.t1.orig_dir, 'dir')
    mkdir(pat.t1.orig_dir)
end
pat.t1.raw    = fullfile(pat.t1.orig_dir, 't1.nii');
pat.t1.cent   = fullfile(pat.t1.orig_dir, 't1_cent.nii');
pat.t1.acpc   = fullfile(pat.t1.orig_dir, 't1_cent_acpc.nii');
pat.t1.deface = fullfile(pat.t1.orig_dir, 't1_cent_acpc_deface.nii');

pat.ct.dir = fullfile(pat.dir, 'ct');
if ~exist(pat.ct.dir, 'dir')
    mkdir(pat.ct.dir)
end
pat.ct.raw    = fullfile(pat.ct.dir, 'ct.nii');
pat.ct.cent   = fullfile(pat.ct.dir, 'ct_cent.nii');
pat.ct.coreg  = fullfile(pat.ct.dir, 'ct_cent_coreg.nii');
pat.ct.deface = fullfile(pat.ct.dir, 'ct_cent_coreg_deface.nii');

pat.t2.dir = fullfile(pat.dir, 't2');
if ~exist(pat.t2.dir, 'dir')
    mkdir(pat.t2.dir)
end
if have_t2
    pat.t2.raw    = fullfile(pat.t2.dir, 't2.nii');
    pat.t2.cent   = fullfile(pat.t2.dir, 't2_cent.nii');
    pat.t2.coreg  = fullfile(pat.t2.dir, 't2_cent_coreg.nii');
    pat.t2.deface = fullfile(pat.t2.dir, 't2_cent_coreg_deface.nii');
end

dirs_files = [
    struct2cell(pat.t1);
    struct2cell(pat.ct);
    struct2cell(pat.t2)];

%% Read mode - check if all files exist
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
    copyfile(fullfile(t1_dir, t1_name), pat.t1.raw)

    % Import CT
    [ct_name, ct_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
        'Select post-op CT');
    copyfile(fullfile(ct_dir, ct_name), pat.ct.raw)

    % Import T2
    if have_t2
        [t2_name, t2_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
            'Select pre-op T2 MRI');
        copyfile(fullfile(t2_dir, t2_name), pat.t2.raw)
    end

    % T1 preprocessing

    % Center
    fprintf('Centering T1 scan\n')
    el_center(pat.t1.raw, pat.t1.cent);

    % AC-PC
    fprintf('Aligning T1 to AC-PC line\n')
    el_auto_acpc(pat.t1.cent, pat.t1.acpc);

    % Deface
    waitfor(msgbox(sprintf(['Next we will perform defacing.\n\n' ...
        'Once the computation is done, you will see the defaced (red) T1 scan ' ...
        'overlaid on top of the original scan (grayscale).\n\n' ...
        'If the result seems satisfactory, click "Overwrite the source file".\n\n' ...
        'If not, click "Bad result & disp file name"']), ...
        'T1 defacing'));
    fprintf('De-facing T1\n')
    el_deface(pat.t1.acpc, pat.t1.deface);

    % CT preprocessing

    % Center
    fprintf('Centering CT scan\n')
    el_center(pat.ct.raw, pat.ct.cent);

    % Co-registration
    fprintf('Coregistering CT to T1\n')
    el_coreg(pat.t1.acpc, pat.ct.cent, pat.ct.coreg);

    % Deface using T1 mask
    deface_mask(pat.t1.deface, pat.ct.coreg, pat.ct.deface);

    % T2 preprocessing
    if have_t2

        % Center
        fprintf('Centering T2 scan\n')
        el_center(pat.t2.raw, pat.t2.cent);

        % Co-registration
        fprintf('Coregistering T2 to T1\n')
        el_coreg(pat.t1.acpc, pat.t2.cent, pat.t2.coreg);

        % Deface using T1 mask
        deface_mask(pat.t1.deface, pat.t2.coreg, pat.t2.deface);

    end

    % Check results in nii_viewer
    if have_t2

        waitfor(nii_viewer( ...
            pat.t1.deface, ...
            {pat.t2.deface, pat.ct.deface}))

    else

        waitfor(nii_viewer( ...
            pat.t1.deface, ...
            {pat.ct.deface}))

    end

end

fprintf('Directories and files:\n')
disp(dirs_files)

end

function deface_mask(t1_def, other_path, other_def_path)

[pth,nm,ext,num] = spm_fileparts(other_path);
spm_o_path = fullfile(pth, strcat('m', nm, ext, num));

Vi = [spm_vol(char(t1_def)), spm_vol(char(other_path))];

spm_imcalc(Vi, char(other_def_path), '(i1~=0).*i2');

end