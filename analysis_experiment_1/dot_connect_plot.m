function cell_midline = dot_connect_plot(lbl,yvals,varargin)
% Plot the individual dots for each y-value, separated on the x-axis by label,
% and connect dots that are paired together (in the same row in yvals)  
% Inputs:
% - lbl = array of values or strings, indicating the labels for each of the
%   y-values
% - yvals = each row must correspond use the same lbl, and each row is 
%   plotted as a different color
% Outputs:
% - cell_midline = x-value of the position of the data for a cell relative
%   to the x-value for the label
% cell/column, so that they can be labeled with a legend
% Nate Zuk (2019)

jit_span = 0.4; % span, in x-values, of the jittered dots
tot_span = 1; % span of all dots and median plots for a single label
dot_size = 12; % size of the dots
line_width = 1.5; % width of the lines connecting dots

% Parse varargin
if ~isempty(varargin),
    for n = 2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

% Check to make sure the dimensions of yvals and lbl are appropriate
if size(yvals,1)~=size(lbl,1)
    error('Number of rows in y-values and labels must be consistent.');
end
if size(lbl,2)>1
    error('Labels array can only contain one column');
end
% reptype = reshape(reptype,[numel(reptype) 1]); % make a column of labels
% YVALS = reshape(yvals,[numel(reptype) 1]); % reorder y-values into a column
nconnect = size(yvals,2); % get the number of cells
unqlbls = unique(lbl); % get all unique labels

% Compute the midline of each repeat, relative to the span
% of the data around point ii on the x axis
cell_midline = tot_span*(-nconnect+1:2:nconnect-1)/nconnect/2;
figure
hold on
for ii = 1:length(unqlbls),
    % Connnect the dots
    ml = cell_midline+ii;
    y_idx = lbl==unqlbls(ii); % get the y-values for the correct label
    x_pos = tot_span/nconnect*(rand(sum(y_idx),1)-0.5)*(jit_span)+ml;
        % get the x-coordinates, which are slightly jittered for each dot
    plot(x_pos',yvals(y_idx,:)','-o','Color',[0 0 0],'MarkerSize',dot_size,'LineWidth',line_width);
end
set(gca,'FontSize',16,'XTick',1:length(unqlbls),'XTickLabel',unqlbls);
