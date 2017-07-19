%This code will analyze raw RT-barrier data (reaction time task, with 3-sided
%  box around target to look at RT differences with trajectory complexity).
%  This code will do a complete trajectory analysis, plotting
%  trajectories, marking target and movement onsets, and measuring
%  "complexity". 
%
%Code written by Aaron L. Wong
%
%To run the code, hit "run". When prompted, navigate to the data file to be
%  analyzed and select it. 
%  
%  You will next be shown a figure with 4 subplots 
%  (x,y target position, x,y hand position). You need to select the region 
%  of the data file in which valid data is contained. Use the mouse to 
%  enter marks (left-click to add a mark, right-click to remove a mark).
%  Scroll forward and backward through the data using the 'n' and 'b' buttons
%  respectively. Hit 'x' when done to close this screen.
%  
%  You will next be prompted to visually inspect each movement trajectory 
%  to verify start and end points. This is done via a figure with 4 plots.
%  The top plot displays the target position; the next two panels display
%  the x and y hand position respectively plotted with respect to time. The
%  lowest panel displays the x and y hand position plotted in cartesian
%  space. Scroll through each trajectory, adjusting markers as necessary.
%  Hit 'x' when done. 
%  
%  There must be an equal number of trajectories
%  selected as there are targets. If not, you will be prompted to adjust
%  both the target (one mark only at the start of each trial) and the
%  trajectory (start and end markers) marks until the numbers match. 
%  
%  Finally, it is necessary to manually remove all non-cannonical
%  trajectories that disagree with the ideal movement path. Scroll through
%  and de-select each trajectory if it does not match the displayed cue
%  (gray line) in the bottom panel.
%
%  The code will then automatically analyze each marked trajectory and save
%  the output file.
%  
%  
%Following this individual-block analysis, run the matlab script to
%  compile data from all subjects into a single summary file.



clear all;
close all;

domanualcomplexity = 0;

[fname,fpath] = uigetfile('*.*','Select data file to analyze');
if ~isempty(strfind(fname,'.txt'))
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
    

