function [pMW,MW,cond] = mannwhitneycmp(obsv,lbl)
% Use a Mann-Whitney U test to perform multiple comparisons on a set of
% data obtained from the obsv matrix.  If obsv is a matrix, each column 
% is a separate condition, and each row an observation. If obsv is a
% vector, the groups must be labeled with the vector lbl.
% Nate Zuk (2019)

if nargin==1,
    ncond = size(obsv,2); % # of conditions
    lbl = 1:ncond;
%     nobsv = size(obsv,1); % # of observations
else
    if size(obsv,2)>1, 
        error('Observations array must be a row vector when labels are provided');
    end
    cond = unique(lbl);
    ncond = length(cond);
end

pMW = NaN(ncond,ncond); % array to store significance of each MW test
MW = NaN(ncond,ncond); % array to store the U value for each test

for ii = 1:ncond,
    for jj = ii+1:ncond,
        if size(obsv,2)>1,
            [pMW(jj,ii),~,stmw] = ranksum(obsv(:,ii),obsv(:,jj));
        else
            [pMW(jj,ii),~,stmw] = ranksum(obsv(lbl==cond(ii)),obsv(lbl==cond(jj)));
        end
        MW(jj,ii) = stmw.ranksum;
    end
end

% Correct for multiple comparisons
% ncmp = sum(sum(~isnan(MW))); % determine the number of comparisons
% pMW = pMW*ncmp;

if size(obsv,2)==1,
    cond = [];
end