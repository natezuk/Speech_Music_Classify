function y = adjdb(x,dbval)
% Set db relative to 1 V rms (0 dB), where the rms is computed for all
% non-zero values

% Make sure max abs(x) is 1
x = x/max(abs(x));
x = x/rms(x);

dbscal = 10^(dbval/20);
y = x*dbscal;