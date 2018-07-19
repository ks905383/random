% MAP_VALUES    easily map data projected onto polygons
%
%   fig = MAP_VALUES(geo_struct,map_var) will return a figure (with handle
%   [fig]) showing the polygons contained in [geo_struct], colored by the
%   values in [map_var]. [map_var] must be a vector with a length equal to
%   the number of elements in [geo_struct]. [geo_struct] must be a standard
%   MATLAB polygon struct, with fields .Geometry = 'Polygon' and either .X
%   and .Y or .Lat and .Lon. By default MAP_VALUES uses MAPSHOW and
%   flipud(jet(18)) as a colormap, but these can be changed in the flags
%   below. 
%
%   fig = MAP_VALUES(array_var,lat,lon)
%
%   MAP_VALUES(...,'[flag]',[params],...) modify program run as below:
%       'fig_type',[char]       - possible options: 'map' (default) and
%                                 'geo'. If set to 'map', then MAPSHOW is
%                                 used, if set to 'geo', then GEOSHOW is
%                                 used. Both are useable regardless of
%                                 whether [geo_struct] has coordinates in
%                                 .X/.Y or .Lat/.Lon format - if a mismatch
%                                 is detected, the coordinates are just
%                                 remapped onto fields with the correct
%                                 names for the mapping function used.
%       'show_coasts',[log]     - set whether to show the outlines of major
%                                 coasts. By default false. If true,
%                                 MAP_VALUES uses the base MATLAB
%                                 'coast.mat' file to draw the coasts.
%       'projection',[char]     - change the projection of the map *if*
%                                 setting 'fig_type' to 'geo' (does nothing
%                                 if 'fig_type' is 'map'). By default
%                                 'bsam' (Bolshoi-Sovietskii Atlas Mira).
%       'axis_lims',[num]       - manually set axis limits in the form 
%                                 [xmin xmax ymin ymax].
%       'title',[char]/[cell]   - set a title for the figure (use a cell
%                                 array if you want it to include a line
%                                 split). 
%       'colobar_label',[char]  - set a label for the colorbar.
%       'colormap',[num]/[char] - manually set the colormap. It can be
%                                 either a [ncolors x 3] RGB array or a
%                                 string giving the name of a built-in
%                                 MATLAB colormap or any other valid input
%                                 to the function DATA_COLORMAP. Be sure to
%                                 set the desired number of colors in the
%                                 'color_split' flag regardless of the
%                                 length of the 'colormap' input.
%       'caxis',[num]           - manually set the color range, in a 2x1
%                                 vector giving minimum and maximum values
%                                 for the colormap.
%       'color_split',[int]     - choose how many discrete colors should be
%                                 used in the colormap (by default 18). 
%
%   See also DATA_COLORMAP, MAPSHOW, GEOSHOW
%                                   
%   For questions/comments, contact Kevin Schwarzwald
%   kschwarzwald@uchicago.edu
%   Last modified 01/11/2018

function varargout = map_values(geo_struct,map_var,varargin)
%% Setup
addpath ~/Documents/code_general/ %To get data_colormap

fig_type = 'map';
show_coasts = false;
proj = 'bsam';
cust_axis_lims = [];
color_split = 18;
title_string = [];
colorbar_label = [];
colormap_set = flipud(jet);
lat_bnds = [];
lon_bnds = [];
creation = 'figure';

if isa(geo_struct,'numeric')
    gen_struct = true;
    lat = map_var;
    lon = varargin{1};
    varargin = varargin(2:end);
    map_var = geo_struct; clear geo_struct
else
    gen_struct = false;
end

%% Set behavior of optional function flags
if (~isempty(varargin))
    for in_idx = 1:length(varargin)
        switch varargin{in_idx}
            %Creation type
            case {'subplot'}
                creation = 'subplot';
            %Data processing
            case {'fig_type'}
                fig_type = varargin{in_idx+1};
            case {'show_coasts'}
                show_coasts = varargin{in_idx+1};
            case {'projection'}
                proj = varargin{in_idx+1};
            case {'axis_lims'}
                cust_axis_lims = varargin{in_idx+1}; varargin{in_idx+1} = 0;
            case {'title'}
                title_string = varargin{in_idx+1}; varargin{in_idx+1} = 0;
            case {'colorbar_label'}
                colorbar_label = varargin{in_idx+1};
            case {'colormap'}
                colormap_set = varargin{in_idx+1}; varargin{in_idx+1} = 0;
            case {'caxis'}
                caxis_set = varargin{in_idx+1}; varargin{in_idx+1} = 0;
            case {'color_split'}
                color_split = varargin{in_idx+1};
            case {'bounds'}
                lat_bnds = varargin{in_idx+1}; varargin{in_idx+1} = 0;
                lon_bnds = varargin{in_idx+2}; varargin{in_idx+2} = 0;
        end
    end
end


