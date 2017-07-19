%This code compiles data across subjects for the RT-Habit RT analysis. The
% data files are hard-coded paths.
%This code assumes that you have previously analyzed all raw data, done an
% initial compile of the data using this script, and then run
% 'rttraj_trajanalysis.m' to compute the Procrustes distance metrics. Then
% this script will run completely.
%
%Code by: Aaron L. Wong

%clear all;
close all;
warning('off');

rtdelay = 105;

%full experimental version: control and task

NTFntfiles = {
    [pwd() '\notracefirst\20150323wg\rtboxta_rtboxs3b1nt_data.mat'];  %s1
    [pwd() '\notracefirst\20150331bi\rtboxta_rtboxs7b2nt_data.mat'];  %s2
    [pwd() '\notracefirst\20150413bi\rtboxta_rtboxs3b3nt_data.mat'];  %s3
    [pwd() '\notracefirst\20150416mh\rtboxta_rtboxs7b4nt_data.mat'];  %s4
    [pwd() '\notracefirst\20150508ew\rtboxta_rtboxs3b2nt_data.mat'];  %s5
    [pwd() '\notracefirst\20150513ne\rtboxta_rtboxs7b4nt_data.mat'];  %s6
    [pwd() '\notracefirst\20150529ts\rtboxta_rtboxs3b4nt_data.mat'];  %s7
    [pwd() '\notracefirst\20150604wn\rtboxta_rtboxs7b1nt_data.mat'];  %s8
    [pwd() '\notracefirst\20150724db\rtboxta_rtboxs3b3nt_data.mat'];  %s9
    [pwd() '\notracefirst\20150806bb\rtboxta_rtboxs7b1nt_data.mat'];  %s10
    [pwd() '\notracefirst\20150811dm\rtboxta_rtboxs3b1nt_data.mat'];  %s11
    [pwd() '\notracefirst\20150813th\rtboxta_rtboxs7b3nt_data.mat'];  %s12
    };

NTFtfiles = {
    [pwd() '\notracefirst\20150323wg\rtboxta_rtboxs7b1t_data.mat'];   %s1
    [pwd() '\notracefirst\20150331bi\rtboxta_rtboxs3b2t_data.mat'];   %s2
    [pwd() '\notracefirst\20150413bi\rtboxta_rtboxs7b3t_data.mat'];   %s3
    [pwd() '\notracefirst\20150416mh\rtboxta_rtboxs3b4t_data.mat'];   %s4
    [pwd() '\notracefirst\20150508ew\rtboxta_rtboxs7b2t_data.mat'];   %s5
    [pwd() '\notracefirst\20150513ne\rtboxta_rtboxs3b4t_data.mat'];   %s6
    [pwd() '\notracefirst\20150529ts\rtboxta_rtboxs7b4t_data.mat'];   %s7
    [pwd() '\notracefirst\20150604wn\rtboxta_rtboxs3b1t_data.mat'];   %s8
    [pwd() '\notracefirst\20150724db\rtboxta_rtboxs7b3t_data.mat'];   %s9
    [pwd() '\notracefirst\20150806bb\rtboxta_rtboxs3b1t_data.mat'];   %s10
    [pwd() '\notracefirst\20150811dm\rtboxta_rtboxs7b1t_data.mat'];   %s11
    [pwd() '\notracefirst\20150813th\rtboxta_rtboxs3b3t_data.mat'];   %s12
    };

%cue first
TFtfiles = {
    [pwd() '\tracefirst\20150325lg\rtboxta_rtboxs3b1t_data.mat'];     %c1
    [pwd() '\tracefirst\20150403mx\rtboxta_rtboxs7b2t_data.mat'];     %c2
    [pwd() '\tracefirst\20150409zi\rtboxta_rtboxs3b4t_data.mat'];     %c3
    [pwd() '\tracefirst\20150506mf\rtboxta_rtboxs7b3t_data.mat'];     %c4
    [pwd() '\tracefirst\20150511qt\rtboxta_rtboxs3b1t_data.mat'];     %c5
    [pwd() '\tracefirst\20150518th\rtboxta_rtboxs7b3t_data.mat'];     %c6
    [pwd() '\tracefirst\20150528ml\rtboxta_rtboxs3b2t_data.mat'];     %c7
    [pwd() '\tracefirst\20150721ec\rtboxta_rtboxs7b1t_data.mat'];     %c8
    [pwd() '\tracefirst\20150728ol\rtboxta_rtboxs3b4t_data.mat'];     %c9
    [pwd() '\tracefirst\20150730nu\rtboxta_rtboxs7b4t_data.mat'];     %c10
    [pwd() '\tracefirst\20150812bg\rtboxta_rtboxs3b3t_data.mat'];     %c11
    [pwd() '\tracefirst\20150817oe\rtboxta_rtboxs7b1t_data.mat'];     %c12
    };

