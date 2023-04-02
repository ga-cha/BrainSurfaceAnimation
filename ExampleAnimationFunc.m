function ExampleAnimationFunc(verts,faces,varargin)

p = inputParser;

validCell = @(x) iscell(x);
validFaces = @(x) ismatrix(x);
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
validMatrix = @(x) isnumeric(x) && ismatrix(x) && (size(x,1) == 1 || size(x,2) == 1);
validLogical = @(x) islogical(x);
validCmap = @(x) isnumeric(x) && size(x,2) == 3;
validAngle = @(x) isnumeric(x) && size(x,1) == 1 && size(x,2) == 2;

Nverts = size(verts{1},1);

defaultCmap = turbo(256);
default_vertData = zeros(Nverts,1);
default_vertParc = ones(Nverts,1);
default_frames = 30;
default_viewAngle = [-90 0];

addRequired(p,'verts',validCell)
addRequired(p,'faces',validFaces)
addOptional(p,'plotBoundary',true,validLogical);
addOptional(p,'boundaryWidth',2,validScalarPosNum);
addOptional(p,'frames',default_frames,validScalarPosNum);
addOptional(p,'vertData',default_vertData,validMatrix);
addOptional(p,'vertParc',default_vertParc,validMatrix);
addOptional(p,'colormap',defaultCmap,validCmap);
addOptional(p,'viewAngle',default_viewAngle,validAngle);
addOptional(p,'outdir',[],@isstring);

parse(p,verts,faces,varargin{:})

Nsurfaces = length(verts);

surface.vertices = verts{Nsurfaces};
surface.faces = faces;

plotBoundary = p.Results.plotBoundary;

vertData = p.Results.vertData;

if length(unique(vertData)) == 1 && max(vertData) == 0
    vertParc = zeros(Nverts,1);
else
    vertParc = p.Results.vertParc;
end

if ~p.Results.plotBoundary || length(unique(p.Results.vertParc)) == 1
    
    plotBoundary = false;
   [surf_patch,b] = plotSurfaceROIBoundary(surface,vertParc,vertData,'none',p.Results.colormap);
   
else

   [surf_patch,b] = plotSurfaceROIBoundary(surface,vertParc,vertData,'midpoint',p.Results.colormap,p.Results.boundaryWidth);  

end

camlight(80,-10);
camlight(-80,-10);
view(p.Results.viewAngle)
axis off
axis vis3d
axis tight
axis equal

% Freeze the axis limits

xlim manual
ylim manual
zlim manual

F = p.Results.frames;

r = linspace(0,1,F);

if ~isempty(p.Results.outdir)
   mkdir(p.Results.outdir) 
end

% Create the first frame
Iter = 1;

surf_patch.Vertices = verts{1};
if plotBoundary   
    delete(b.boundary)
    BOUNDARY = findROIboundaries(verts{1},surface.faces,p.Results.vertParc,'midpoint');
    for jj = 1:length(BOUNDARY)
       b.boundary(jj) = plot3(BOUNDARY{jj}(:,1), BOUNDARY{jj}(:,2), BOUNDARY{jj}(:,3), 'Color', 'k', 'LineWidth',p.Results.boundaryWidth,'Clipping','off');
    end
end

if ~isempty(p.Results.outdir)
    print([outdir,'/Frame',num2str(Iter),'.png'],'-dpng')
end

Iter = 2;
for i = 1:length(verts)-1

    for j = 1:F-1        
        newVerts = find_point_on_line(verts{i},verts{i+1},r(j+1));
        surf_patch.Vertices = newVerts;
        if plotBoundary
            delete(b.boundary)
            BOUNDARY = findROIboundaries(newVerts,surface.faces,p.Results.vertParc,'midpoint');
            for jj = 1:length(BOUNDARY)
               b.boundary(jj) = plot3(BOUNDARY{jj}(:,1), BOUNDARY{jj}(:,2), BOUNDARY{jj}(:,3), 'Color', 'k', 'LineWidth',p.Results.boundaryWidth,'Clipping','off');
            end
        end
        % pause for a split second, because sometimes it can continue
        % running before the frame as actually saved which messes things up
        pause(.1)
        if ~isempty(p.Results.outdir)
            print([outdir,'/Frame',num2str(Iter),'.png'],'-dpng')
        end
        Iter = Iter + 1;
    end
    
end