if gen_struct
    %% Generate polygon for each pixel
    %Get total number of pixels (supporting both vector and matrix grids)
    if size(lon,2)==1
        num_pixels = length(lon)*length(lat);
    else
        num_pixels = numel(lon);
    end
    %Get lat/lon bnds if necessary
    if isempty(lat_bnds)
        [lat_bnds,lon_bnds] = derive_bnds(lat,lon);
    end
    %Preallocate struct
    geo_struct(num_pixels).Lat = 0;
    %Generate struct for each pixel
    for poly_idx = 1:num_pixels
        if size(lon,2) == 1
            [lon_idx,lat_idx] = ind2sub([length(lon) length(lat)],poly_idx);
        else %for matrix geographic grids, the linear index is already the correct one
            lon_idx = poly_idx; lat_idx = poly_idx;
        end
        %pix_polys(poly_idx).Lat = [lat_bnds(lat_idx,1); lat_bnds(lat_idx,2); lat_bnds(lat_idx,2); lat_bnds(lat_idx,1); lat_bnds(lat_idx,1);NaN];
        %pix_polys(poly_idx).Lon = [lon_bnds(lon_idx,1); lon_bnds(lon_idx,1); lon_bnds(lon_idx,2); lon_bnds(lon_idx,2); lon_bnds(lon_idx,1);NaN];
        geo_struct(poly_idx).Lat = [lat_bnds(lat_idx,1); lat_bnds(lat_idx,1); lat_bnds(lat_idx,2); lat_bnds(lat_idx,2); lat_bnds(lat_idx,1);NaN];
        geo_struct(poly_idx).Lon = [lon_bnds(lon_idx,1); lon_bnds(lon_idx,2); lon_bnds(lon_idx,2); lon_bnds(lon_idx,1); lon_bnds(lon_idx,1);NaN];
        geo_struct(poly_idx).Geometry = 'Polygon';
    end
end


[plot_colors,cmap,c_range] = data_colormap(map_var,color_split,'colormap',colormap_set);
color_atts = makesymbolspec('Polygon',{'INDEX',[1 numel(geo_struct)],'FaceColor',plot_colors,'LineStyle','none'});

if strcmp(creation,'figure')
    fig = figure();
end

colormap(cmap);
caxis(c_range);

if strcmp(fig_type,'map')
    %Fortify coordinates to be inputs for the desired mapping function
    if all(~contains(fieldnames(geo_struct),'X'))
        if any(~contains(fieldnames(geo_struct),'Lat'))
            for i = 1:numel(geo_struct)
                geo_struct(i).X = geo_struct(i).Lon;
                geo_struct(i).Y = geo_struct(i).Lat;
            end
        else
            error('MAPVALUES:NoCoords','No fields ''X'', ''Y'', or ''Lat'', ''Lon'' found in the inputted [geo_struct]. Please reinput with coordinates in that format.')
        end
    end
    %Map
    mapshow(geo_struct,'SymbolSpec',color_atts);
    %Add outlines of coasts, if desired
    if show_coasts
        coasts = matfile('coast.mat');
        mapshow(coasts.long,coasts.lat);
    end
    %Set axis limits
    if ~isempty(cust_axis_lims)
        axis(cust_axis_lims)
    else
        x_offset = (max(cellfun(@max,{geo_struct.X})) - min(cellfun(@min,{geo_struct.X})))*0.05;
        y_offset = (max(cellfun(@max,{geo_struct.Y})) - min(cellfun(@min,{geo_struct.Y})))*0.05;
        axis([min(cellfun(@min,{geo_struct.X}))-x_offset,max(cellfun(@max,{geo_struct.X}))+x_offset,...
            min(cellfun(@min,{geo_struct.Y}))-y_offset,max(cellfun(@max,{geo_struct.Y}))+y_offset])
    end
    axh = gca;
        
elseif strcmp(fig_type,'geo')
    %Fortify coordinates to be inputs for the desired mapping function
    if all(~contains(fieldnames(geo_struct),'Lat'))
        if any(~contains(fieldnames(geo_struct),'X'))
            for i = 1:numel(geo_struct)
                geo_struct(i).Lon = geo_struct(i).X;
                geo_struct(i).Lat = geo_struct(i).Y;
            end
        else
            error('MAPVALUES:NoCoords','No fields ''X'', ''Y'', or ''Lat'', ''Lon'' found in the inputted [geo_struct]. Please reinput with coordinates in that format.')
        end
    end
    
    %Set axis limits
    if ~isempty(cust_axis_lims)
        axh = axesm(proj,'MapLatLimit',cust_axis_lims(3:4),'MapLonLimit',cust_axis_lims(1:2));
    else
        x_offset = (max(cellfun(@max,{geo_struct.Lon})) - min(cellfun(@min,{geo_struct.Lon})))*0.05;
        y_offset = (max(cellfun(@max,{geo_struct.Lat})) - min(cellfun(@min,{geo_struct.Lat})))*0.05;
        axh = axesm(proj,'MapLatLimit',[min(cellfun(@min,{geo_struct.Lat}))-y_offset,max(cellfun(@max,{geo_struct.Lat}))+y_offset],...
            'MapLonLimit',[min(cellfun(@min,{geo_struct.Lon}))-x_offset,max(cellfun(@max,{geo_struct.Lon}))+x_offset]);
    end
    %Map
    geoshow(geo_struct,'SymbolSpec',color_atts);
    %Add outlines of coasts, if desired
    if show_coasts
        coasts = matfile('coast.mat');
        hold on
        geoshow(coasts.lat,coasts.long);
    end
end


%Add colorbar
c = colorbar;

%Add title
if ~isempty(title_string)
    title(title_string)
end

%Add colorbar label
if ~isempty(colorbar_label)
    c.Label.String = colorbar_label;
end

if strcmp(creation,'figure')
    varargout{1} = fig;
elseif strcmp(creation,'subplot')
    varargout{1} = axh;
end



end