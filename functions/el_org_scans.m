function pat = el_org_scans(pat)

arguments
    pat struct
end

%% Create folders
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

pat.ct.dir = fullfile(pat.dir, 'ct');
if ~exist(pat.ct.dir, 'dir')
    mkdir(pat.ct.dir)
end

pat.t2.dir = fullfile(pat.dir, 't2');
if ~exist(pat.t2.dir, 'dir')
    mkdir(pat.t2.dir)
end

%% Get files
[t1_name, t1_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
    'Select pre-op T1 MRI');
pat.t1.raw = fullfile(pat.t1.orig_dir, 't1.nii');
copyfile(fullfile(t1_dir, t1_name), pat.t1.raw)

[ct_name, ct_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
    'Select post-op CT');
pat.ct.raw = fullfile(pat.ct.dir, 'ct.nii');
copyfile(fullfile(ct_dir, ct_name), pat.ct.raw)

if_t2 = questdlg( ...
    'Do you have a T2 scan to load?', ...
    'el_org_scans', ...
    'Yes', ...
    'No', ...
    'No');

if strcmp(if_t2, 'Yes')
    [t2_name, t2_dir] = uigetfile({'*.nii; *.nii.gz; *.mgz'}, ...
        'Select pre-op T2 MRI');
    pat.t2.raw = fullfile(pat.t2.dir, 't2.nii');
    copyfile(fullfile(t2_dir, t2_name), pat.t2.raw)
end

%% T1 preprocessing
% Center
fprintf('Centering T1 scan\n')
pat.t1.cent = el_center(pat.t1.raw);
% AC-PC
fprintf('Aligning T1 to AC-PC line\n')
pat.t1.acpc = el_auto_acpc(pat.t1.cent);
% Deface
waitfor(msgbox(sprintf(['Next we will perform defacing.\n\n' ...
    'Once the computation is done, you will see the defaced (red) file ' ...
    'overlaid on top of the original file (grayscale).\n\n' ...
    'If the result seems satisfactory, click "Overwrite the source file".\n\n' ...
    'If not, click "Bad result & disp file name"']), ...
    'T1 defacing'));
fprintf('De-facing T1\n')
pat.t1.deface = el_deface(pat.t1.acpc);

%% CT preprocessing
% Center
fprintf('Centering CT scan\n')
pat.ct.cent = el_center(pat.ct.raw);
% Co-registration
fprintf('Coregistering CT to T1\n')
pat.ct.coreg = el_coreg(pat.t1.acpc, pat.ct.cent);
% Deface using T1 mask
pat.ct.deface = deface_mask(pat.t1.deface, pat.ct.coreg);

%% T2 preprocessing
if strcmp(if_t2, 'Yes')
    % Center
    fprintf('Centering T2 scan\n')
    pat.t2.cent = el_center(pat.t2.raw);
    % Co-registration
    fprintf('Coregistering T2 to T1\n')
    pat.t2.coreg = el_coreg(pat.t1.acpc, pat.t2.cent);
    % Deface using T1 mask
    pat.t2.deface = deface_mask(pat.t1.deface, pat.t2.coreg);
end

%% Check results in nii_viewer
switch if_t2
    case 'Yes'
        waitfor(nii_viewer(pat.t1.deface, ...
            {pat.t2.deface, pat.ct.deface}))
    case 'No'
        waitfor(nii_viewer(pat.t1.deface, ...
            {pat.ct.deface}))
end

end

function other_def_path = deface_mask(t1_def, other_path)

[pth,nm,ext,num] = spm_fileparts(other_path);
spm_o_path = fullfile(pth, strcat('m', nm, ext, num));

other_def_path = strrep(other_path, '.nii', '_deface.nii');

Vi = [spm_vol(char(t1_def)), spm_vol(char(other_path))];

spm_imcalc(Vi, char(other_def_path), '(i1~=0).*i2');

end