if doRawAnalysis == 1
    
    %find the indices of all reaches
    inds = intersect(find(data.TargetX<-50),find(data.TargetY<-50));
    data.TargetX(inds) = 0;
    data.TargetY(inds) = 0;
    
    starttgt = [mean(data.StartX(data.StartX>0)) mean(data.StartY(data.StartY>0))];
    
    [data.reachInds,tlims] = findReach(data.Time,data.HandX,data.HandY,data.TargetX,data.TargetY,'startatorig',starttgt,'vthreshmin',0.05);
        
    %verify reaches
    figure(1);
    data.reachInds = markdata3tp(data.Time,[data.TargetX,data.TargetY],data.HandX,data.HandY,1,data.reachInds,0,'Name','Mark All Trajectories','dplot',200,'stgt',starttgt);
    
    data.TargetInds = findTarget(data.Time,data.TargetX,data.TargetY,'lims',tlims);
    %verify targets
    figure(1);
    data.TargetInds = markdata3tp(data.Time,[data.TargetX,data.TargetY],data.HandX,data.HandY,1,data.TargetInds,0,'Name','Mark All Target Onsets','dplot',500,'indz',data.reachInds,'stgt',starttgt);
    
    %there should be an equal number of reaches and target indices.
    while length(data.reachInds) ~= 2*length(data.TargetInds)
        fprintf('Check: unequal number of reaches and targets.  Off by: %d targets\n',length(data.TargetInds)-length(data.reachInds)/2);
        figure(1);
        data.TargetInds = markdata3tp(data.Time,[data.TargetX,data.TargetY],data.HandX,data.HandY,1,data.TargetInds,0,'Name','Recheck Target Onsets','dplot',500,'indz',data.reachInds,'stgt',starttgt);
        
        figure(1);
        data.reachInds = markdata3tp(data.Time,[data.TargetX,data.TargetY],data.HandX,data.HandY,1,data.reachInds,0,'Name','Recheck Reach Trajectories','dplot',200,'stgt',starttgt,'indx',data.TargetInds);

    end
    
    data.TargetInds = data.TargetInds';  %make this a column vector
    
    %throw out the bad reaches
    disp('Remove all bad reaches.');
    data.AllreachInds = data.reachInds;
    figure(1);
    GoodreachInds = markdata3tp(data.Time,[data.TargetX,data.TargetY],data.HandX,data.HandY,1,data.reachInds,0,'Name','Remove bad reaches.','dplot',200,'stgt',starttgt,'reachonly',1);
    [~,badinds] = setdiff(data.reachInds,GoodreachInds);
    data.reachInds(badinds) = NaN;
    data.reachInds = reshape(data.reachInds,2,[])';
    data.AllreachInds = reshape(data.AllreachInds,2,[])';  %nx2 array

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
    reach = repmat(reach,size(data.AllreachInds,1),1);
    
    for a = 1:size(data.AllreachInds,1)
        reachi = [data.AllreachInds(a,1) data.AllreachInds(a,2)];
        reach(a).time = data.Time(reachi(1):reachi(2));
        reach(a).handx = data.HandX(reachi(1):reachi(2));
        reach(a).handy = data.HandY(reachi(1):reachi(2));
        reach(a).starttgt = [data.StartX(data.TargetInds(a)),data.StartY(data.TargetInds(a))];
        reach(a).tgt = [data.TargetX(data.TargetInds(a)),data.TargetY(data.TargetInds(a))];
        reach(a).spath = data.SPath(data.TargetInds(a));
        reach(a).tpath = data.TPath(data.TargetInds(a));
        
        %decode the tgt
        if abs(reach(a).tgt(1)-0.7250)<0.01 && (abs(reach(a).tgt(2)-0.2400)<0.01 ||  abs(reach(a).tgt(2)-0.2300)<0.01)
            tgt = 0;
        elseif abs(reach(a).tgt(1)-0.6898)<0.01 && (abs(reach(a).tgt(2)-0.3248)<0.01 || abs(reach(a).tgt(2)-0.3148)<0.01)
            tgt = 1;
        elseif abs(reach(a).tgt(1)-0.6050)<0.01 && (abs(reach(a).tgt(2)-0.3600)<0.01 || abs(reach(a).tgt(2)-0.3500)<0.01)
            tgt = 2;
        elseif abs(reach(a).tgt(1)-0.5202)<0.01 && (abs(reach(a).tgt(2)-0.3248)<0.01 || abs(reach(a).tgt(2)-0.3148)<0.01)
            tgt = 3;
        elseif abs(reach(a).tgt(1)-0.4850)<0.01 && (abs(reach(a).tgt(2)-0.2400)<0.01 || abs(reach(a).tgt(2)-0.2300)<0.01)
            tgt = 4;
        elseif abs(reach(a).tgt(1)-0.5202)<0.01 && (abs(reach(a).tgt(2)-0.1552)<0.01 || abs(reach(a).tgt(2)-0.1452)<0.01)
            tgt = 5;
        elseif abs(reach(a).tgt(1)-0.6050)<0.01 && (abs(reach(a).tgt(2)-0.1200)<0.01 || abs(reach(a).tgt(2)-0.1100)<0.01)
            tgt = 6;
        elseif abs(reach(a).tgt(1)-0.6898)<0.01 && (abs(reach(a).tgt(2)-0.1552)<0.01 || abs(reach(a).tgt(2)-0.1452)<0.01)
            tgt = 7;
        else
            tgt = -50;
        end
        reach(a).tgtcode = tgt;
        
        %note the true trace, for when the data-table trace is a "bad" trial
        reach(a).truebtrace = (tgt*8) + 4*(reach(a).tpath==4) + ceil((reach(a).spath)/2);  %8*(tgt)+4*(tr(3)==5)+ceil((spath)/2)
        reach(a).showntrace = data.Trace(data.TargetInds(a));
        if (~isempty(strfind(fpath,'badtrace')) && ((reach(a).truebtrace ~= reach(a).showntrace) && (reach(a).truebtrace ~= reach(a).showntrace-64)) && (reach(a).showntrace >= 0) )
            reach(a).badtrace = 1;
        else
            reach(a).badtrace = 0;
        end
        
        reach(a).rottgt = reach(a).tgtcode-reach(a).spath;
        if reach(a).rottgt > 7
            reach(a).rottgt = reach(a).rottgt - 8;
        elseif reach(a).rottgt < 0
            reach(a).rottgt = reach(a).rottgt + 8;
        end
        reach(a).rottgt = reach(a).rottgt+1;  %set to be in the range 1:8, not 0:7
        
        if reach(a).tpath == -1 && ~isempty(strfind(fname,'sonly'))
            reach(a).rottpath = 5;
        else        
            reach(a).rottpath = reach(a).tpath-reach(a).spath;
            if reach(a).rottpath > 7
                reach(a).rottpath = reach(a).rottpath - 8;
            elseif reach(a).rottpath < 0
                reach(a).rottpath = reach(a).rottpath + 8;
            end
            reach(a).rottpath = reach(a).rottpath+1;  %set to be in the range 1:8, not 0:7
        end
        
        reach(a).rotspath = 0 +1;
        
        truetgts(a) = tgt;
        tgtxys(a,1:2) = reach(a).tgt;
        truespath(a) = reach(a).spath;
        truetpath(a) = reach(a).tpath;
        tgts(a) = reach(a).rottgt;
        tpaths(a) = reach(a).rottpath;

    end
