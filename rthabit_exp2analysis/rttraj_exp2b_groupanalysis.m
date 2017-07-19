%Compile data across subjects for Experiment 2B
%
%Code by: Aaron L. Wong

%clear all;
close all;

rtdelay = 105;

%full experimental version: control and task

CNCB1files = {
    [pwd() '\cnc\20161010dl\rtboxta_rtboxs7b1t_data.mat'];  %s1
    [pwd() '\cnc\20161011di\rtboxta_rtboxs3b1t_data.mat'];  %s2
    [pwd() '\cnc\20161014bl\rtboxta_rtboxs7b1t_data.mat'];  %s3
    [pwd() '\cnc\20161017di\rtboxta_rtboxs3b1t_data.mat'];  %s4
    [pwd() '\cnc\20161017bx\rtboxta_rtboxs7b1t_data.mat'];  %s5
    [pwd() '\cnc\20161018gu\rtboxta_rtboxs3b1t_data.mat'];  %s6
    [pwd() '\cnc\20161018dh\rtboxta_rtboxs7b1t_data.mat'];  %s7
    [pwd() '\cnc\20161019bi\rtboxta_rtboxs3b1t_data.mat'];  %s8
    [pwd() '\cnc\20161020ms\rtboxta_rtboxs7b1t_data.mat'];  %s9
    [pwd() '\cnc\20161027fw\rtboxta_rtboxs3b1t_data.mat'];  %s10
    [pwd() '\cnc\20161027lk\rtboxta_rtboxs7b1t_data.mat'];  %s11
    [pwd() '\cnc\20161107bx\rtboxta_rtboxs3b1t_data.mat'];  %s12
    };

CNCB2files = {
    [pwd() '\cnc\20161010dl\rtboxta_rtboxs3b1nt_data.mat'];  %s1
    [pwd() '\cnc\20161011di\rtboxta_rtboxs7b1nt_data.mat'];  %s2
    [pwd() '\cnc\20161014bl\rtboxta_rtboxs3b1nt_data.mat'];  %s3
    [pwd() '\cnc\20161017di\rtboxta_rtboxs7b1nt_data.mat'];  %s4
    [pwd() '\cnc\20161017bx\rtboxta_rtboxs3b1nt_data.mat'];  %s5
    [pwd() '\cnc\20161018gu\rtboxta_rtboxs7b1nt_data.mat'];  %s6
    [pwd() '\cnc\20161018dh\rtboxta_rtboxs3b1nt_data.mat'];  %s7
    [pwd() '\cnc\20161019bi\rtboxta_rtboxs7b1nt_data.mat'];  %s8
    [pwd() '\cnc\20161020ms\rtboxta_rtboxs3b1nt_data.mat'];  %s9
    [pwd() '\cnc\20161027fw\rtboxta_rtboxs7b1nt_data.mat'];  %s10
    [pwd() '\cnc\20161027lk\rtboxta_rtboxs3b1nt_data.mat'];  %s11
    [pwd() '\cnc\20161107bx\rtboxta_rtboxs7b1nt_data.mat'];  %s12
    };

CNCB3files = {
    [pwd() '\cnc\20161010dl\rtboxta_rtboxs7b2t_data.mat'];  %s1
    [pwd() '\cnc\20161011di\rtboxta_rtboxs3b2t_data.mat'];  %s2
    [pwd() '\cnc\20161014bl\rtboxta_rtboxs7b2t_data.mat'];  %s3
    [pwd() '\cnc\20161017di\rtboxta_rtboxs3b2t_data.mat'];  %s4
    [pwd() '\cnc\20161017bx\rtboxta_rtboxs7b2t_data.mat'];  %s5
    [pwd() '\cnc\20161018gu\rtboxta_rtboxs3b2t_data.mat'];  %s6
    [pwd() '\cnc\20161018dh\rtboxta_rtboxs7b2t_data.mat'];  %s7
    [pwd() '\cnc\20161019bi\rtboxta_rtboxs3b2t_data.mat'];  %s8
    [pwd() '\cnc\20161020ms\rtboxta_rtboxs7b2t_data.mat'];  %s9
    [pwd() '\cnc\20161027fw\rtboxta_rtboxs3b2t_data.mat'];  %s10
    [pwd() '\cnc\20161027lk\rtboxta_rtboxs7b2t_data.mat'];  %s11
    [pwd() '\cnc\20161107bx\rtboxta_rtboxs3b2t_data.mat'];  %s12
    };

