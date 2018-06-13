function unqstims = checkidentsource(stims)
% Goes through a cell array of stimulus names and identifies stimuli that
% come from the same source.  In Emily Teoh's stimuli for speech / music
% discrimination, stimuli were labeled 2, 3, etc if they came from the same
% audio file (ex. M-Banjo, M-Banjo2, M-Banjo3)
% NZ (4/16/2018)

unqstims = true(length(stims),1); % start assuming that they are all unique

for ii = 1:length(stims)
    if unqstims(ii) % if it's already specified as unique
        otherstims = setxor(1:length(stims),ii); % indexes of the other stimuli to check
        dotind = strfind(stims{ii},'.'); % find the index in the stimulus name with '.wav'
        % Check if the stimulus name is identical to any other name in the
        % list
        notunq = cellfun(@(x) strcmp(stims{ii}(1:dotind-1),x(1:min([dotind-1 length(x)]))),stims(otherstims));
        unqstims(otherstims(notunq)) = 0; % if they're not unique, set to 0
    end
end