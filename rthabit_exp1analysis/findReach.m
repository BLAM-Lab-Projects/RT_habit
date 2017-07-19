function [inds,varargout] = findReach(t,x,y,tgtx,tgty,varargin)

%use a velocity threshold to find all reaches (note, although this is an
%out-and-back, there isn't a good way to "pair" this because temporally a
%reach end may run into a reach beginning.  so the best thing to do is just
%find all point-to-point reaches and let the user combine the reaches as
%appropriate

maxendpts = [];
dostartatorig = 0;
vthreshMin = [];
vthreshMax = [];
a = 1;
while a < length(varargin)
    switch(varargin{a})
        case 'lims'
            maxendpts = varargin{a+1};
            a = a+2;
        case 'startx'
            startx = varargin{a+1};
            a = a+2;
        case 'starty'
            starty = varargin{a+1};
            a = a+2;
        case 'startatorig'
            dostartatorig = 1;
            starttgt = varargin{a+1};
            a = a+2;
        case 'vthreshmin'
            vthreshMin = varargin{a+1};
            a = a+2;
        case 'vthreshmax'
            vthreshMax = varargin{a+1};
            a = a+2;
        otherwise
            disp('Unrecognized input to findReach');
            a = a+1;
    end
end


%threshold criteria
if isempty(vthreshMax)
    vthreshMax = 0.15;  %meters/sec   %0.18
end
if isempty(vthreshMin)
    vthreshMin = 0.05;  %meters/sec   %0.06
end


% %derivitive and filter
% xvel = diffilt(5,x,mean(diff(t))/1000);
% yvel = diffilt(5,y,mean(diff(t))/1000);

% filter position trace
dt = mean(diff(t))/1000; %sampling interval, sec
smoothedX = sgolayfilt(x,2,min([19,2*floor((length(x)-2)/2)+1]));
smoothedY = sgolayfilt(y,2,min([19,2*floor((length(y)-2)/2)+1]));

% get velocity
xvel = gradient(smoothedX,dt);      % non-filtered velocity
yvel = gradient(smoothedY,dt);      % non-filtered velocity


vel2d = sqrt(xvel.^2 + yvel.^2);
veli = find(vel2d>vthreshMax);
velid = find(diff([0; veli])>1); %now i have the indices into veli of all the starts of all reaches exceeding vthreshMax
velid = sort([velid; velid-1]);
velid = [velid(2:end); length(veli)];
veli = veli(velid); %now i have the start and end indices of all reaches exceeding vthreshMax


%exclude points outside of a desired cutoff threshold (this throws out
%   noise at the start and end of the block, which should improve the
%   search speed a little 
if isempty(maxendpts)
    maxendpts = markdata4a(tgtx,tgty,x,y,5000,[],0,1000/mean(diff(t)),'title','Mark Region to search for valid reaches');
end
veli(veli<maxendpts(1)) = [];
veli(veli>maxendpts(2)) = [];


%we will walk back and forth until we reach the vthreshMin value for each
%identified reach.  to speed this up, we could use
%find(vel(1:veli(a)<vthresh,1,'last');
for a = 1:2:length(veli)
%     doloop = 1;
%     while doloop
%         veli(a) = veli(a)-1;
%         if veli(a) < 1
%             veli(a) = 1;
%             doloop = 0;
%         elseif abs(xvel(veli(a))) < vthreshMin || abs(yvel(veli(a))) < vthreshMin %vel2d(veli(a)) < vthreshMin
%             doloop = 0;
%         end
%     end
    xveli = find(abs(xvel(1:veli(a)))<vthreshMin,1,'last');
    yveli = find(abs(yvel(1:veli(a)))<vthreshMin,1,'last');
    if isempty(xveli)
        %xveli = 1;
        xveli = inf;
    end
    if isempty(yveli)
        yveli = inf;
    end
    veli(a) = min([xveli,yveli]);
    
%     doloop = 1;
%     while doloop
%         veli(a+1) = veli(a+1)+1;
%         if veli(a+1) > length(vel2d)
%             veli(a) = length(vel2d);
%             doloop = 0;
%         elseif abs(xvel(veli(a+1))) < vthreshMin || abs(yvel(veli(a+1))) < vthreshMin
%             doloop = 0;
%         end
%     end
    xveli = find(abs(xvel(veli(a+1):end))<vthreshMin,1,'first');
    yveli = find(abs(yvel(veli(a+1):end))<vthreshMin,1,'first');
    if isempty(xveli)
        %xveli = length(xvel);
        xveli = 1;
        
    end
    if isempty(yveli)
        yveli = 2;
    end
    veli(a+1) = max([xveli,yveli])+veli(a+1)-1;
    
end

dveliind = find(diff(veli)<0);  %find points where veli < 0; two reaches have overlapped here!
for a = 1:length(dveliind)
    veli(dveliind(a):dveliind(a)+1) = 0;  %erase these overlapping indices
end
veli = nonzeros(veli);  %merge the overlapping reaches together
dveliind = find(diff(veli)==0);  %find points where veli = 0; two reaches have overlapped here and we want to separate them
for a = 1:length(dveliind)
    veli(dveliind(a)) = veli(dveliind(a))-1;
    veli(dveliind(a)+1) = veli(dveliind(a)+1)+1;  %separate these overlapping indices
end


%now we have the indices to the starts and ends of every reach!  these will
%be returned (without user verification).
inds = veli;

if dostartatorig == 1
    %for each reach, we will exclude all those movements that do not begin at
    %the start target -- this will reduce the number of reaches to manually
    %exclude later.
    for a = 1:2:length(inds)-1
        %just check reach start indices
        if sqrt( (x(inds(a))-starttgt(1))^2 + (y(inds(a))-starttgt(2))^2 ) > 0.02
            inds(a) = 0;
            inds(a+1) = 0;
        end
    end
    inds = nonzeros(inds)';
end


if nargout>1
    varargout{1} = maxendpts;
end