CNCexcluded = zeros(12,2);

clrplot = hsv(8);


%% CNC: Block 1 analysis

CNCB1Allrt = [];
CNCB1Allrtstd = [];
CNCB1Alllat = [];
for a = 1:8
    for b = 1:8
        CNCB1Reach(a,b).handxy = {};
        CNCB1trajrsmpl{a,b}.x = [];
        CNCB1trajrsmpl{a,b}.y = [];
        CNCB1trajrsmpl{a,b}.id = [];
    end
end

for a = 1:length(CNCB1files)
    temp = load(CNCB1files{a});
    
    for b = 1:8
        for c = 1:8
            CNCSubj(a).B1.rts{b,c} = [];
            CNCSubj(a).B1.acc{b,c} = [];
            CNCSubj(a).B1.excludedlats{b,c} = [];
        end
    end
    
    for b = 1:length(temp.reach)
        if (temp.reach(b).latency > 1000)
            temp.reach(b).latency = NaN;
            CNCSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];
        end
        CNCSubj(a).B1.rts{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B1.rts{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).latency];
        
        if ~isnan(temp.reach(b).latency)
            CNCB1Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end+1} = [temp.reach(b).handx-temp.reach(b).starttgt(1) temp.reach(b).handy-temp.reach(b).starttgt(2)];
            
            RotMat = [cos(-temp.reach(b).spath*pi/4) -sin(-temp.reach(b).spath*pi/4);
                sin(-temp.reach(b).spath*pi/4)  cos(-temp.reach(b).spath*pi/4)];
            
            %this is the actual rotated/centered hand path
            CNCB1Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end} = (RotMat*CNCB1Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end}')';
            
            %we will compile matrices of the temporally-resampled
            %   trajectories for calculating trajectory mean and variance
            x = temp.reach(b).handxspl-temp.reach(b).handxspl(1);
            y = temp.reach(b).handyspl-temp.reach(b).handyspl(2);
            traj = RotMat*[x; y];
            x = traj(1,:);
            y = traj(2,:);
            
            if any(x<-0.05 & x > -0.15 & y > 0.025)
                x = -x;
            elseif any(x<-0.05 & x > -0.15 & y < -0.025)
                x = -x;
                y = -y;
            elseif any(x>0.05 & x < 0.15 & y < -0.025)
                y = -y;
            end
            
            %now we code the exceptions
            if temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 2 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 4 && any(x < -0.05)
                x = -x;
                y = -y;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 5 && any(x < -0.05)
                x = -x;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 6 && any(x < -0.05)
                x = -x;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 6 && any(x > 0.05 & x < 0.1 & y < -0.01)
                y = -y;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 6 && any(x > 0.071 & x < 0.076 & y < -3e-3 & y > -10e-3)
                y = -y;
            elseif temp.reach(b).rottgt == 3 && temp.reach(b).rottpath == 4 && any(x < -0.02 & y < 0.04)
                x = -x;
            elseif temp.reach(b).rottgt == 3 && temp.reach(b).rottpath == 5 && any(x < -0.02 & y < 0.04)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 2 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 3 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 4 && any(x > 0 & y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 4 && any(x < -0.02 & y > 0 & y < 0.03)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 5 && any(y < -0.08)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 5 && any(x < -0.015 & y < 0.04 & y > 0)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 6 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 6 && any(x < -0.02 & y < 0.03 & y > 0)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 7 && any(y < -0.05)
                y = -y;
            end
            
            CNCB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x = [CNCB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x; x]; %every row is a trajectory
            CNCB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y = [CNCB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y; y];
            CNCB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id = [CNCB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id; [a temp.reach(b).spath temp.reach(b).tpath temp.reach(b).tgtcode]];
            
            
            CNCSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).acc.apeak];
        else
            CNCSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];

        end
        
    end
    
    for b = 1:8
        for c = 1:8
            CNCSubj(a).B1.rtmean(b,c) = nanmean(CNCSubj(a).B1.rts{b,c});
            CNCSubj(a).B1.rtstd(b,c) = nanstd(CNCSubj(a).B1.rts{b,c});
            
            CNCexcluded(a,1) = CNCexcluded(a,1) + sum(isnan(CNCSubj(a).B1.rts{b,c}));
        end
    end
    
    CNCB1Allrt = cat(3,CNCB1Allrt, CNCSubj(a).B1.rtmean);
    CNCB1Allrtstd = cat(3,CNCB1Allrtstd,CNCSubj(a).B1.rtstd);
    
    CNCB1Alllat = [CNCB1Alllat, temp.Latency];
    
    
    %we will also pull out the non-cannonical but still valid reach inds:
    clear alm1*
    ValidReachInds = reshape(temp.data.ValidReachInds,2,[])';
    ValidReachInds = ValidReachInds(:,1);
    CannonicalReachInds = reshape(temp.CannonicalReachInds,2,[])';
    CannonicalReachInds = CannonicalReachInds(:,1);
    for b = 1:8  %tgt
        for c = 1:8  %tpath
            CNCSubj(a).B1.excludedlats{b,c} = [];
        end
    end
    for b = 1:length(ValidReachInds)
        ind = find(CannonicalReachInds == ValidReachInds(b));
        if isempty(ind)
            ind = find(temp.data.AllreachInds(:,1) == ValidReachInds(b));  %this is the index into the reach array
            tmplat = temp.data.Time(temp.data.AllreachInds(b,1))-temp.data.Time(temp.data.TargetInds(b,1));
            if tmplat > 1000
                tmplat = NaN;
            end
            c = temp.tgts(b);
            d = temp.tpaths(b);
            CNCSubj(a).B1.excludedlats{c,d}(end+1,1) = tmplat;
        end
    end
    for b = 1:8
        for c = 1:8
            CNCSubj(a).B1.alllats(b,c) = nanmean([CNCSubj(a).B1.rts{b,c}; CNCSubj(a).B1.excludedlats{b,c}]);
            CNCSubj(a).B1.alllatsstd(b,c) = nanstd([CNCSubj(a).B1.rts{b,c}; CNCSubj(a).B1.excludedlats{b,c}]);
        end
    end
    