TFntfiles = {
    [pwd() '\tracefirst\20150325lg\rtboxta_rtboxs7b1nt_data.mat'];    %c1
    [pwd() '\tracefirst\20150403mx\rtboxta_rtboxs3b2nt_data.mat'];    %c2
    [pwd() '\tracefirst\20150409zi\rtboxta_rtboxs7b4nt_data.mat'];    %c3
    [pwd() '\tracefirst\20150506mf\rtboxta_rtboxs3b3nt_data.mat'];    %c4
    [pwd() '\tracefirst\20150511qt\rtboxta_rtboxs7b1nt_data.mat'];    %c5
    [pwd() '\tracefirst\20150518th\rtboxta_rtboxs3b3nt_data.mat'];    %c6
    [pwd() '\tracefirst\20150528ml\rtboxta_rtboxs7b2nt_data.mat'];    %c7
    [pwd() '\tracefirst\20150721ec\rtboxta_rtboxs3b1nt_data.mat'];    %c8
    [pwd() '\tracefirst\20150728ol\rtboxta_rtboxs7b4nt_data.mat'];    %c9
    [pwd() '\tracefirst\20150730nu\rtboxta_rtboxs3b4nt_data.mat'];    %c10
    [pwd() '\tracefirst\20150812bg\rtboxta_rtboxs7b3nt_data.mat'];    %c11
    [pwd() '\tracefirst\20150817oe\rtboxta_rtboxs3b1nt_data.mat'];    %c12
    };



%no-cue-first group
NTFB1files = NTFntfiles;
NTFB2files = NTFtfiles;

%cue-first group
TFB1files = TFtfiles;
TFB2files = TFntfiles;


NTFexcluded = zeros(12,2);
TFexcluded = zeros(12,2);

clrplot = hsv(8);



%% NTF: Block 1 analysis

NTFB1Allrt = [];
NTFB1Allrtstd = [];
NTFB1Alllat = [];
for a = 1:8
    for b = 1:8
        NTFB1Reach(a,b).handxy = {};
        NTFB1trajrsmpl{a,b}.x = [];
        NTFB1trajrsmpl{a,b}.y = [];
        NTFB1trajrsmpl{a,b}.id = [];
    end
end

for a = 1:length(NTFB1files)
    temp = load(NTFB1files{a});
    
    for b = 1:8
        for c = 1:8
            NTFSubj(a).B1.rts{b,c} = [];
            NTFSubj(a).B1.acc{b,c} = [];
            NTFSubj(a).B1.excludedlats{b,c} = [];
        end
    end
    
    scorei = findTarget(temp.data.Time,temp.data.TrialScore+1,temp.data.TrialScore+1);
    NTFSubj(a).B1.Score = sum(temp.data.TrialScore(scorei+1));
    
    for b = 1:length(temp.reach)
        if (temp.reach(b).latency > 1000)
            temp.reach(b).latency = NaN;
            NTFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [NTFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];
        end
        NTFSubj(a).B1.rts{temp.reach(b).rottgt,temp.reach(b).rottpath} = [NTFSubj(a).B1.rts{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).latency];
        
        if ~isnan(temp.reach(b).latency)
            NTFB1Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end+1} = [temp.reach(b).handx-temp.reach(b).starttgt(1) temp.reach(b).handy-temp.reach(b).starttgt(2)];
            
            RotMat = [cos(-temp.reach(b).spath*pi/4) -sin(-temp.reach(b).spath*pi/4);
                sin(-temp.reach(b).spath*pi/4)  cos(-temp.reach(b).spath*pi/4)];
            
            %this is the actual rotated/centered hand path
            NTFB1Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end} = (RotMat*NTFB1Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end}')';
            
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
            
            NTFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x = [NTFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x; x]; %every row is a trajectory
            NTFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y = [NTFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y; y];
            NTFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id = [NTFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id; [a temp.reach(b).spath temp.reach(b).tpath temp.reach(b).tgtcode]];
            
            NTFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [NTFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).acc.apeak];
        else
            NTFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [NTFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];

        end
        
    end
    
    for b = 1:8
        for c = 1:8
            NTFSubj(a).B1.rtmean(b,c) = nanmean(NTFSubj(a).B1.rts{b,c});
            NTFSubj(a).B1.rtstd(b,c) = nanstd(NTFSubj(a).B1.rts{b,c});
            
            NTFexcluded(a,1) = NTFexcluded(a,1) + sum(isnan(NTFSubj(a).B1.rts{b,c}));
        end
    end
    
    NTFB1Allrt = cat(3,NTFB1Allrt, NTFSubj(a).B1.rtmean);
    NTFB1Allrtstd = cat(3,NTFB1Allrtstd,NTFSubj(a).B1.rtstd);
    
    NTFB1Alllat = [NTFB1Alllat, temp.Latency];
    
    
    
    %we will also pull out the non-cannonical but still valid reach inds:
    clear alm1*
    ValidReachInds = reshape(temp.data.ValidReachInds,2,[])';
    ValidReachInds = ValidReachInds(:,1);
    CannonicalReachInds = reshape(temp.CannonicalReachInds,2,[])';
    CannonicalReachInds = CannonicalReachInds(:,1);
    for b = 1:8  %tgt
        for c = 1:8  %tpath
            NTFSubj(a).B1.excludedlats{b,c} = [];
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
            NTFSubj(a).B1.excludedlats{c,d}(end+1,1) = tmplat;
        end
    end
    for b = 1:8
        for c = 1:8
            NTFSubj(a).B1.alllats(b,c) = nanmean([NTFSubj(a).B1.rts{b,c}; NTFSubj(a).B1.excludedlats{b,c}]);
            NTFSubj(a).B1.alllatsstd(b,c) = nanstd([NTFSubj(a).B1.rts{b,c}; NTFSubj(a).B1.excludedlats{b,c}]);
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
    means = [nanmean(NTFB1Allrt(pairs(a,1),pairs(a,2),:)) nanmean(NTFB1Allrt(pairs(a,3),pairs(a,4),:))];
    stds = [nanstd(NTFB1Allrt(pairs(a,1),pairs(a,2),:)) nanstd(NTFB1Allrt(pairs(a,3),pairs(a,4),:))]/sqrt(12);
    sametrajlats = [sametrajlats; means];
