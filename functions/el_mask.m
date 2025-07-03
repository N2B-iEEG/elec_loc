function el_mask(ref_path, source_path, out_path)

fprintf('>> el_mask\n\tREFERENCE: %s\n\tSOURCE: %s\n\tOUTPUT: %s\n', ...
    ref_path, source_path, out_path)

Vi = [spm_vol(char(source_path)), spm_vol(char(ref_path))];

spm_imcalc(Vi, char(out_path), '(i2~=0).*i1');

fprintf('Done\n')

end