end

pairs = [1 2 1 8;
         1 3 1 7;
         1 4 1 6;
         2 1 8 1;
         2 2 8 8;
         2 3 8 7;
         2 4 8 6;
         2 5 8 5;
         2 6 8 4;
         2 7 8 3;
         2 8 8 2;
         3 1 7 1;
         3 2 7 8;
         3 3 7 7;
         3 4 7 6;
         3 5 7 5;
         3 6 7 4;
         3 7 7 3;
         3 8 7 2;
        ];

sametrajlats = [];
for a = 1:size(pairs,1)
    means = [nanmean(CNCB1Allrt(pairs(a,1),pairs(a,2),:)) nanmean(CNCB1Allrt(pairs(a,3),pairs(a,4),:))];
    stds = [nanstd(CNCB1Allrt(pairs(a,1),pairs(a,2),:)) nanstd(CNCB1Allrt(pairs(a,3),pairs(a,4),:))]/sqrt(12);
    sametrajlats = [sametrajlats; means];
end
[~,p_sametrajlats_CNC1] = ttest(sametrajlats(:,1),sametrajlats(:,2));


%% CNC: Block 2 analysis

CNCB2Allrt = [];
CNCB2Allrtstd = [];
CNCB2Alllat = [];
for a = 1:8
    for b = 1:8
        CNCB2Reach(a,b).handxy = {};
        CNCB2trajrsmpl{a,b}.x = [];
        CNCB2trajrsmpl{a,b}.y = [];
        CNCB2trajrsmpl{a,b}.id = [];
    end
end