else
    disp('Skipped reach selection/rotation.');
    for a = 1:size(data.AllreachInds,1) 
        truetgts(a) = reach(a).tgtcode;
        tgtxys(a,1:2) = reach(a).tgt;
        truespath(a) = reach(a).spath;
        truetpath(a) = reach(a).tpath;
        tgts(a) = reach(a).rottgt;
        tpaths(a) = reach(a).rottpath;
    end
end

if (doRawAnalysis == 0 && exist('Latency','var'))
    doRawAnalysis = input('Redo reach computation? (y = 1; n = 0): ');
else
    doRawAnalysis = 1;
end

if doRawAnalysis == 1
    
     %since we just add on to the existing the array, we have to clear it first so we don't duplicate entries
     for a = 1:8  %tgt number
        for b = 1:8 %path number
            lats{a,b} = [];
        end
    end
    
    Latency = zeros(size(reach));
    VPeak = zeros(size(reach));
    EndPtErr = zeros(size(reach));
    MvmtTime = zeros(size(reach));
    MvmtComplexity = zeros(size(reach));  %curvature
    MvmtVelComplex = zeros(size(reach));  %number of vel peaks
    
    for a = 1:size(data.AllreachInds,1)
        if ~isnan(data.reachInds(a,1))
            reach(a).latency = data.Time(data.reachInds(a))-data.Time(data.TargetInds(a));  %calculate reach latency
            
            disp(['Trial ' num2str(a)]);
            
            if domanualcomplexity == 1
                [reach(a).pos, reach(a).vel, reach(a).acc, reach(a).complexity] = processComplexTraj(reach(a).time,reach(a).handx,reach(a).handy,reach(a).starttgt,reach(a).tgt,reach(a).tgtcode+1,reach(a).spath+1,reach(a).tpath+1,'verifyvel',1);  %,'doplot',100+a
            else
                [reach(a).pos, reach(a).vel, reach(a).acc, reach(a).complexity] = processComplexTraj(reach(a).time,reach(a).handx,reach(a).handy,reach(a).starttgt,reach(a).tgt,reach(a).tgtcode+1,reach(a).spath+1,reach(a).tpath+1);  %,'doplot',100+a
            end
            
            %error between the heading direction and the direct line between the two targets
            reach(a).pos.tgtang = atan2(reach(a).tgt(2)-reach(a).starttgt(2),reach(a).tgt(1)-reach(a).starttgt(1))*180/pi;
            reach(a).pos.initangerr = reach(a).pos.initang - reach(a).pos.tgtang;
            
            if reach(a).badtrace == 0
                %compile data into easily accessible arrays
                Latency(a,1) = reach(a).latency;
                MvmtTime(a,1) = reach(a).time(end)-reach(a).time(1);
                VPeak(a,1) = reach(a).vel.vpeak;
                EndPtErr(a,1) = reach(a).pos.end_dist;
                MvmtComplexity(a,1) = reach(a).complexity.mvmt;
                MvmtVelComplex(a,1) = reach(a).vel.nvelpeaks;
            else
                %compile data into easily accessible arrays
                Latency(a,1) = NaN;
                MvmtTime(a,1) = NaN;
                VPeak(a,1) = NaN;
                EndPtErr(a,1) = NaN;
                MvmtComplexity(a,1) = NaN;
                MvmtVelComplex(a,1) = NaN;
                
                BadLatency(a,1) = reach(a).latency;
                BadMvmtTime(a,1) = reach(a).time(end)-reach(a).time(1);
                BadVPeak(a,1) = reach(a).vel.vpeak;
                BadEndPtErr(a,1) = reach(a).pos.end_dist;
                BadMvmtComplexity(a,1) = reach(a).complexity.mvmt;
            end
                
        else
            reach(a,1).latency = NaN;
            Latency(a,1) = NaN;
            MvmtTime(a,1) = NaN;
            VPeak(a,1) = NaN;
            EndPtErr(a,1) = NaN;
            MvmtComplexity(a,1) = NaN;
        end
        
        lats{reach(a).rottgt,reach(a).rottpath} = [lats{reach(a).rottgt,reach(a).rottpath} reach(a).latency];
    end
