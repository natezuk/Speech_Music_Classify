function [median_handles,cell_midline] = dot_median_plot(lbl,yvals,cmap,varargin)
% Plot the individual dots for each y-value, separated on the x-axis by label,
% and show the median of y-values for each label as a line.
% Inputs:
% - lbl = array of values or strings, indicating the labels for each of the
%   y-values
% - yvals:
%     -- If yvals is a 1D column vector, lbl must be the same dimension as
%     yvals, and dots and median line are plotted in black
%     -- If yvals contains more than one column, each row must correspond
%     use the same lbl, and each row is plotted as a different color
%     -- If yvals is a cell array, each array must be a 1D column vector,
%     and lbl must be a cell array with the same dimensions as yvals in
%     each cell. Each cell is plotted as a different color.
% - (optional) cmap = 64x3 dimension matrix specifying the rgb values of
% the colormap to use (only used if there is more than one cell or column
% in y-vals
% Outputs:
% - median_handles = handle labels for the median lines for each
% - cell_midline = x-value of the position of the data for a cell relative
%   to the x-value for the label
% cell/column, so that they can be labeled with a legend

jit_span = 0.4; % span, in x-values, of the jittered dots
med_span = 0.8; % span, in x-values, of the line for the median
tot_span = 1; % span of all dots and median plots for a single label
dot_size = 16; % size of the dots
line_width = 4; % width of the median line

% Parse varargin
if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Check to make sure the dimensions of yvals and lbl are appropriate
if iscell(yvals),
    if ~iscell(lbl), error('Labels must be contained in a cell array');
    else
        dim_check = cellfun(@(x,y) length(x)~=length(y),yvals,lbl);
        if sum(dim_check)>1,
            error('Not all cells of labels and y-values have the same dimesions');
        end
    end
else
    if size(yvals,1)~=size(lbl,1)
        error('Number of rows in y-values and labels must be consistent.');
    end
    if size(lbl,2)>1
        error('Because y-values are in matrix form, labels array can only contain one column');
    end
end

if ~iscell(yvals), % if it's not a cell array, split columns into separate cells
    ncols = size(yvals,2);
    nreps = size(yvals,1);
    yvals = mat2cell(yvals,nreps,ones(ncols,1));
    lbl = repmat(lbl,[1 ncols]);
    lbl = mat2cell(lbl,nreps,ones(ncols,1));
end
% reptype = reshape(reptype,[numel(reptype) 1]); % make a column of labels
% YVALS = reshape(yvals,[numel(reptype) 1]); % reorder y-values into a column
ncells = length(yvals); % get the number of cells
unqlbls = unique(cell2mat(lbl)); % get all unique labels

% Compute the midline of each repeat, relative to the span
% of the data around point ii on the x axis
cell_midline = tot_span*(-ncells+1:2:ncells-1)/ncells/2;
median_handles = NaN(ncells,1); % this is to store the handles for the different median lines
    % which can be used to label a legend
figure
if nargin<3 | isempty(cmap), % if the colormap isn't defined
    cmap = colormap('jet');
end
hold on
for ii = 1:length(unqlbls),
    for jj = 1:ncells,
        % If there's more than one repeat, use different colors
        if ncells==1,
            clr = [0 0 0]; % otherwise use black
        else
            cidx = round((jj-1)/ncells*(size(cmap,1)-1))+1;
            clr = cmap(cidx,:);
        end
        % Plot the dots
        y_idx = lbl{jj}==unqlbls(ii); % get the y-values for the correct label
        ml = cell_midline(jj)+ii;
        x_pos = tot_span/ncells*(rand(sum(y_idx),1)-0.5)*(jit_span)+ml;
            % get the x-coordinates, which are slightly jittered for each dot
        plot(x_pos,yvals{jj}(y_idx),'.','Color',clr,'MarkerSize',dot_size);
        % Plot the median value
        x_md_pos = tot_span/ncells*[-med_span med_span]/2+ml;
        y_md = median(yvals{jj}(y_idx));
        median_handles(jj) = plot(x_md_pos,[y_md y_md],'Color',clr,'LineWidth',line_width);
    end
end
set(gca,'FontSize',16,'XTick',1:length(unqlbls),'XTickLabel',unqlbls);