for a = 1:length(CNCB2files)
    temp = load(CNCB2files{a});
    
    for b = 1:8
        for c = 1:8
            CNCSubj(a).B2.rts{b,c} = [];
            CNCSubj(a).B2.acc{b,c} = [];
            CNCSubj(a).B2.excludedlats{b,c} = [];
        end
    end
    
    for b = 1:length(temp.reach)
        if (temp.reach(b).latency > 1000)
            temp.reach(b).latency = NaN;
            CNCSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];
        end
        CNCSubj(a).B2.rts{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B2.rts{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).latency];
        
        if ~isnan(temp.reach(b).latency)
            CNCB2Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end+1} = [temp.reach(b).handx-temp.reach(b).starttgt(1) temp.reach(b).handy-temp.reach(b).starttgt(2)];
            
            RotMat = [cos(-temp.reach(b).spath*pi/4) -sin(-temp.reach(b).spath*pi/4);
                sin(-temp.reach(b).spath*pi/4)  cos(-temp.reach(b).spath*pi/4)];
            
            %this is the actual rotated/centered hand path
            CNCB2Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end} = (RotMat*CNCB2Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end}')';
            
            %we will compile matrices of the temporally-resampled
            %   trajectories for calculating trajectory mean and variance
            x = temp.reach(b).handxspl-temp.reach(b).handxspl(1);
            y = temp.reach(b).handyspl-temp.reach(b).handyspl(2);
            traj = RotMat*[x; y];
            x = traj(1,:);
            y = traj(2,:);
            
            if any(x<-0.05 & x > -0.15 & y > 0.025)
                x = -x;
            elseif any(x<-0.05 & x > -0.15 & y < -0.025)
                x = -x;
                y = -y;
            elseif any(x>0.05 & x < 0.15 & y < -0.025)
                y = -y;
            end
            
            if temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 1 && any(y < -0.04)
                y = -y;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 5 && any(x < -0.05)
                x = -x;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 6 && any(x < -0.05)
                x = -x;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 6 && any(x > 0.06 & x < 0.08 & y < 0)
                y = -y;
            elseif temp.reach(b).rottgt == 3 && temp.reach(b).rottpath == 4 && any(x < -0.01 & y < 0.04)
                x = -x;
            elseif temp.reach(b).rottgt == 3 && temp.reach(b).rottpath == 5 && any(x < -0.01 & y < 0.04)
                x = -x;
            elseif temp.reach(b).rottgt == 3 && temp.reach(b).rottpath == 6 && any(x < -0.02 & y < 0.04)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 1 && any(y < -0.08)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 2 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 3 && any(y < -0.04)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 4 && any(y < -0.04)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 5 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 5 && any(x < -0.02 & y < 0.04)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 6 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 6 && any(x < -0.02 & y < 0.04)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 8 && any(y < -0.08)
                y = -y;
            end
            
            
            CNCB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x = [CNCB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x; x]; %every row is a trajectory
            CNCB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y = [CNCB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y; y];
            CNCB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id = [CNCB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id; [a temp.reach(b).spath temp.reach(b).tpath temp.reach(b).tgtcode]];
            
            CNCSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).acc.apeak];
        else
            CNCSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];

        end
        
    end
    
    for b = 1:8
        for c = 1:8
            CNCSubj(a).B2.rtmean(b,c) = nanmean(CNCSubj(a).B2.rts{b,c});
            CNCSubj(a).B2.rtstd(b,c) = nanstd(CNCSubj(a).B2.rts{b,c});
            
            CNCexcluded(a,2) = CNCexcluded(a,2) + sum(isnan(CNCSubj(a).B2.rts{b,c}));
        end
    end
    
    CNCB2Allrt = cat(3,CNCB2Allrt, CNCSubj(a).B2.rtmean);
    CNCB2Allrtstd = cat(3,CNCB2Allrtstd,CNCSubj(a).B2.rtstd);
    
    CNCB2Alllat = [CNCB2Alllat, temp.Latency];
    
    
    %we will also pull out the non-cannonical but still valid reach inds:
    clear alm1*
    ValidReachInds = reshape(temp.data.ValidReachInds,2,[])';
    ValidReachInds = ValidReachInds(:,1);
    CannonicalReachInds = reshape(temp.CannonicalReachInds,2,[])';
    CannonicalReachInds = CannonicalReachInds(:,1);
    for b = 1:8  %tgt
        for c = 1:8  %tpath
            CNCSubj(a).B2.excludedlats{b,c} = [];
        end
    end
    for b = 1:length(ValidReachInds)
        ind = find(CannonicalReachInds == ValidReachInds(b));
        if isempty(ind)
            ind = find(temp.data.AllreachInds(:,1) == ValidReachInds(b));  %this is the index into the reach array
            tmplat = temp.data.Time(temp.data.AllreachInds(b,1))-temp.data.Time(temp.data.TargetInds(b,1));
            if tmplat > 1000
                tmplat = NaN;
            end
            c = temp.tgts(b);
            d = temp.tpaths(b);
            CNCSubj(a).B2.excludedlats{c,d}(end+1) = tmplat;
        end
    end
    for b = 1:8
        for c = 1:8
            CNCSubj(a).B2.alllats(b,c) = nanmean([CNCSubj(a).B2.rts{b,c}; reshape(CNCSubj(a).B2.excludedlats{b,c},[],1)]);
            CNCSubj(a).B2.alllatsstd(b,c) = nanstd([CNCSubj(a).B2.rts{b,c}; reshape(CNCSubj(a).B2.excludedlats{b,c},[],1)]);
        end
    end
    
    