else
    %since we just add on to the existing the array, we have to clear it first so we don't duplicate entries
     for a = 1:8  %tgt number
        for b = 1:8 %path number
            lats{a,b} = [];
        end
     end
    
    for a = 1:size(data.AllreachInds,1)
        if ~isnan(data.reachInds(a,1))
            
            reach(a).complexity = calculateCurvature(reach(a).handx,reach(a).handy,reach(a).tgtcode+1,reach(a).spath+1,reach(a).tpath+1);  %,'doplot',0
            
            %compile data into easily accessible arrays
            Latency(a,1) = reach(a).latency;
            MvmtTime(a,1) = reach(a).time(end)-reach(a).time(1);
            VPeak(a,1) = reach(a).vel.vpeak;
            EndPtErr(a,1) = reach(a).pos.end_dist;
            MvmtComplexity(a,1) = reach(a).complexity.mvmt;
            MvmtVelComplex(a,1) = reach(a).vel.nvelpeaks;
        else
            reach(a,1).latency = NaN;
            Latency(a,1) = NaN;
            MvmtTime(a,1) = NaN;
            VPeak(a,1) = NaN;
            EndPtErr(a,1) = NaN;
            MvmtComplexity(a,1) = NaN;
        end
        
        lats{reach(a).rottgt,reach(a).rottpath} = [lats{reach(a).rottgt,reach(a).rottpath} reach(a).latency];
    end
end

%***we have to weed out the "non-cannonical" trajectories that disagree
%with the control trajectories.  We do this manually.
if (doRawAnalysis == 0)
    doRawAnalysis = input('Remove non-cannonical reaches? (y = 1; n = 0): ');
else
    doRawAnalysis = 1;
end

