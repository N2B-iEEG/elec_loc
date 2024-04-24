function el_merge_mesh(pat)

white_l = fullfile(pat.dir, 'surf', 'lh.white');
white_r = fullfile(pat.dir, 'surf', 'rh.white');
white_m = fullfile(pat.dir, 'iel', 'bil_white.nv');

merge_mesh(white_l, white_r, white_m)

pial_l = fullfile(pat.dir, 'surf', 'lh.pial');
pial_r = fullfile(pat.dir, 'surf', 'rh.pial');
pial_m = fullfile(pat.dir, 'iel', 'bil_pial.nv');

merge_mesh(pial_l, pial_r, pial_m)

end

function merge_mesh(filename1,filename2,filename3)

% Adapted from BrainNet_MergeMesh()
% Written by Mingrui Xia
% Mail to Author:  <a href="mingruixia@gmail.com">Mingrui Xia</a>

[pathstr,name,ext] = fileparts(filename1);
[vertex1, faces1, vertex_number1, faces_number1] =loadpial(filename1);

[pathstr,name,ext] = fileparts(filename2);
[vertex2, faces2, vertex_number2, faces_number2] =loadpial(filename2);

surf.vertex_number=vertex_number1+vertex_number2;
surf.coord=[vertex1,vertex2];
surf.ntri=faces_number1+faces_number2;
surf.tri=[(faces1);(faces2+double(vertex_number1))];
%     surf.coord(3,:) = surf.coord(3,:) + 13;
%     surf.coord(2,:) = surf.coord(2,:) -13;

fid = fopen(filename3,'wt');
fprintf(fid,'%d\n',surf.vertex_number);
for i=1:surf.vertex_number
    fprintf(fid,'%f %f %f\n',surf.coord(1:3,i));
end
fprintf(fid, '%d\n', surf.ntri);
for i=1:surf.ntri
    fprintf(fid,'%d %d %d\n',surf.tri(i,1:3));
end
fclose(fid);
% msgbox('Mesh was successfully created!','Success','help');
fprintf('Merged mesh successfully saved at %s\n', filename3)

end

function [vertex, faces, vertex_number, face_number] =loadpial(filename)
fid = fopen(filename, 'rb', 'b') ;
b1 = fread(fid, 1, 'uchar') ;
b2 = fread(fid, 1, 'uchar') ;
b3 = fread(fid, 1, 'uchar') ;
magic = bitshift(b1, 16) + bitshift(b2,8) + b3 ;
fgets(fid);
fgets(fid);
v = fread(fid, 1, 'int32') ;
t = fread(fid, 1, 'int32') ;
vertex= fread(fid, [3 v], 'float32') ;
faces= fread(fid, [3 t], 'int32')' + 1 ;
fclose(fid) ;
vertex_number=size(vertex,2);
face_number=size(faces,1);

end