end

sametrajlats = [];
for a = 1:size(pairs,1)
    means = [nanmean(CNCB2Allrt(pairs(a,1),pairs(a,2),:)) nanmean(CNCB2Allrt(pairs(a,3),pairs(a,4),:))];
    stds = [nanstd(CNCB2Allrt(pairs(a,1),pairs(a,2),:)) nanstd(CNCB2Allrt(pairs(a,3),pairs(a,4),:))]/sqrt(12);
    sametrajlats = [sametrajlats; means];
end
[~,p_sametrajlats_CNC2] = ttest(sametrajlats(:,1),sametrajlats(:,2));

%% CNC: Block 3 analysis

CNCB3Allrt = [];
CNCB3Allrtstd = [];
CNCB3Alllat = [];
for a = 1:8
    for b = 1:8
        CNCB3Reach(a,b).handxy = {};
        CNCB3trajrsmpl{a,b}.x = [];
        CNCB3trajrsmpl{a,b}.y = [];
        CNCB3trajrsmpl{a,b}.id = [];
    end
end

for a = 1:length(CNCB3files)
    temp = load(CNCB3files{a});
    
    for b = 1:8
        for c = 1:8
            CNCSubj(a).B3.rts{b,c} = [];
            CNCSubj(a).B3.acc{b,c} = [];
            CNCSubj(a).B3.excludedlats{b,c} = [];
        end
    end
    
    for b = 1:length(temp.reach)
        if (temp.reach(b).latency > 1000)
            temp.reach(b).latency = NaN;
            CNCSubj(a).B3.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B3.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];
        end
        CNCSubj(a).B3.rts{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B3.rts{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).latency];
        
        if ~isnan(temp.reach(b).latency)
            CNCB3Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end+1} = [temp.reach(b).handx-temp.reach(b).starttgt(1) temp.reach(b).handy-temp.reach(b).starttgt(2)];
            
            RotMat = [cos(-temp.reach(b).spath*pi/4) -sin(-temp.reach(b).spath*pi/4);
                sin(-temp.reach(b).spath*pi/4)  cos(-temp.reach(b).spath*pi/4)];
            
            %this is the actual rotated/centered hand path
            CNCB3Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end} = (RotMat*CNCB3Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end}')';
            
            %we will compile matrices of the temporally-resampled
            %   trajectories for calculating trajectory mean and variance
            x = temp.reach(b).handxspl-temp.reach(b).handxspl(1);
            y = temp.reach(b).handyspl-temp.reach(b).handyspl(2);
            traj = RotMat*[x; y];
            x = traj(1,:);
            y = traj(2,:);
            
            if any(x<-0.05 & x > -0.15 & y > 0.025)
                x = -x;
            elseif any(x<-0.05 & x > -0.15 & y < -0.025)
                x = -x;
                y = -y;
            elseif any(x>0.05 & x < 0.15 & y < -0.025)
                y = -y;
            end
            
            if temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 4 && any(x < -0.05)
                x = -x;
                y = -y;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 5 && any(x < -0.05)
                x = -x;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 6 && any(x < -0.05)
                x = -x;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 6 && any(x > 0.07 & x < 0.1 & y < 0)
                y = -y;
            elseif temp.reach(b).rottgt == 3 && temp.reach(b).rottpath == 4 && any(x < -0.02 & y < 0.04)
                x = -x;
            elseif temp.reach(b).rottgt == 3 && temp.reach(b).rottpath == 5 && any(x < -0.02 & y < 0.03)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 2 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 3 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 4 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 5 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 5 && any(x < -0.02 & y < 0.03)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 6 && any(y < -0.05)
                y = -y;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 6 && any(x < -0.02 & y < 0.03)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 7 && any(y < -0.05)
                y = -y;
            end
            
            CNCB3trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x = [CNCB3trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x; x]; %every row is a trajectory
            CNCB3trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y = [CNCB3trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y; y];
            CNCB3trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id = [CNCB3trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id; [a+12 temp.reach(b).spath temp.reach(b).tpath temp.reach(b).tgtcode]];
            
            CNCSubj(a).B3.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B3.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).acc.apeak];
        else
            CNCSubj(a).B3.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [CNCSubj(a).B3.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];

        end
        
    end
    
    for b = 1:8
        for c = 1:8
            CNCSubj(a).B3.rtmean(b,c) = nanmean(CNCSubj(a).B3.rts{b,c});
            CNCSubj(a).B3.rtstd(b,c) = nanstd(CNCSubj(a).B3.rts{b,c});
            
            CNCexcluded(a,1) = CNCexcluded(a,1) + sum(isnan(CNCSubj(a).B3.rts{b,c}));
        end
    end
    
    CNCB3Allrt = cat(3,CNCB3Allrt, CNCSubj(a).B3.rtmean);
    CNCB3Allrtstd = cat(3,CNCB3Allrtstd,CNCSubj(a).B3.rtstd);
    
    CNCB3Alllat = [CNCB3Alllat, temp.Latency];
    
    %we will also pull out the non-cannonical but still valid reach inds:
    clear alm1*
    ValidReachInds = reshape(temp.data.ValidReachInds,2,[])';
    ValidReachInds = ValidReachInds(:,1);
    CannonicalReachInds = reshape(temp.CannonicalReachInds,2,[])';
    CannonicalReachInds = CannonicalReachInds(:,1);
    for b = 1:8  %tgt
        for c = 1:8  %tpath
            CNCSubj(a).B3.excludedlats{b,c} = [];
        end
    end
    for b = 1:length(ValidReachInds)
        ind = find(CannonicalReachInds == ValidReachInds(b));
        if isempty(ind)
            ind = find(temp.data.AllreachInds(:,1) == ValidReachInds(b));  %this is the index into the reach array
            tmplat = temp.data.Time(temp.data.AllreachInds(b,1))-temp.data.Time(temp.data.TargetInds(b,1));
            if tmplat > 1000
                tmplat = NaN;
            end
            c = temp.tgts(b);
            d = temp.tpaths(b);
            CNCSubj(a).B3.excludedlats{c,d}(end+1,1) = tmplat;
        end
    end
    for b = 1:8
        for c = 1:8
            CNCSubj(a).B3.alllats(b,c) = nanmean([CNCSubj(a).B3.rts{b,c}; CNCSubj(a).B3.excludedlats{b,c}]);
            CNCSubj(a).B3.alllatsstd(b,c) = nanstd([CNCSubj(a).B3.rts{b,c}; CNCSubj(a).B3.excludedlats{b,c}]);
        end
    end
    
    