if (doRawAnalysis == 1)
    
    data.ValidReachInds = data.reachInds;
    data.ValidReachInds(isnan(data.ValidReachInds)) = [];
    
    %if this is a no-trace file, the trace column will be all -1s (no
    %trace). So we have to recompute it using the spath and tpath
    %columns...
    if ~isfield(data,'Trace') || (max(data.Trace) <= 0) || ~isempty(strfind(fpath,'endtrace'))
        for a = 1:length(data.TargetX)
            
            %decode the tgt
            if abs(data.TargetX(a)-0.7250)<0.01 && (abs(data.TargetY(a)-0.2400)<0.01 ||  abs(data.TargetY(a)-0.2300)<0.01)
                tgt = 0;
            elseif abs(data.TargetX(a)-0.6898)<0.01 && (abs(data.TargetY(a)-0.3248)<0.01 || abs(data.TargetY(a)-0.3148)<0.01)
                tgt = 1;
            elseif abs(data.TargetX(a)-0.6050)<0.01 && (abs(data.TargetY(a)-0.3600)<0.01 || abs(data.TargetY(a)-0.3500)<0.01)
                tgt = 2;
            elseif abs(data.TargetX(a)-0.5202)<0.01 && (abs(data.TargetY(a)-0.3248)<0.01 || abs(data.TargetY(a)-0.3148)<0.01)
                tgt = 3;
            elseif abs(data.TargetX(a)-0.4850)<0.01 && (abs(data.TargetY(a)-0.2400)<0.01 || abs(data.TargetY(a)-0.2300)<0.01)
                tgt = 4;
            elseif abs(data.TargetX(a)-0.5202)<0.01 && (abs(data.TargetY(a)-0.1552)<0.01 || abs(data.TargetY(a)-0.1452)<0.01)
                tgt = 5;
            elseif abs(data.TargetX(a)-0.6050)<0.01 && (abs(data.TargetY(a)-0.1200)<0.01 || abs(data.TargetY(a)-0.1100)<0.01)
                tgt = 6;
            elseif abs(data.TargetX(a)-0.6898)<0.01 && (abs(data.TargetY(a)-0.1552)<0.01 || abs(data.TargetY(a)-0.1452)<0.01)
                tgt = 7;
            else
                data.Trace(a) = -1;
                continue;
            end
            
            if data.SPath(a) >= 0
                pos = tgt+1;
                if data.SPath(a) <= 5 && data.SPath(a) >= 2
                    data.Trace(a) = (data.SPath(a)-2)*(3*8) + (tgt+1-3)*8 + data.TPath(a) + 0;
                else
                    trspath = (data.SPath(a)-6);
                    if trspath < 0
                        trspath = trspath + 8;
                    end
                    trpos = (tgt+1)-7;
                    if trpos < 0
                        trpos = trpos+8;
                    end
                    data.Trace(a) = trspath*(3*8) + trpos*8 + data.TPath(a) + (3*3*8);
                end
            end
            
        end
    end
    
    data.ValidReachInds = sort(reshape(data.ValidReachInds,[],1));
    data.reachInds = reshape(data.reachInds',[],1);

    impath = [pwd() '\contexttraces\'];
    
    CannonicalReachInds = markdata3tp(data.Time,[data.TargetX,data.TargetY],data.HandX,data.HandY,1,data.ValidReachInds,0,'Name','Remove Non-Cannonical reaches.','dplot',200,'stgt',starttgt,'impath',impath,'tracenum',data.Trace);
    
    [~,badinds] = setdiff(data.reachInds,CannonicalReachInds);
    data.reachInds(badinds) = NaN;
    data.reachInds = reshape(data.reachInds,2,[])';
    
    %since we just add on to the existing the array, we have to clear it first so we don't duplicate entries
     for a = 1:8  %tgt number
        for b = 1:8 %path number
            lats{a,b} = [];
        end
     end
    
    for a = 1:size(data.AllreachInds,1)
        if isnan(data.reachInds(a,1))
            reach(a,1).latency = NaN;
            Latency(a,1) = NaN;
            MvmtTime(a,1) = NaN;
            VPeak(a,1) = NaN;
            EndPtErr(a,1) = NaN;
            MvmtComplexity(a,1) = NaN;
            SolnComplexity(a,1) = NaN;
        end
        
        lats{reach(a).rottgt,reach(a).rottpath} = [lats{reach(a).rottgt,reach(a).rottpath} reach(a).latency];
    end
    
    
end  %end remove non-cannonical reaches


%trajectory resampling for trajectory mean/variability analysis
if (doRawAnalysis == 0 && isfield(reach,'resamptraj') )
    doRawAnalysis = input('Resample trajectories for averaging analysis? (y = 1; n = 0): ');
else
    doRawAnalysis = 1;
end

if (doRawAnalysis == 1)

    reach = trajresamp(reach,'starttgt',starttgt,'2dspline');  %i think these are equivalent statements, so we'll use this one which is more efficient

end

for a = 1:8  %target
    for b = 1:8  %tpath
        latmean{b}(a,1) = nanmean(lats{a,b});
        latstd{b}(a,1) = nanstd(lats{a,b});
        latstd{b}(a,2) = -nanstd(lats{a,b});
        lm1(a,b) = nanmean(lats{a,b});
        lm1std(a,b) = nanstd(lats{a,b});
    end
end


figure(11)
plot(MvmtComplexity,Latency,'o');
[b,~,~,~,stats] = regress(Latency,[MvmtComplexity ones(size(MvmtComplexity))]);
xlims = get(gca,'xlim');
plot(xlims,xlims*b(1)+b(2),'b-');
hold on;
plot(MvmtComplexity,Latency,'o');
hold off;
legend(sprintf('y = %.2f*x + %.2f\nr^2 = %.2f,p = %.3f',b(1),b(2),stats(1),stats(3)));
xlabel('Curvature');
ylabel('Latency (ms)');

figure(12)
plot(MvmtVelComplex,Latency,'o');
[b,~,~,~,stats] = regress(Latency,[MvmtVelComplex ones(size(MvmtVelComplex))]);
xlims = get(gca,'xlim');
plot(xlims,xlims*b(1)+b(2),'b-');
hold on;
plot(MvmtVelComplex,Latency,'o');
hold off;
legend(sprintf('y = %.2f*x + %.2f\nr^2 = %.2f,p = %.3f',b(1),b(2),stats(1),stats(3)));
xlabel('Number of Vel Peaks');
ylabel('Latency (ms)');


%save compiled data
clear a ans b c correct d doRawAnalysis foundbird dims h* inds lat plotstr reachi spath stats tpath tgt ticklabel tmp* x y ystd ylim maxendpts  xlims

tmpfname = strfind(fname,'_');
tmpfname = fname(tmpfname(1)+1:strfind(fname,'.txt')-1);

if ~exist([fpath 'rtbox_' tmpfname '.mat'],'file')
    save([fpath 'rtbox_' tmpfname '.mat']);
    fprintf('\n\nFile saved: %s\n\n',['rtbox_' tmpfname '.mat']);
    
else
    d = 1;
    while exist([fpath 'rtbox_' tmpfname num2str(d) '.mat'],'file')
        d = d+1;
    end
    save([fpath 'rtbox_' tmpfname num2str(d) '.mat']);
    fprintf('\n\nFile saved: %s\n\n',['rtbox_' tmpfname num2str(d) '.mat']);
end
    