end
[~,p_sametrajlats_ntf1] = ttest(sametrajlats(:,1),sametrajlats(:,2));


%% NTF: Block 2 analysis

NTFB2Allrt = [];
NTFB2Allrtstd = [];
NTFB2Alllat = [];
for a = 1:8
    for b = 1:8
        NTFB2Reach(a,b).handxy = {};
        NTFB2trajrsmpl{a,b}.x = [];
        NTFB2trajrsmpl{a,b}.y = [];
        NTFB2trajrsmpl{a,b}.id = [];
    end
end

for a = 1:length(NTFB2files)
    temp = load(NTFB2files{a});
    
    for b = 1:8
        for c = 1:8
            NTFSubj(a).B2.rts{b,c} = [];
            NTFSubj(a).B2.acc{b,c} = [];
            NTFSubj(a).B2.excludedlats{b,c} = [];
        end
    end
    
    scorei = findTarget(temp.data.Time,temp.data.TrialScore+1,temp.data.TrialScore+1);
    NTFSubj(a).B2.Score = sum(temp.data.TrialScore(scorei+1));
    
    for b = 1:length(temp.reach)
        if (temp.reach(b).latency > 1000)
            temp.reach(b).latency = NaN;
            NTFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [NTFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];
        end
        NTFSubj(a).B2.rts{temp.reach(b).rottgt,temp.reach(b).rottpath} = [NTFSubj(a).B2.rts{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).latency];
        
        if ~isnan(temp.reach(b).latency)
            NTFB2Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end+1} = [temp.reach(b).handx-temp.reach(b).starttgt(1) temp.reach(b).handy-temp.reach(b).starttgt(2)];
            
            RotMat = [cos(-temp.reach(b).spath*pi/4) -sin(-temp.reach(b).spath*pi/4);
                sin(-temp.reach(b).spath*pi/4)  cos(-temp.reach(b).spath*pi/4)];
            
            %this is the actual rotated/centered hand path
            NTFB2Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end} = (RotMat*NTFB2Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end}')';
            
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
            
            
            NTFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x = [NTFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x; x]; %every row is a trajectory
            NTFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y = [NTFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y; y];
            NTFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id = [NTFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id; [a temp.reach(b).spath temp.reach(b).tpath temp.reach(b).tgtcode]];
            
            NTFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [NTFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).acc.apeak];
        else
            NTFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [NTFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];

        end
        
    end
    
    for b = 1:8
        for c = 1:8
            NTFSubj(a).B2.rtmean(b,c) = nanmean(NTFSubj(a).B2.rts{b,c});
            NTFSubj(a).B2.rtstd(b,c) = nanstd(NTFSubj(a).B2.rts{b,c});
            
            NTFexcluded(a,2) = NTFexcluded(a,2) + sum(isnan(NTFSubj(a).B2.rts{b,c}));
        end
    end
    
    NTFB2Allrt = cat(3,NTFB2Allrt, NTFSubj(a).B2.rtmean);
    NTFB2Allrtstd = cat(3,NTFB2Allrtstd,NTFSubj(a).B2.rtstd);
    
    NTFB2Alllat = [NTFB2Alllat, temp.Latency];
    
    
    %we will also pull out the non-cannonical but still valid reach inds:
    clear alm1*
    ValidReachInds = reshape(temp.data.ValidReachInds,2,[])';
    ValidReachInds = ValidReachInds(:,1);
    CannonicalReachInds = reshape(temp.CannonicalReachInds,2,[])';
    CannonicalReachInds = CannonicalReachInds(:,1);
    for b = 1:8  %tgt
        for c = 1:8  %tpath
            NTFSubj(a).B2.excludedlats{b,c} = [];
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
            NTFSubj(a).B2.excludedlats{c,d}(end+1) = tmplat;
        end
    end
    for b = 1:8
        for c = 1:8
            NTFSubj(a).B2.alllats(b,c) = nanmean([NTFSubj(a).B2.rts{b,c}; reshape(NTFSubj(a).B2.excludedlats{b,c},[],1)]);
            NTFSubj(a).B2.alllatsstd(b,c) = nanstd([NTFSubj(a).B2.rts{b,c}; reshape(NTFSubj(a).B2.excludedlats{b,c},[],1)]);
        end
    end
    
    
    
end

sametrajlats = [];
for a = 1:size(pairs,1)
    means = [nanmean(NTFB2Allrt(pairs(a,1),pairs(a,2),:)) nanmean(NTFB2Allrt(pairs(a,3),pairs(a,4),:))];
    stds = [nanstd(NTFB2Allrt(pairs(a,1),pairs(a,2),:)) nanstd(NTFB2Allrt(pairs(a,3),pairs(a,4),:))]/sqrt(12);
    sametrajlats = [sametrajlats; means];
end
[~,p_sametrajlats_ntf2] = ttest(sametrajlats(:,1),sametrajlats(:,2));


%% NTF across-block analysis