end

sametrajlats = [];
for a = 1:size(pairs,1)
    means = [nanmean(CNCB3Allrt(pairs(a,1),pairs(a,2),:)) nanmean(CNCB3Allrt(pairs(a,3),pairs(a,4),:))];
    stds = [nanstd(CNCB3Allrt(pairs(a,1),pairs(a,2),:)) nanstd(CNCB3Allrt(pairs(a,3),pairs(a,4),:))]/sqrt(12);
    sametrajlats = [sametrajlats; means];
end
[~,p_sametrajlats_CNC1] = ttest(sametrajlats(:,1),sametrajlats(:,2));



%% CNC - data plots

plotstr{1,1} = 'r-';
plotstr{1,2} = 'b-';
plotstr{1,3} = 'm-';

%figure: RT as a function of trial
figure(2)
clf;
%we will plot every row of B1AllRT
cmap = hsv(size(CNCB1Alllat,1));
errorfield([1:size(CNCB1Alllat,1)],nanmean(CNCB1Alllat(:,:)-rtdelay,2),nanstd(CNCB1Alllat(:,:)-rtdelay,[],2)/sqrt(length(CNCB1files)),[plotstr{1,1} 'o']);
hold on;
errorfield([size(CNCB1Alllat,1)+1:size(CNCB1Alllat,1)+size(CNCB2Alllat,1)],nanmean(CNCB2Alllat(:,:)-rtdelay,2),nanstd(CNCB2Alllat(:,:)-rtdelay,[],2)/sqrt(length(CNCB1files)),[plotstr{1,2} 's']);
errorfield([size(CNCB1Alllat,1)+size(CNCB2Alllat,1)+1:size(CNCB1Alllat,1)+size(CNCB2Alllat,1)+size(CNCB3Alllat,1)],nanmean(CNCB3Alllat(:,:)-rtdelay,2),nanstd(CNCB3Alllat(:,:)-rtdelay,[],2)/sqrt(length(CNCB1files)),[plotstr{1,3} '^']);
ylims = [260 480];
plot([size(CNCB1Alllat,1)+0.5 size(CNCB1Alllat,1)+0.5],ylims,'k:');
plot([size(CNCB1Alllat,1)+size(CNCB2Alllat,1)+0.5 size(CNCB1Alllat,1)+size(CNCB2Alllat,1)+0.5],ylims,'k:');
hold off;
xlabel('Trial');
ylabel('Latency (ms)');
set(gca,'ylim',[260 480],'box','off');


