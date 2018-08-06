function EEGplot(EEG,Fs,chstep,t)
% Plots an EEG signal with a sampling rate of Fs (in Hz)
% Each channel is plotted on a single plot, different channes on the y axis
% chstep is the spacing between channels to be plotted
% t is a time array, optional input

ystep = max(chstep,5); % step size in labeling channels
mx = max(max(abs(EEG)))*3/4;

yax = (chstep:chstep:size(EEG,2))*mx/chstep; % points for y axis
chval = chstep:chstep:size(EEG,2); % value of each channel
if nargin<4,
    t = (0:size(EEG,1)-1)/Fs; % time (in s)
end
ytck = ystep:ystep:size(EEG,2);

figure
hold on
% ylbl = {};
for ii = 1:length(yax),
    % Plot each channel shifted up on the y axis
    plot(t,EEG(:,chval(ii))+yax(ii),'b','LineWidth',1.5);
end
set(gcf,'Position',[0 0 1200 860]);
set(gca,'YTick',ytck*mx/chstep,'YTickLabel',ytck,'FontSize',14,'YLim',[0 (size(EEG,2)+1)*mx/chstep]);
xlabel('Time (s)');
ylabel('Channel');