for a = 1:8
    for b = 1:8
        if isempty(NTFB1trajrsmpl{a,b}.x) && isempty(NTFB2trajrsmpl{a,b}.x)
            NTFHotellingT2(a,b,:) = NaN;
            continue;
        end
        
        ic = 0;
        for c = 1:5:201
            ic = ic+1;
            X1 = [];
            X2 = [];
            for d = 1:max(NTFB1trajrsmpl{a,b}.id(:,1))
                inds1 = NTFB1trajrsmpl{a,b}.id(:,1)==d;
                inds2 = NTFB2trajrsmpl{a,b}.id(:,1)==d;
                
                if ~any(inds1) || ~any(inds2)  %if subject is completely missing movements from either condition, skip that subject
                    continue;
                end
                
                X1 = [X1; nanmean(NTFB1trajrsmpl{a,b}.x(inds1,c)) nanmean(NTFB1trajrsmpl{a,b}.y(inds1,c))];
                X2 = [X2; nanmean(NTFB2trajrsmpl{a,b}.x(inds2,c)) nanmean(NTFB2trajrsmpl{a,b}.y(inds2,c))];
                
            end

            NTFHotellingT2(a,b,ic) = HotellingT2([X1; X2],0.05,2,2,'nooutput');
        end
        
    end
end


sametrajlats = [];
for a = 1:size(pairs,1)
    x1 = [squeeze(NTFB1Allrt(pairs(a,1),pairs(a,2),:)), squeeze(NTFB1Allrt(pairs(a,3),pairs(a,4),:))];
    x2 = [squeeze(NTFB2Allrt(pairs(a,1),pairs(a,2),:)), squeeze(NTFB2Allrt(pairs(a,3),pairs(a,4),:))];
    means = [nanmean(nanmean(x1)) nanmean(nanmean(x2))];
    stds = [nanstd(nanmean(x1,2)) nanstd(nanmean(x2,2))]/sqrt(12);
    sametrajlats = [sametrajlats; means];
end
[~,p_sametrajlats_ntfblkcmp] = ttest(sametrajlats(:,1),sametrajlats(:,2));



%% TF: Block 1 analysis

TFB1Allrt = [];
TFB1Allrtstd = [];
TFB1Alllat = [];
for a = 1:8
    for b = 1:8
        TFB1Reach(a,b).handxy = {};
        TFB1trajrsmpl{a,b}.x = [];
        TFB1trajrsmpl{a,b}.y = [];
        TFB1trajrsmpl{a,b}.id = [];
    end
end

for a = 1:length(TFB1files)
    temp = load(TFB1files{a});
    
    for b = 1:8
        for c = 1:8
            TFSubj(a).B1.rts{b,c} = [];
            TFSubj(a).B1.acc{b,c} = [];
            TFSubj(a).B1.excludedlats{b,c} = [];
        end
    end
    
    scorei = findTarget(temp.data.Time,temp.data.TrialScore+1,temp.data.TrialScore+1);
    TFSubj(a).B1.Score = sum(temp.data.TrialScore(scorei+1));

    
    for b = 1:length(temp.reach)
        if (temp.reach(b).latency > 1000)
            temp.reach(b).latency = NaN;
            TFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [TFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];
        end
        TFSubj(a).B1.rts{temp.reach(b).rottgt,temp.reach(b).rottpath} = [TFSubj(a).B1.rts{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).latency];
        
        if ~isnan(temp.reach(b).latency)
            TFB1Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end+1} = [temp.reach(b).handx-temp.reach(b).starttgt(1) temp.reach(b).handy-temp.reach(b).starttgt(2)];
            
            RotMat = [cos(-temp.reach(b).spath*pi/4) -sin(-temp.reach(b).spath*pi/4);
                sin(-temp.reach(b).spath*pi/4)  cos(-temp.reach(b).spath*pi/4)];
            
            %this is the actual rotated/centered hand path
            TFB1Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end} = (RotMat*TFB1Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end}')';
            
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
            
            TFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x = [TFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x; x]; %every row is a trajectory
            TFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y = [TFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y; y];
            TFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id = [TFB1trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id; [a+12 temp.reach(b).spath temp.reach(b).tpath temp.reach(b).tgtcode]];
            
            TFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [TFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).acc.apeak];
        else
            TFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [TFSubj(a).B1.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];

        end
        
    end
    
    for b = 1:8
        for c = 1:8
            TFSubj(a).B1.rtmean(b,c) = nanmean(TFSubj(a).B1.rts{b,c});
            TFSubj(a).B1.rtstd(b,c) = nanstd(TFSubj(a).B1.rts{b,c});
            
            TFexcluded(a,1) = TFexcluded(a,1) + sum(isnan(TFSubj(a).B1.rts{b,c}));
        end
    end
    
    TFB1Allrt = cat(3,TFB1Allrt, TFSubj(a).B1.rtmean);
    TFB1Allrtstd = cat(3,TFB1Allrtstd,TFSubj(a).B1.rtstd);
    
    TFB1Alllat = [TFB1Alllat, temp.Latency];
    
    %we will also pull out the non-cannonical but still valid reach inds:
    clear alm1*
    ValidReachInds = reshape(temp.data.ValidReachInds,2,[])';
    ValidReachInds = ValidReachInds(:,1);
    CannonicalReachInds = reshape(temp.CannonicalReachInds,2,[])';
    CannonicalReachInds = CannonicalReachInds(:,1);
    for b = 1:8  %tgt
        for c = 1:8  %tpath
            TFSubj(a).B1.excludedlats{b,c} = [];
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
            TFSubj(a).B1.excludedlats{c,d}(end+1,1) = tmplat;
        end
    end
    for b = 1:8
        for c = 1:8
            TFSubj(a).B1.alllats(b,c) = nanmean([TFSubj(a).B1.rts{b,c}; TFSubj(a).B1.excludedlats{b,c}]);
            TFSubj(a).B1.alllatsstd(b,c) = nanstd([TFSubj(a).B1.rts{b,c}; TFSubj(a).B1.excludedlats{b,c}]);
        end
    end
    
    
