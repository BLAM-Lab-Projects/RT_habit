function [varargout] = errorfieldpp(theta,r,rterr,varargin)
%plot error field on polar coordinates: 
%h = errorfieldpp(theta,r,rterr,linespec,property name, property value...)
%plots one column vector of data; rterr should be an nx2 column array).
%theta must be in radians.

ttl = [];
rmax = [];
rmin = [];


linespec = 'b-';


if nargin > 3
    for a = 1:2:length(varargin)
        switch(varargin{a})
            case 'linespec'
                linespec = varargin{a+1};
            case 'title'
                ttl = varargin{a+1};
            case 'rmax'
                rmax = varargin{a+1};
            case 'rmin'
                rmin = varargin{a+1};
            otherwise
                prop = varargin{a};
                propval = varargin{a+1};
        end
    end
end

if size(theta,1) < size(theta,2)
    theta = theta';
end
if size(r,1) < size(r,2)
    r = r';
end
if size(rterr,2) == 1
    rterr = [rterr -rterr];
elseif size(rterr,2) ~= 2
    rterr = rterr';
    if size(rterr,2) ~= 2
        disp('ERROR: Errorbar matrix has incorrect size!');
    end
end

% if (size(r,1) ~= 1) || (size(theta,1) ~= 1)
%     disp('Error: must be vector input');
%     return;
% end


if isempty(rmax)
    rmax = max([r; r] + reshape(rterr,[],1));
    rorder = floor(log10(abs(rmax)));
    rmax = (10^rorder)*ceil(rmax/10^rorder);
end
if isempty(rmin)
    rmin = min([r; r] + reshape(rterr,[],1));
	rorder = floor(log10(abs(rmin)));
    rmin = (10^rorder)*floor(rmin/10^rorder);
end


holdstate = ishold;

if holdstate == 0
    polar2(0,(rmax+rmin)/2,[rmin rmax],'k');
end
hold on;

theta = [theta; theta(1)];
r = [r; r(1)];
rterr = [rterr; rterr(1,:)];

re = [r+rterr(:,1); flipud(r + rterr(:,2))];
th = [theta; flipud(theta)];
[x,y] = pol2cart(th,re-rmin);
h.h1 = fill(x,y,linespec);
set(h.h1,'facealpha',0.5,'edgealpha',0);

h.h2 = polar2(theta,r,[rmin rmax],linespec);

if holdstate == 0
    hold off;
end
title(ttl);

if nargout > 0
    varargout{1} = h;
end