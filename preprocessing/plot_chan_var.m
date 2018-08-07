function plot_chan_var(eeg)
% Plot the channel variance

v = zeros(size(eeg,2),1);
L = 0;
for ii = 1:length(eeg),
    v = v + var(eeg{ii},1)'*size(eeg{ii},1); % sum of squares
    L = L + size(eeg{ii},1); % number of samples in the eeg for that trial
end
v = v/(L-1); % divide by total number of samples

figure
plot(v)
xlabel('Channel');
ylabel('Variance');