end


sametrajlats = [];
for a = 1:size(pairs,1)
    means = [nanmean(TFB1Allrt(pairs(a,1),pairs(a,2),:)) nanmean(TFB1Allrt(pairs(a,3),pairs(a,4),:))];
    stds = [nanstd(TFB1Allrt(pairs(a,1),pairs(a,2),:)) nanstd(TFB1Allrt(pairs(a,3),pairs(a,4),:))]/sqrt(12);
    sametrajlats = [sametrajlats; means];
end
[~,p_sametrajlats_tf1] = ttest(sametrajlats(:,1),sametrajlats(:,2));


%% Block 2 analysis

TFB2Allrt = [];
TFB2Allrtstd = [];
TFB2Alllat = [];
for a = 1:8
    for b = 1:8
        TFB2Reach(a,b).handxy = {};
        TFB2trajrsmpl{a,b}.x = [];
        TFB2trajrsmpl{a,b}.y = [];
        TFB2trajrsmpl{a,b}.id = [];
        
    end
end

for a = 1:length(TFB2files)
    temp = load(TFB2files{a});
    
    for b = 1:8
        for c = 1:8
            TFSubj(a).B2.rts{b,c} = [];
            TFSubj(a).B2.acc{b,c} = [];
            TFSubj(a).B2.excludedlats{b,c} = [];
        end
    end
    
    scorei = findTarget(temp.data.Time,temp.data.TrialScore+1,temp.data.TrialScore+1);
    TFSubj(a).B2.Score = sum(temp.data.TrialScore(scorei+1));
    
    for b = 1:length(temp.reach)
        if (temp.reach(b).latency > 1000)
            temp.reach(b).latency = NaN;
            TFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [TFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];
        end
        TFSubj(a).B2.rts{temp.reach(b).rottgt,temp.reach(b).rottpath} = [TFSubj(a).B2.rts{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).latency];
        
        if ~isnan(temp.reach(b).latency)
            TFB2Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end+1} = [temp.reach(b).handx-temp.reach(b).starttgt(1) temp.reach(b).handy-temp.reach(b).starttgt(2)];
            
            RotMat = [cos(-temp.reach(b).spath*pi/4) -sin(-temp.reach(b).spath*pi/4);
                sin(-temp.reach(b).spath*pi/4)  cos(-temp.reach(b).spath*pi/4)];
            
            %this is the actual rotated/centered hand path
            TFB2Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end} = (RotMat*TFB2Reach(temp.reach(b).rottgt,temp.reach(b).rottpath).handxy{end}')';
            
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
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 4 && any(x < -0.05)
                x = -x;
                y = -y;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 5 && any(x < -0.05)
                x = -x;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 6 && any(x < -0.05)
                x = -x;
                y = -y;
            elseif temp.reach(b).rottgt == 1 && temp.reach(b).rottpath == 6 && any(x > 0.07 & x < 0.1 & y < 0)
                y = -y;
            elseif temp.reach(b).rottgt == 3 && temp.reach(b).rottpath == 4 && any(x < -0.005 & y < 0.04)
                x = -x;
            elseif temp.reach(b).rottgt == 3 && temp.reach(b).rottpath == 5 && any(x < -0.02 & y < 0.03)
                x = -x;
            elseif temp.reach(b).rottgt == 3 && temp.reach(b).rottpath == 6 && any(x < -0.02 & y < 0.03)
                x = -x;
            elseif temp.reach(b).rottgt == 7 && temp.reach(b).rottpath == 1 && any(y < -0.05)
                y = -y;
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
            
            
            TFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x = [TFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.x; x]; %every row is a trajectory
            TFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y = [TFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.y; y];
            TFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id = [TFB2trajrsmpl{temp.reach(b).rottgt,temp.reach(b).rottpath}.id; [a+12 temp.reach(b).spath temp.reach(b).tpath temp.reach(b).tgtcode]];
            
            TFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [TFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; temp.reach(b).acc.apeak];
        else
            TFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath} = [TFSubj(a).B2.acc{temp.reach(b).rottgt,temp.reach(b).rottpath}; NaN];            
        end
        
    end
    
    for b = 1:8
        for c = 1:8
            TFSubj(a).B2.rtmean(b,c) = nanmean(TFSubj(a).B2.rts{b,c});
            TFSubj(a).B2.rtstd(b,c) = nanstd(TFSubj(a).B2.rts{b,c});
            
            TFexcluded(a,2) = TFexcluded(a,2) + sum(isnan(TFSubj(a).B2.rts{b,c}));
        end
    end
    
    TFB2Allrt = cat(3,TFB2Allrt, TFSubj(a).B2.rtmean);
    TFB2Allrtstd = cat(3,TFB2Allrtstd,TFSubj(a).B2.rtstd);
    
    TFB2Alllat = [TFB2Alllat, temp.Latency];
    
    
    %we will also pull out the non-cannonical but still valid reach inds:
    clear alm1*
    ValidReachInds = reshape(temp.data.ValidReachInds,2,[])';
    ValidReachInds = ValidReachInds(:,1);
    CannonicalReachInds = reshape(temp.CannonicalReachInds,2,[])';
    CannonicalReachInds = CannonicalReachInds(:,1);
    for b = 1:8  %tgt
        for c = 1:8  %tpath
            TFSubj(a).B2.excludedlats{b,c} = [];
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
            TFSubj(a).B2.excludedlats{c,d}(end+1) = tmplat;
        end
    end
    for b = 1:8
        for c = 1:8
            TFSubj(a).B2.alllats(b,c) = nanmean([TFSubj(a).B2.rts{b,c}; reshape(TFSubj(a).B2.excludedlats{b,c},[],1)]);
            TFSubj(a).B2.alllatsstd(b,c) = nanstd([TFSubj(a).B2.rts{b,c}; reshape(TFSubj(a).B2.excludedlats{b,c},[],1)]);
        end
    end
    
