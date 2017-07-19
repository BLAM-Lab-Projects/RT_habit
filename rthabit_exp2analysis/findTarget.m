function inds = findTarget(t,tgtx,tgty,varargin)

a = 1;
baseline = 0;
returnoffsets = 0;
tlims = [1 length(t)];
window = [];
ignore1 = 1;

while a <= length(varargin)
    switch(varargin{a})
        case 'lims'
            tlims = varargin{a+1};
            a = a+2;
        case 'baseline'
            baseline = varargin{a+1};
            a = a+2;
        case 'onoff'
            returnoffsets = 1;  %if flagged, return the target offsets as well as the onsets
            a = a+1;
        case 'window'
            window = varargin{a+1};
            a = a+2;
        case 'ignore1'
            ignore1 = varargin{a+1};
            a = a+2;
        otherwise
            disp('Unrecognized input to findTarget');
            a = a+1;
    end
end


% %we will do this the "easy" way for now: find all non-zero target values
% %  THIS DOES NOT WORK - SOMETIMES HAVE TGT JUMPS WITHOUT RETURN TO ZERO
% tgtindx = find(tgtx<=0);
% tgtindy = find(tgty<=0);
% tgtind = intersect(tgtindx,tgtindy); %x and y must both be "zero"
% 
% dtgtind = find(diff([0; tgtind])>1);
% dtgtind = sort([dtgtind; dtgtind-1]);
% dtgtind = [dtgtind(2:end); length(tgtind)];
% tgtind = tgtind(dtgtind); %now i have the start and end indices of all target steps
% 
% tgtind(tgtind<tlims(1)) = [];
% tgtind(tgtind>tlims(2)) = [];
% 
% inds = tgtind;


%we will do this the "hard" way and actually find target transitions
tgtindx = find(diff([0; tgtx])~= 0); %all transitions in x
tgtindy = find(diff([0; tgty])~= 0); %all transitions in y
%tgtind = union(tgtindx,tgtindy); %x and y must transition together - this is not always true, for target/barrier jumps!
tgtind = unique(sort([tgtindx; tgtindy]));  %just take all the unique values

if ignore1 == 1
    tgtind(tgtind == 1) = [];
    tgtind(tgtind == length(tgtx)) = [];
end

%get rid of the "return-to-zero" target jumps (return to baseline, where
%  baseline may be specified) (default). may be flagged to skip this step
%  to return target offsets also.
if (~returnoffsets)
    
    %here, we detect the single-target "spikes" and preserve them.
    spikeind = intersect(find(tgtx(tgtind+1)==baseline & tgtx(tgtind-1)==baseline), find(tgty(tgtind+1)==baseline & tgty(tgtind-1)==baseline));
    
    tgtindx = find(tgtx(tgtind+1)==baseline);
    tgtindy = find(tgty(tgtind+1)==baseline);
    zerotgt = intersect(tgtindx,tgtindy);
    zerotgt = setxor(zerotgt,spikeind);
    tgtind(zerotgt) = [];
end

%tgtind = tgtind-1;  %find the time the target leaves zero, otherwise this is the time the target first turns on (is nonzero)

%exclude all target jumps outside the requested range
tgtind(tgtind<tlims(1)) = [];
tgtind(tgtind>tlims(2)) = [];

%using a sliding window, remove all subsequent points after the first
%within that window
if ~isempty(window) && window > 0
    while any(diff(tgtind) < window)
        
        dt = diff(tgtind);
        ibad = find(dt < window);
        tgtind(ibad) = [];  %take out any previous target marks; tgtind(ibad+1) = []; -- take out any following target marks
    end
end


inds = tgtind';
