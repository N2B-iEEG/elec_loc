function el_deface(in_path, out_path)

fprintf('>> el_deface\n\tINPUT: %s\n\tOUTPUT: %s\n', in_path, out_path)

% Create copy if input and output paths are different
if ~strcmp(in_path, out_path)
    copyfile(in_path, out_path)
end

% Defacing
el_nii_deface(out_path)
fprintf('Done\n')

end

% The following function is an adaptation of `nii_deface()` from
% `dicm2nii` by Xiangrui Li. It was modified to automate the defacing
% process.
function el_nii_deface(in)
% Syntax: NII_DEFACE(in)
%  input can be a single anat 3D NIfTI, or BIDS folder containing sub-* folders.
%  If no input is provided, a file/folder dialog will pop up.
%
% NII_DEFACE removes face and neck structure from T1w/T2w NIfTI.
%
% How does this code deface?
%  1. A xform matrix is estimated for normalizing an anat image to MNI template
%  2. MNI deface mask, which includes brain and scalp but without neck and face,
%     is transformed to the subject reference using the above xform matrix
%  3. Voxels outside the transformed mask is set to zeros
%  4. A GUI gives options to overwrite the file etc.
%
% Potential benefit over other defacing tools:
%  1. Except zeroing some voxels, nothing else of the NIfTI is altered.
%  2. Most neck tissue is removed, which reduces the chance of error for the
%     anatomical analysis for some tools.
%  3. File size is significantly reduced for .gz version.
%
% See also NII_TOOL NII_COREG NII_VIEWER NII_XFORM

% 230415 Wrote it by Xiangrui.Li@gmail.com

f = fileparts(which('nii_viewer'));
niiT1 = nii_tool('load', [f '/templates/MNI_2mm_T1.nii']);
niiT2 = nii_tool('load', [f '/templates/MNI_2mm_T2.nii']);
msk = load([f '/example_data.mat'], 'MNI_2mm_deface_mask');
msk = msk.MNI_2mm_deface_mask; % enlarged brain+scalp mask

% deface1(in, niiT1, niiT2, msk);

niiM = nii_tool('load', in);
if endsWith(in, 'T2w.nii.gz')
    niiT = niiT2;
else
    niiT = niiT1;
end
[M, mss] = nii_coreg(niiT, niiM);
if mss>0.5, warning('nii_deface:AlignBad', 'Alignment unreliable: %s', in); end
M = M \ [msk.hdr.sform_mat; 0 0 0 1];
msk = nii_tool('update', msk, M);
msk.hdr.sform_code = niiM.hdr.sform_code;
msk = nii_xform(msk, niiM.hdr, [], 'nearest', 0);
nii = niiM;
slp = nii.hdr.scl_slope; if slp==0, slp = 1; end
nii.img(~msk.img) = -nii.hdr.scl_inter/slp; % set outside to 0

nii_tool('save', nii);

end