end


sametrajlats = [];
for a = 1:size(pairs,1)
    means = [nanmean(TFB2Allrt(pairs(a,1),pairs(a,2),:)) nanmean(TFB2Allrt(pairs(a,3),pairs(a,4),:))];
    stds = [nanstd(TFB2Allrt(pairs(a,1),pairs(a,2),:)) nanstd(TFB2Allrt(pairs(a,3),pairs(a,4),:))]/sqrt(12);
    sametrajlats = [sametrajlats; means];
end
[~,p_sametrajlats_tf2] = ttest(sametrajlats(:,1),sametrajlats(:,2));


%% TF across-block analysis

for a = 1:8
    for b = 1:8
        if isempty(TFB1trajrsmpl{a,b}.x) && isempty(TFB2trajrsmpl{a,b}.x)
            TFHotellingT2(a,b,:) = NaN;
            continue;
        end
        
        ic = 0;
        for c = 1:5:201
            ic = ic+1;
            X1 = [];
            X2 = [];
            for d = 1:max(TFB1trajrsmpl{a,b}.id(:,1))
                inds1 = TFB1trajrsmpl{a,b}.id(:,1)==d;
                inds2 = TFB2trajrsmpl{a,b}.id(:,1)==d;
                
                if ~any(inds1) || ~any(inds2)  %if subject is completely missing movements from either condition, skip that subject
                    continue;
                end
                
                X1 = [X1; nanmean(TFB1trajrsmpl{a,b}.x(inds1,c)) nanmean(TFB1trajrsmpl{a,b}.y(inds1,c))];
                X2 = [X2; nanmean(TFB2trajrsmpl{a,b}.x(inds2,c)) nanmean(TFB2trajrsmpl{a,b}.y(inds2,c))];
                
            end

            TFHotellingT2(a,b,ic) = HotellingT2([X1; X2],0.05,2,2,'nooutput');
        end
        
        
    end
end

sametrajlats = [];
for a = 1:size(pairs,1)
    x1 = [squeeze(TFB1Allrt(pairs(a,1),pairs(a,2),:)), squeeze(TFB1Allrt(pairs(a,3),pairs(a,4),:))];
    x2 = [squeeze(TFB2Allrt(pairs(a,1),pairs(a,2),:)), squeeze(TFB2Allrt(pairs(a,3),pairs(a,4),:))];
    means = [nanmean(nanmean(x1)) nanmean(nanmean(x2))];
    stds = [nanstd(nanmean(x1,2)) nanstd(nanmean(x2,2))]/sqrt(12);
    sametrajlats = [sametrajlats; means];
end
[~,p_sametrajlats_tfblkcmp] = ttest(sametrajlats(:,1),sametrajlats(:,2));





%% data plots


%% NTF - data plots

plotstr{1,1} = 'b-';
plotstr{1,2} = 'm-';
plotstr{2,1} = 'r-';
plotstr{2,2} = 'c-';

%figure: RT as a function of trial
figure(2)
clf;
%we will plot every row of B1AllRT
cmap = hsv(size(NTFB1Alllat,1));
errorfield([1:size(NTFB1Alllat,1)],nanmean(NTFB1Alllat(:,:)-rtdelay,2),nanstd(NTFB1Alllat(:,:)-rtdelay,[],2)/sqrt(12),[plotstr{1,1} 'o']);
hold on;
errorfield([size(NTFB1Alllat,1)+1:size(NTFB1Alllat,1)+size(NTFB2Alllat,1)],nanmean(NTFB2Alllat(:,:)-rtdelay,2),nanstd(NTFB2Alllat(:,:)-rtdelay,[],2)/sqrt(12),[plotstr{1,2} 'o']);
ylims = [260 480];
plot([size(NTFB1Alllat,1)+0.5 size(NTFB1Alllat,1)+0.5],ylims,'k:');

%we will plot every row of B1AllRT
cmap = hsv(size(TFB1Alllat,1));
errorfield([1:size(TFB1Alllat,1)]+128,nanmean(TFB1Alllat(:,:)-rtdelay,2),nanstd(TFB1Alllat(:,:)-rtdelay,[],2)/sqrt(12),[plotstr{2,1} 's']);
errorfield([size(TFB1Alllat,1)+1:size(TFB1Alllat,1)+size(TFB2Alllat,1)]+128,nanmean(TFB2Alllat(:,:)-rtdelay,2),nanstd(TFB2Alllat(:,:)-rtdelay,[],2)/sqrt(12),[plotstr{2,2} 's']);
ylims = [260 480];
plot([size(TFB1Alllat,1)+0.5 size(TFB1Alllat,1)+0.5]+128,ylims,'k:');
hold off;
xlabel('Trial');
ylabel('Latency (ms)');
set(gca,'ylim',[260 480],'box','off');


%fit an exponential curve to the cue block to see what the rate of
%  decrease of the RT is (e.g., measure the time constant)

x = [2:size(NTFB2Alllat,1)]';
y = nanmean(NTFB2Alllat(2:end,:)-rtdelay,2);
f = fit(x,y,'power1')