%% summary data plot

y = [nanmean(squeeze(nanmean(nanmean(CNCB1Allrt,2),1))) nanmean(squeeze(nanmean(nanmean(CNCB2Allrt,2),1)))  nanmean(squeeze(nanmean(nanmean(CNCB3Allrt,2),1)));
    ]-rtdelay;
ystd = [nanstd(squeeze(nanmean(nanmean(CNCB1Allrt,2),1)))/sqrt(size(CNCB1Allrt,3)) nanstd(squeeze(nanmean(nanmean(CNCB2Allrt,2),1)))/sqrt(size(CNCB2Allrt,3)) nanstd(squeeze(nanmean(nanmean(CNCB3Allrt,2),1)))/sqrt(size(CNCB3Allrt,3));
    ];

figure(25)
h = bar(y);
hold on
errorbar([1 2 3], y, ystd,'k.')
hold off;
xlabel('Block');
ylabel('Reaction time (ms)');
set(gca,'box','off','xtick',[1 2 3],'xticklabel',{'Cue','No Cue','Cue'});


%% individual subjects RT vs pdist

y = [squeeze(nanmean(nanmean(CNCB1Allrt,2),1)) squeeze(nanmean(nanmean(CNCB2Allrt,2),1)) squeeze(nanmean(nanmean(CNCB3Allrt,2),1))]-rtdelay;
figure(26)
bar([1 2 3],[nanmean(y(:,2)-y(:,1)) nanmean(y(:,3)-y(:,1)) nanmean(y(:,3)-y(:,2))]);
hold on
plot(repmat([1 2 3],size(y,1),1)',[y(:,2)-y(:,1),y(:,3)-y(:,1),y(:,3)-y(:,2)]','k.-')
hold off;set(gca,'xtick',[1 2 3],'xticklabel',{'NT-T1','T2-T1','T2-NT'},'box','off');

ylabel('Change in RT')
xlabel('Group');




%% output data to R for analysis

if (true)

idata = 1;
Data{1,1} = 'Subject';
Data{1,2} = 'Condition';  %Trace1 / No-Trace / Trace2
Data{1,3} = 'Block';
Data{1,4} = 'TB';
Data{1,5} = 'TrialNum';
Data{1,6} = 'Trial';
Data{1,7} = 'Lat';

