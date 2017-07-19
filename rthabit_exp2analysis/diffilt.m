function fdata = diffilt(n, data, interval)

%  fdata = diffilt(n, data, interval)
%  Do a simple zero phase shift filter.  N specifies number of samples
% to average together.
%

filtvect = [ones(1,n) 0 -ones(1,n)];
fdata = filter(filtvect, 1, [ones(n,1)*data(1); data(:)]);
%fdata = filter(filtvect, 1, data(:));
fdata = [fdata((n*2+1):end); zeros(n,1)];

% fdata = fdata / (n * n * interval);
fdata = fdata / ( (n* (n+1)) * interval);

return;

% old way.  makes bad velocities at beginning of trace.

ndata = length(data);
filtvect = [ones(1,n) 0 -ones(1,n)];
fdata = filter(filtvect, 1, data(:));
fdata = [fdata((n+1):ndata); zeros(n,1)];
fdata = fdata / (n * n * interval);
