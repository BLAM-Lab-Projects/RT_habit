%This code analyzes the interception task, particularly with regard to RTs.
%  This analysis does a single-block analysis on raw data.
%
%Code written by Aaron L. Wong
%
%To run the code, hit "run". When prompted, navigate to the data file to be
%  analyzed and select it. 
%  
%  You will next be prompted to visually inspect each movement one by one
%  to verify start and end points. This is done via a figure with 4 plots.
%  The top plot displays the target position; the next two panels display
%  the x and y hand position respectively plotted with respect to time. The
%  lowest panel displays the x and y hand position plotted in cartesian
%  space. Adjust the start and end markers for the current reach as
%  necessary using the mouse (left-click adds a marker at the cursor,
%  right-click removes the closest marker to the cursor). When done, hit
%  'x' to proceed to the next trial.      
%  
%  The code will then automatically analyze each marked trajectory and save
%  the output file.
%  
%  
%Following this individual-block analysis, run the matlab script to
%  compile data from all subjects into a single summary file.


clear all;
close all;

[fname,fpath] = uigetfile('*.*','Select data file to analyze');
if ~isempty(strfind(fname,'.txt')) || ~isempty(strfind(fname,'.dat'))
    [data,params] = KRload([fpath fname]);
    
    %find the right hand data; throw out everything else
    foundbird = 0;
    a = 1;
    while ~foundbird
        if strcmp(data{a}.BirdName,'Right_Hand')
            data = data{a};
            foundbird = 1;
        else
            a = a+1;
        end
    end
    
    if ~foundbird
        disp('No bird found!');
        return;
    end

    doRawAnalysis = 1;
elseif ~isempty(strfind(fname,'.mat'))
    load([fpath fname]);
    doRawAnalysis = input('Repeat reach and target selection? (yes = 1, no = 0): ');
end

data.Time = (data.TrackerTime-data.TrackerTime(1))*1000;


if doRawAnalysis == 1
    
    %find the indices of all reaches
    starttgt = [mean(data.StartX(data.StartX>0)) mean(data.StartY(data.StartY>0))];
    
    data.reachInds = [];
    data.TargetInds = [];
    
    %examine reaches trial-by-trial.
    for a = 1:max(data.Trial)
        i = data.Trial == a;
        j = [max([1 find(i>0,1,'first')-9]),min([find(i>0,1,'last')+10,length(data.Trial)])];
        i(j(1):j(2)) = 1;
        
        reachInds = findReach(data.Time(i),data.HandX(i),data.HandY(i),data.TargetX(i),data.TargetY(i),'startatorig',starttgt,'vthreshmin',0.04,'lims',[1 diff(j)+1],'vthreshmax',0.07);
        
        tgtx = data.TargetX(i);
        tgty = data.TargetY(i);
        
        %verify reaches
        figure(1);
        reachInds = markdata3tp(data.Time(i),[data.TargetX(i),data.TargetY(i)],data.HandX(i),data.HandY(i),1,reachInds,0,'Name',sprintf('Mark Trajectory %d',a),'dplot',200,'stgt',starttgt);
        %to manipuate this figure, use:
        %  'n' and 'b' for scrolling forward and backward through the data.
        %  'v' refreshes the screen.
        %  'x' quits out of the window; press this when you are done
        %       marking a reach
        %  left mouse click: add a data mark
        %  right mouse click: remove a data mark
    
        if isempty(reachInds) || length(reachInds) < 2
            data.reachInds(a,:) = [NaN NaN];
        else
            data.reachInds(a,:) = reachInds(1:2) + j(1);
        end
        
        tgtInds = findTarget(data.Time(i),data.TargetX(i),data.TargetY(i),'lims',[1 diff(j)+1]);
        data.TargetInds(a,1) = tgtInds(1)+j(1)+1;

        
    end
    
    data.AllreachInds = data.reachInds;

end



if (doRawAnalysis == 0 &&  exist('reach','var'))
    doRawAnalysis = input('Redo reach pre-computation? (y = 1; n = 0): ');
else
    doRawAnalysis = 1;
end

