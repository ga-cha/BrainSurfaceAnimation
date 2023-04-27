function plotAnimation(verts, faces, rois, data, options)
%PLOTANIMATION Summary of this function goes here
%   Detailed explanation goes here
% verts = Vx3 xyz coordinated
% faces = Fx3 vert allcoations of each face
% rois = Vx1 rois allocation of each vertex
% data = VxT or RxT matrix of data to be plotted at each timepoint in the
% animation

if nargin<5; options = {}; end;

T = size(data, 2);

cellVerts = {1, T}; for ii = 1:T; cellVerts{ii} = verts; end

dataVerts = {1, T}; for ii = 1:T; dataVerts{ii} = data(:, ii); end

SurfMorphAnimation(cellVerts, faces, 'vertParc', rois, 'vertData', dataVerts, options{:});

end

