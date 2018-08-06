function Z = standardize(X)
% Standardize the design matrix X so that the mean of each column is 0 and
% the standard deviation is 1 (X should not include a bias column)

Z = X-ones(size(X,1),1)*mean(X); % set to 0 mean
Z = Z./(ones(size(Z,1),1)*std(Z)); % set to 1 variance