if doRawAnalysis == 1
    
    %now that we have all the reaches marked, we will want to process them.
    clear reach;
    reach.time = [];
    reach.handx = [];
    reach.handy = [];
    reach.starttgt = [];
    reach.tgt = [];
    reach.pos = [];
    reach.vel = [];
    reach.acc = [];
    reach.goodtrial = [];
    reach.lat = [];
    reach = repmat(reach,size(data.AllreachInds,1),1);
    
    for a = 1:size(data.reachInds,1)
        
        reach(a).starttgt = [data.StartX(data.TargetInds(a)),data.StartY(data.TargetInds(a))];
        itgt = data.Trial == a & (data.TargetX2 > 0 | data.TargetY2 > 0);
        reach(a).tgt = [data.TargetX2(itgt),data.TargetY2(itgt)];
        
        if isnan(data.reachInds(a,1))
            
            reach(a).time = [];
            reach(a).handx = [];
            reach(a).handy = [];
            reach(a).latency = NaN;
            reach(a).lat = NaN;
            reach(a).goodtrial = 0;
            continue;
        end
        
        reachi = [data.reachInds(a,1) data.reachInds(a,2)];
        reach(a).time = data.Time(reachi(1):reachi(2));
        reach(a).handx = data.HandX(reachi(1):reachi(2));
        reach(a).handy = data.HandY(reachi(1):reachi(2));
        
        reach(a).latency = data.Time(data.reachInds(a,1))-data.Time(data.TargetInds(a));  %calculate reach latency
        
        
        tgt = reach(a).tgt(end,:) - reach(a).starttgt;
        reach(a).tgtdir = atan2d(tgt(2),tgt(1));
        rotang = [-reach(a).tgtdir 0];
        
        [~, reach(a).pos, reach(a).vel, reach(a).acc, reach(a).rothand] = processKinTrial(reach(a).time,reach(a).handx,reach(a).handy,reach(a).starttgt,tgt,'rotang',rotang);
        
        reach(a).pos.intercepterr = reach(a).pos.endpterr * 100;
        reach(a).pos.endpterr = sqrt( (reach(a).handx(end) - reach(a).tgt(end,1))^2 + (reach(a).handy(end) - reach(a).tgt(end,2))^2) * 100;

       
    end
else
    disp('Skipped reach selection/rotation.');
end



    
Latency = zeros(size(reach));
VPeak = zeros(size(reach));
EndPtErr = zeros(size(reach));
InterceptErr = zeros(size(reach));
MvmtTime = zeros(size(reach));
InitDir = zeros(size(reach));
TargetDir = zeros(size(reach));
    
for a = 1:size(data.AllreachInds,1)
    if ~isnan(data.reachInds(a,1)) || reach(a).goodtrial ~= 0 || ~isnan(reach(a).latency)
        
        %compile data into easily accessible arrays
        Latency(a,1) = reach(a).latency;
        MvmtTime(a,1) = reach(a).pos.mvmttime;
        VPeak(a,1) = reach(a).vel.vpeak;
        EndPtErr(a,1) = reach(a).pos.endpterr;
        InterceptErr(a,1) = reach(a).pos.intercepterr;
        InitDir(a,1) = reach(a).pos.initang;
        TargetDir(a,1) = reach(a).tgtdir;
        
    else
        Latency(a,1) = NaN;
        MvmtTime(a,1) = NaN;
        VPeak(a,1) = NaN;
        EndPtErr(a,1) = NaN;
        InterceptErr(a,1) = NaN;
        InitDir(a,1) = NaN;
        TargetDir(a,1) = NaN;
        
    end
end


close all;

if doRawAnalysis ~= 0 
    
    %save compiled data
    clear a ans badinds doRawAnalysis foundbird i inds j reachi reachInds starttgt tgt* verts
    
    tmpfname = strfind(fname,'_');
    tmpfname = fname(tmpfname(1)+1:end);
    tmpfname = strrep(tmpfname,'.dat','');
    tmpfname = strrep(tmpfname,'.txt','');
    
    if ~exist([fpath tmpfname '.mat'],'file')
        save([fpath tmpfname '.mat']);
        fprintf('\n\nFile saved: %s\n\n',[tmpfname '.mat']);
    else
        d = 1;
        while exist([fpath tmpfname '_' num2str(d) '.mat'],'file')
            d = d+1;
        end
        save([fpath tmpfname '_' num2str(d) '.mat']);
        fprintf('\n\nFile saved: %s\n\n',[tmpfname '_' num2str(d) '.mat']);
    end
    
end
