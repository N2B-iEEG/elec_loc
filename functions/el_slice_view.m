function el_slice_view(pat)

dir_slice = fullfile(pat.dir.el, 'slice_views');
if ~exist(dir_slice, 'dir')
    mkdir(dir_slice)
end

elec = [pat.elec.ch];
elec_radius = 10;

pat.t1.modality = 'T1w';
pat.ct.modality = 'CT';
fig = figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.8]);
for scan = [pat.t1, pat.ct]

    img = scan.data;
    CLIM = [...
        min(img, [], "all"), ...
        max(img, [], "all"), ...
        ];
    
    for e = elec
        mm_coords = [e.x; e.y; e.z; 1];

        voxel_coords = scan.mat \ mm_coords;
        voxel_coords = round(voxel_coords(1:3));

        x_slice = squeeze(img(voxel_coords(1), :, :));
        y_slice = squeeze(img(:, voxel_coords(2), :));
        z_slice = squeeze(img(:, :, voxel_coords(3)));

        integrated = [...
            zeros(size(x_slice, 1), size(z_slice, 2)), x_slice;
            z_slice, y_slice];

        % Display the slices
        hold on
        imagesc(rot90(integrated, -1), CLIM);
        xline([ ...
            size(img, 1) - voxel_coords(1), ...
            size(img, 1) + size(img, 2) - voxel_coords(2), ...
            ], ...
            ':', 'Color', 'c', 'LineWidth', 0.5)
        yline([ ...
            voxel_coords(2), ...
            voxel_coords(3) + size(img, 2), ...
            ], ':', 'Color', 'c', 'LineWidth', 0.5)
        text(size(img, 1), size(img, 2), ...
            e.name, ...
            'FontSize', 15, 'Color', [.7 .7 .7], ...
            "HorizontalAlignment", "left", VerticalAlignment="top")
        xlim([1, size(integrated, 1)]);
        ylim([1, size(integrated, 2)]);
        xticks([]);
        yticks([]);
        colormap gray;
        pbaspect([size(integrated, 1), size(integrated, 2), size(integrated, 3)])

        % Export figure
        exportgraphics(fig, ...
            fullfile(dir_slice, sprintf('sub-%s_%s_%s.jpg', ...
            pat.id, e.name, scan.modality)), ...
            "Resolution", 300, ...
            'Colorspace', 'gray')
        cla

    end
end