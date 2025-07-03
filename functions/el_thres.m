function el_thres(in_path, out_path, expr)

fprintf('>> el_thres\n\tINPUT: %s\n\tOUTPUT: %s\n\tEXPRESSION: %s\n', ...
    in_path, out_path, expr)

Vi = spm_vol(char(in_path));

spm_imcalc(Vi, char(out_path), expr);

fprintf('Done\n')

end