x = [2:size(TFB1Alllat,1)]';
y = nanmean(TFB1Alllat(2:end,:)-rtdelay,2);
f = fit(x,y,'power1')


%% summary data plot

y = [nanmean(squeeze(nanmean(nanmean(NTFB1Allrt,2),1))) nanmean(squeeze(nanmean(nanmean(NTFB2Allrt,2),1)));
    nanmean(squeeze(nanmean(nanmean(TFB2Allrt,2),1)))  nanmean(squeeze(nanmean(nanmean(TFB1Allrt,2),1)));
    ]-rtdelay;
ystd = [nanstd(squeeze(nanmean(nanmean(NTFB1Allrt,2),1)))/sqrt(size(NTFB1Allrt,3)) nanstd(squeeze(nanmean(nanmean(NTFB2Allrt,2),1)))/sqrt(size(NTFB2Allrt,3));
    nanstd(squeeze(nanmean(nanmean(TFB2Allrt,2),1)))/sqrt(size(TFB2Allrt,3))   nanstd(squeeze(nanmean(nanmean(TFB1Allrt,2),1)))/sqrt(size(TFB1Allrt,3));
    ];

figure(25)
h = bar(y);
hold on
errorbar([.86 1.14 1.86 2.14], [y(1,:) y(2,:)], [ystd(1,:) ystd(2,:)],'k.')
hold off;
xlabel('Group');
ylabel('Reaction time (ms)');
set(gca,'box','off','xtick',[1 2],'xticklabel',{'No Cue First','Cue First'});
legend('Uncued','Cued');

%% compute Procrustes Distance 

%note, this takes a long time to run so if it has been done once it may be
%  best to leave this section unavailable. otherwise, set the if statement
%  to (true) to run this code.

if (false)

for a = 1:8
    for b = 1:8
        NTFb1X{a,b} = NTFB1trajrsmpl{a,b}.x;
        NTFb1Y{a,b} = NTFB1trajrsmpl{a,b}.y;
        NTFb1ID{a,b} = NTFB1trajrsmpl{a,b}.id;
        
        NTFb2X{a,b} = NTFB2trajrsmpl{a,b}.x;
        NTFb2Y{a,b} = NTFB2trajrsmpl{a,b}.y;
        NTFb2ID{a,b} = NTFB2trajrsmpl{a,b}.id;
        
        TFb1X{a,b} = TFB1trajrsmpl{a,b}.x;
        TFb1Y{a,b} = TFB1trajrsmpl{a,b}.y;
        TFb1ID{a,b} = TFB1trajrsmpl{a,b}.id;

        TFb2X{a,b} = TFB2trajrsmpl{a,b}.x;
        TFb2Y{a,b} = TFB2trajrsmpl{a,b}.y;
        TFb2ID{a,b} = TFB2trajrsmpl{a,b}.id;
    end
end

save([pwd() '\resampled_trajectories_ALL.mat'],'NTFb1X','NTFb1Y','NTFb1ID','NTFb2X','NTFb2Y','NTFb2ID','TFb1X','TFb1Y','TFb1ID','TFb2X','TFb2Y','TFb2ID');

rttraj_trajanalysis()

end


%% individual subjects RT vs pdist

y = [squeeze(nanmean(nanmean(NTFB1Allrt,2),1)) squeeze(nanmean(nanmean(NTFB2Allrt,2),1)) squeeze(nanmean(nanmean(TFB1Allrt,2),1))  squeeze(nanmean(nanmean(TFB2Allrt,2),1))]-rtdelay;
figure(26)
subplot(1,2,1)
bar([1 2],[nanmean(y(:,1)-y(:,2)) nanmean(y(:,4)-y(:,3))]);
hold on
plot(ones(12,1),y(:,1)-y(:,2),'k.',2*ones(12,1),y(:,4)-y(:,3),'k.')
hold off;
set(gca,'xtick',[1 2],'xticklabel',{'NTF','TF'},'box','off');
ylabel('Change in RT')
xlabel('Group');

pdist = load([pwd() '\resampled_trajectories_PDist.mat']);

pdntf = [];
pdtf = [];

for a = 1:12
    for b = 1:8
        for c = 1:8
            if isempty(pdist.NTFB1trajrsmpl{b,c}.x)
                continue;
            end
            
            pd(a).ntf(b,c) = nanmean(pdist.NTFB1trajrsmpl{b,c}.Pdist{a}) - nanmean(pdist.NTFB2trajrsmpl{b,c}.Pdist{a});
            pd(a).tf(b,c) = nanmean(pdist.TFB2trajrsmpl{b,c}.Pdist{a}) - nanmean(pdist.TFB1trajrsmpl{b,c}.Pdist{a});
        end
    end
    
    pdallntf(a) = nanmean(reshape(pd(a).ntf,[],1));
    pdalltf(a) = nanmean(reshape(pd(a).tf,[],1));
end

subplot(1,2,2)
bar([1 2],[nanmean(pdallntf) nanmean(pdalltf)]);
hold on
plot(ones(12,1),pdallntf,'k.',2*ones(12,1),pdalltf,'k.')
hold off;
set(gca,'xtick',[1 2],'xticklabel',{'NTF','TF'},'box','off');
ylabel('Change in Pdist')
xlabel('Group');
pos = get(gcf,'position');
set(gcf,'position',[pos(1) pos(2) pos(3)*1.5 pos(4)]);



%% score analysis

clear ntfscore tfscore

