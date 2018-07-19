% STANDARD_COLORBAR generate a simple, good-for-most-occasions colorbar
%
%   Are you constantly annoyed by having to manually place new axes for a
%   figure-spanning colorbar when making figures containing multiple
%   subplots? This function will create a 'good-enough'-positioned colorbar
%   for most subplot figure applications by creating a new (invisible) axis
%   spanning the figure and placing the colorbar onto it at a position
%   determined to look 'pretty alright' by trial-and-error.
%
%   c = STANDARD_COLORBAR(crange,cmap) produces a colorbar on the right
%   side of your current figure with the range [crange] (equivalent to what
%   you'd put into the function [caxis]) and the colormap [cmap]
%   (equivalent ot what you'd put into the function [colormap]). The handle
%   for the colorbar is returned as [c].
%
%   c = STANDARD_COLORBAR(___,'left') will produce a colorbar on the left
%   side of the current figure.
%
%   c = STANDARD_COLORBAR(___,'label',[  ]) will put on a label given by
%   the string entry.
%
%   STANDARD_COLORBAR(...,'[flag]',[params],...) modify program run as below:
%       'tick_scale',[char],([num]) - 'raw' by default. If set to 'log' or
%                                     'log10', then the ticks labels will
%                                     be set to exp([ticks]) or
%                                     10^([ticks]) respectively - useful if
%                                     your colorscale is log but you still
%                                     want the base numbers listed. I
%                                     suggest you use this in conjunction
%                                     with the 'ticks' option below. You
%                                     can optionally set the significant
%                                     digits precision of the [num2str]
%                                     call - by default 4 to avoid spurious
%                                     rounding errors when you really just
%                                     want integer ticks - by adding an
%                                     integer to the flag call.
%       'ticks',[num]               - manually set the ticks for the
%                                     colorbar


function c = standard_colorbar(crange,cmap,varargin)

clabel_string = [];
cloc = 'right';
tick_scale = 'raw';
tick_labels = [];
ticks = [];
tick_label_precision = 4;

if (~isempty(varargin))
    for in_idx = 1:length(varargin)
        switch varargin{in_idx}
            case {'label'}
                clabel_string = varargin{in_idx+1}; varargin{in_idx+1} = 0;
            case {'left'}
                cloc = 'left';
            case {'tick_scale'}
                tick_scale = varargin{in_idx+1};
                if isa(varargin{in_idx+2},'numeric')
                    tick_label_precision = varargin{in_idx+2};
                elseif strcmp(tick_scale,'manual')
                    if isa(varargin{in_idx+2},'cell')
                        tick_labels = varargin{in_idx+2}; varargin{in_idx+2} = 0;
                    else
                        error('STANDARD_COLORMAP:MissingTickLabels','If setting ''tick_scale'' to ''manual'', the next input should be a cell array of tick labels the same length as the tick vector')
                    end
                    
                end
            case {'ticks'}
                ticks = varargin{in_idx+1}; varargin{in_idx+1} = 0;
                
        end
    end
end

% Get figure handle
fig = gcf;

% Make invisible axis to stick colorbar onto
axes_cbar = axes('Visible','off','Parent',fig,...
    'Position',[0.05 0.05 0.95 0.95],...
    'CLim',crange);

% Set position
if strcmp(cloc,'left')
    cposition = [0.09 0.15 0.014 0.75];
else
    cposition = [0.91 0.15 0.014 0.75];
end

% Set colormap
colormap(axes_cbar,cmap);

% Generate colorbar
c=colorbar('peer',axes_cbar,...
    'Position',cposition);

% Label colorbar, if desired
c.Label.String = clabel_string;
c.Label.FontSize = 15;

% Change ticks, if desired
if ~isempty(ticks)
    c.Ticks = ticks;
end

% Change colorbar scaling, if desired
if strcmp(tick_scale,'log')
    c.TickLabels = num2str(exp(cellfun(@str2double,c.TickLabels)),tick_label_precision);
elseif strcmp(tick_scale,'log10')
    c.TickLabels = num2str(10^(cellfun(@str2double,c.TickLabels)),tick_label_precision);
elseif strcmp(tick_scale,'manual')
    if length(tick_labels)==length(ticks)
        c.TickLabels = tick_labels;
    else
        error('STANDARD_COLORBAR:n_labels',['The length of the array of tick labels - ',num2str(length(tick_labels)),...
            ' - is not equal to the length of ticks. There''s currently no programmatic way to deal with this, so please manually set the tick locations ([ticks]) and a tick label array of the same length.'])
    end
end




