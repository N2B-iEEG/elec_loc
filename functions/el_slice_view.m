function el_slice_view(pat)

dir_slice = fullfile(pat.dir.el, 'slice_views');
if ~exist(dir_slice, 'dir')
    mkdir(dir_slice)
end

chs = [pat.elec.ch];

pat.t1.modality = 'T1w';
pat.ct.modality = 'CT';

fig = figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8]);
for scan = [pat.t1, pat.ct]

    img = scan.data;
    CLIM = [...
        min(img, [], "all"), ...
        max(img, [], "all"), ...
        ];
    
    for c = chs
        pos_mm = [c.x; c.y; c.z; 1];
        pos_vox = scan.mat \ pos_mm;
        pos_vox = round(pos_vox(1:3));

        x_slice = squeeze(img(pos_vox(1), :, :));
        y_slice = squeeze(img(:, pos_vox(2), :));
        z_slice = squeeze(img(:, :, pos_vox(3)));

        integrated = [...
            zeros(size(x_slice, 1), size(z_slice, 2)), x_slice;
            z_slice, y_slice];

        % Display the slices
        hold on
        imagesc(rot90(integrated, -1), CLIM);
        xline([ ...
            size(img, 1) - pos_vox(1), ... % On coronal and horizontal planes
            size(img, 1) + size(img, 2) - pos_vox(2), ... % On sagittal plane
            ], ...
            ':', 'Color', 'c', 'LineWidth', 0.5)
        yline([ ...
            pos_vox(2), ... % On horizontal plane
            pos_vox(3) + size(img, 2), ... % On coronal and sagittal planes
            ], ':', 'Color', 'c', 'LineWidth', 0.5)
        text(size(img, 1), size(img, 2), ...
            c.name, ...
            'FontSize', 15, 'Color', [.7 .7 .7], ...
            "Interpreter", "none", ...
            "HorizontalAlignment", "left", VerticalAlignment="top" ...
            )
        xlim([1, size(integrated, 1)]);
        ylim([1, size(integrated, 2)]);
        xticks([]);
        yticks([]);
        colormap gray;
        pbaspect([size(integrated, 1), size(integrated, 2), size(integrated, 3)])

        % Export figure
        exportgraphics(fig, ...
            fullfile(dir_slice, sprintf('sub-%s_%s_%s.jpg', ...
            pat.id, c.name, scan.modality)), ...
            "Resolution", 300, ...
            'Colorspace', 'gray')
        cla
    end
end
close(fig)