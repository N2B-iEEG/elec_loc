function el_thres(input_path, output_path, expr)

fprintf('>>>>>Thresholding %s according to %s\n', ...
    input_path, expr)

Vi = spm_vol(char(input_path));

spm_imcalc(Vi, char(output_path), expr)

fprintf('\n>>>>>Thresholded scan saved at %s\n\n', output_path)

end