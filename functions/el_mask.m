function el_mask(ref_path, other_path, other_mask_path)

fprintf('>>>>>Masking %s according to %s\n', ...
    other_path, ref_path)

[pth,nm,ext,num] = spm_fileparts(other_path);
spm_o_path = fullfile(pth, strcat('m', nm, ext, num));

Vi = [spm_vol(char(ref_path)), spm_vol(char(other_path))];

spm_imcalc(Vi, char(other_mask_path), '(i1~=0).*i2');

fprintf('\n>>>>>Masked scan saved at %s\n\n', other_mask_path)

end