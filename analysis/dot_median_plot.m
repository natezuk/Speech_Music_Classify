function dot_median_plot(lbl,yvals,varargin)
% Plot the individual dots for each y-value, separated on the x-axis by label,
% and show the median of y-values for each label as a line. Columns in yvals
% represent different repeated measures for the set of x-values (rows)
% Inputs:
% - lbl = array of values or strings, indicating the labels for each of the
%   y-values
% - yvals = array of y-values

jit_span = 0.3; % span, in x-values, of the jittered dots
med_span = 0.6; % span, in x-values, of the line for the median
dot_size = 16; % size of the dots
line_width = 4; % width of the median line

% Parse varargin
if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

nrepeats = size(yvals,2); % get the number of repeats
unqlbls = unique(lbl); % get the set of unique labels
reptype = repmat(lbl,[1 nrepeats]);
reptype = reshape(reptype,[numel(reptype) 1]); % make a column of labels
YVALS = reshape(yvals,[numel(reptype) 1]); % reorder y-values into a column

figure
hold on
for ii = 1:length(unqlbls),
    % Plot the dots
    y_idx = reptype==ii; % get the y-values for the correct label
    x_pos = 2*(rand(sum(y_idx),1)-0.5)*(jit_span/2)+ii;
        % get the x-coordinates, which are slightly jittered for each dot
    plot(x_pos,YVALS(y_idx),'k.','MarkerSize',dot_size);
    % Plot the median value
    x_md_pos = [-med_span med_span]/2+ii;
    y_md = median(YVALS(y_idx));
    plot(x_md_pos,[y_md y_md],'k','LineWidth',line_width);
end
set(gca,'FontSize',16,'XTick',1:length(unqlbls),'XTickLabel',unqlbls);