for a = 1:length(CNCB1files)
    temp = load(CNCB1files{a});
    
    itgtbarN = zeros(8,8);
    
    for b = 1:length(temp.reach)
        
        idata = idata+1;
        
        Data{idata,1} = sprintf('S%d',a); %Subject ID
        Data{idata,2} = 'T'; %Condition - Trace
        Data{idata,3} = 1; %Block
        Data{idata,4} = (temp.reach(b).rottgt-1)*8+(temp.reach(b).rottpath-1);
        
        itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath) = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath)+1;
        Data{idata,5} = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath);
        Data{idata,6} = b;
        Data{idata,7} = temp.reach(b).latency-rtdelay;
        
    end  %end for all reaches
    
    
    temp = load(CNCB2files{a});
    
    itgtbarN = zeros(8,8);
    
    for b = 1:length(temp.reach)
        
        idata = idata+1;
        
        Data{idata,1} = sprintf('S%d',a); %Subject ID
        Data{idata,2} = 'NT'; %Condition - No Trace
        Data{idata,3} = 2; %Block
        Data{idata,4} = (temp.reach(b).rottgt-1)*8+(temp.reach(b).rottpath-1);
        
        itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath) = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath)+1;
        Data{idata,5} = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath);
        Data{idata,6} = b;
        Data{idata,7} = temp.reach(b).latency-rtdelay;
        
    end  %end for all reaches
    
    
    temp = load(CNCB3files{a});
    
    itgtbarN = zeros(8,8);
    
    for b = 1:length(temp.reach)
        
        idata = idata+1;
        
        Data{idata,1} = sprintf('S%d',a); %Subject ID
        Data{idata,2} = 'T'; %Condition - Trace
        Data{idata,3} = 3; %Block
        Data{idata,4} = (temp.reach(b).rottgt-1)*8+(temp.reach(b).rottpath-1);
        
        itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath) = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath)+1;
        Data{idata,5} = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath);
        Data{idata,6} = b;
        Data{idata,7} = temp.reach(b).latency-rtdelay;
        
    end  %end for all reaches
    
end  %end for all subjects


fpath = [pwd() '\r data analysis\'];

fid = fopen([fpath 'rtcnc.txt'],'wt');
a = 1;
fprintf(fid,'"%s" "%s" "%s" "%s" "%s" "%s" "%s"\n',Data{a,1},Data{a,2},Data{a,3},Data{a,4},Data{a,5}, Data{a,6}, Data{a,7});
for a = 2:size(Data,1)
    fprintf(fid,'%d "%s" "%s" "%d" "%d" "%d" "%d" %.3f\n',(a-1),Data{a,1},Data{a,2},Data{a,3},Data{a,4}, Data{a,5}, Data{a,6}, Data{a,7});
end

fclose(fid);

end

%% output data for trajectory Procrustes distance analysis

if (false)

for a = 1:8
    for b = 1:8
        CNCb1X{a,b} = CNCB1trajrsmpl{a,b}.x;
        CNCb1Y{a,b} = CNCB1trajrsmpl{a,b}.y;
        CNCb1ID{a,b} = CNCB1trajrsmpl{a,b}.id;
        
        CNCb2X{a,b} = CNCB2trajrsmpl{a,b}.x;
        CNCb2Y{a,b} = CNCB2trajrsmpl{a,b}.y;
        CNCb2ID{a,b} = CNCB2trajrsmpl{a,b}.id;
        
        CNCB3X{a,b} = CNCB3trajrsmpl{a,b}.x;
        CNCB3Y{a,b} = CNCB3trajrsmpl{a,b}.y;
        CNCB3ID{a,b} = CNCB3trajrsmpl{a,b}.id;

    end
end

save([pwd() '\cnc\resampled_trajectories_ALL.mat'],'CNCb1X','CNCb1Y','CNCb1ID','CNCb2X','CNCb2Y','CNCb2ID','CNCB3X','CNCB3Y','CNCB3ID','CNCb2X','CNCb2Y','CNCb2ID');

rttraj_exp2b_trajanalysis_traj();

end