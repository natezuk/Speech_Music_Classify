function [icasig,A] = icaexamineeeg(EEG,Fs)
% Concatenate the EEG signal across trials and compute the ICA components

numIC = 20;

if iscell(EEG),
    disp('Concatenating the trials...');
    eeg = [];
    for ii = 1:length(EEG), % concatenate the EEG signal
        eeg = [eeg; EEG{ii}];
    end
else
    eeg = EEG;
end

% Compute the ICA components of the eeg
[icasig,A,~] = fastica(eeg','numOfIC',numIC,'interactivePCA','on','g','gauss');

% Plot the results
EEGplot(icasig',Fs,1);
ylabel('Component');

% Plot the topographies of each component
pcprplt = 5;
figure
for ii = 1:size(A,2)
    subplot(5,ceil(size(icasig,1)/pcprplt),ii);
    topoplot(A(:,ii),'chanlocs.xyz');
    title(['Component #' num2str(ii)]);
end

% Plot the average variance contributed by each component
figure
for ii = 1:ceil(size(icasig,1)/pcprplt),
    subplot(ceil(size(icasig,1)/pcprplt),1,ii);
    if ii*pcprplt>size(A,2),
        pcplt = (ii-1)*pcprplt+1:size(A,2);
    else
        pcplt = (ii-1)*pcprplt+1:ii*pcprplt;
    end
    plot(A(:,pcplt).^2./var(eeg)');
%     plot(A(:,pcplt).^2);
    pcleg = cell(pcprplt,1);
    for jj = 1:length(pcplt),
        pcleg{jj} = num2str(pcplt(jj));
    end
    legend(pcleg)
end
xlabel('Component');
ylabel('Variance');