for a = 1:length(NTFSubj)
    ntfscore.b1(a) = NTFSubj(a).B1.Score;
    ntfscore.b2(a) = NTFSubj(a).B2.Score;
end
for a = 1:length(TFSubj)
    tfscore.b1(a) = TFSubj(a).B1.Score;
    tfscore.b2(a) = TFSubj(a).B2.Score;
end


fpath = [pwd() '\r data analysis\'];

fid = fopen([fpath 'scoredata.txt'],'wt');
i = 0;
fprintf(fid,'"%s" "%s" "%s" "%s"\n','Score','Group','Condition','Subject');
for a = 1:length(ntfscore.b1)
    i = i+1;
    fprintf(fid,'%d %d "%s" "%s" "%d"\n',i,ntfscore.b1(a),'NTF','NT',a);
    i = i+1;
    fprintf(fid,'%d %d "%s" "%s" "%d"\n',i,ntfscore.b2(a),'NTF','T',a);
end
for a = 1:length(tfscore.b1)
    i = i+1;
    fprintf(fid,'%d %d "%s" "%s" "%d"\n',i,tfscore.b1(a),'TF','T',a+12);
    i = i+1;
    fprintf(fid,'%d %d "%s" "%s" "%d"\n',i,tfscore.b2(a),'TF','NT',a+12);
end

fclose(fid);




%% output to R

if (true) %set to false to not output text file for R analysis

idata = 1;
Data{1,1} = 'Subject';
Data{1,2} = 'Group';  %TF / NTF
Data{1,3} = 'Condition';  %cue / No-cue
Data{1,4} = 'TB';
Data{1,5} = 'TrialNum';
Data{1,6} = 'Trial';
Data{1,7} = 'Lat';

for a = 1:length(NTFntfiles)
    temp = load(NTFntfiles{a});
    
    itgtbarN = zeros(8,8);
    
    for b = 1:length(temp.reach)
        
        idata = idata+1;
        
        Data{idata,1} = sprintf('%d',a); %Subject ID
        Data{idata,2} = 1; %Group - NTF
        Data{idata,3} = 1; %Condition - NT
        Data{idata,4} = (temp.reach(b).rottgt-1)*8+(temp.reach(b).rottpath-1);
        
        itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath) = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath)+1;
        Data{idata,5} = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath);
        Data{idata,6} = b;
        Data{idata,7} = temp.reach(b).latency-rtdelay;
        
    end  %end for all reaches
    
    
    temp = load(NTFtfiles{a});
    
    itgtbarN = zeros(8,8);
    
    for b = 1:length(temp.reach)
        
        idata = idata+1;
        
        Data{idata,1} = sprintf('%d',a); %Subject ID
        Data{idata,2} = 1; %Group - NTF
        Data{idata,3} = 0; %Condition - T
        Data{idata,4} = (temp.reach(b).rottgt-1)*8+(temp.reach(b).rottpath-1);
        
        itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath) = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath)+1;
        Data{idata,5} = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath);
        Data{idata,6} = b;
        Data{idata,7} = temp.reach(b).latency-rtdelay;
        
    end  %end for all reaches
    
end  %end for all non-control subjects


for a = 1:length(TFtfiles)
    temp = load(TFtfiles{a});
    
    itgtbarN = zeros(8,8);
    
    for b = 1:length(temp.reach)
        
        idata = idata+1;
        
        Data{idata,1} = sprintf('%d',a+length(NTFntfiles)); %Subject ID
        Data{idata,2} = 0; %Group - NTF
        Data{idata,3} = 0; %Condition - T
        Data{idata,4} = (temp.reach(b).rottgt-1)*8+(temp.reach(b).rottpath-1);
        
        itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath) = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath)+1;
        Data{idata,5} = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath);
        Data{idata,6} = b;
        Data{idata,7} = temp.reach(b).latency-rtdelay;
        
    end  %end for all reaches
    
    
    temp = load(TFntfiles{a});
    
    itgtbarN = zeros(8,8);
    
    for b = 1:length(temp.reach)
        
        idata = idata+1;
        
        Data{idata,1} = sprintf('%d',a+length(NTFntfiles)); %Subject ID
        Data{idata,2} = 0; %Group - NTF
        Data{idata,3} = 1; %Condition - NT
        Data{idata,4} = (temp.reach(b).rottgt-1)*8+(temp.reach(b).rottpath-1);
        
        itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath) = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath)+1;
        Data{idata,5} = itgtbarN(temp.reach(b).rottgt,temp.reach(b).rottpath);
        Data{idata,6} = b;
        Data{idata,7} = temp.reach(b).latency-rtdelay;
        
    end  %end for all reaches
    
end  %end for all control subjects


fpath = [pwd() '\r data analysis\'];

fid = fopen([fpath 'rtdata.txt'],'wt');
a = 1;
fprintf(fid,'"%s" "%s" "%s" "%s" "%s" "%s" "%s"\n',Data{a,1},Data{a,2},Data{a,3},Data{a,4},Data{a,5}, Data{a,6}, Data{a,7});
for a = 2:size(Data,1)
    if isnan(Data{a,7})
        tmp = 'NA';
    else
        tmp = sprintf('%.3f',Data{a,7});
    end
    
    fprintf(fid,'"%d" "%s" "%d" "%d" "%d" "%d" "%d" %s\n',(a-1),Data{a,1},Data{a,2},Data{a,3},Data{a,4}, Data{a,5}, Data{a,6}, tmp);
end

fclose(fid);

end



warning('on');
