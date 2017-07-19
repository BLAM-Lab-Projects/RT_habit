function rttraj_trajanalysis()

%Analyze the trajectory data by computing a Procrustes distance, comparing
% each trajectory to the template (which is derived directly from the mean
% trajectory produced in the original barrier experiment in the no-trace
% condition). 
%These data are then fed into the rttraj_groupanalysis and r analysis
% code.
%
%Code by: Aaron L. Wong

templates = load('C:\Users\Aaron\Documents\MATLAB\data\rtbox\pilot2\resampled_trajectories_ALL.mat');

RotMat = [cosd(-135) -sind(-135)
          sind(-135)  cosd(-135)];

for a = 1:8
    for b = 1:8
        
        x = nanmean(templates.ReachX{a,b});
        y = nanmean(templates.ReachY{a,b});
        
        x = x - x(1);
        y = y - y(1);
        
        xy = RotMat*[x; y];
        
        templates.tpReachX{a,b} = xy(1,:);
        templates.tpReachY{a,b} = xy(2,:);
    end
end

load(['\resampled_trajectories_ALL.mat']);

for a = 1:16
    figure(a)
    clf;
end


for a = 1:8
    for b = 1:8
        
        figure(a)
        subplot(2,4,b)
        h = plot(templates.tpReachX{a,b},templates.tpReachY{a,b},'k-');
        set(h,'LineWidth',5,'Color',[0.5 0.5 0.5]);
        hold on;

        figure(a+8)
        subplot(2,4,b)
        h = plot(templates.tpReachX{a,b},templates.tpReachY{a,b},'k-');
        set(h,'LineWidth',5,'Color',[0.5 0.5 0.5]);
        hold on;

        
        %NTF - B1
        for c = 1:12
            
            %first compute the mean for each subject
            if isempty(NTFB1trajrsmpl{a,b}.id)
                NTFB1trajrsmpl{a,b}.Pdist{c} = NaN;
                NTFB1trajrsmpl{a,b}.Z = {};
                NTFB1trajrsmpl{a,b}.transform = {};
                continue;
            end
            
            inds = find(NTFB1trajrsmpl{a,b}.id(:,1) == c);
            if isempty(inds)
                NTFB1trajrsmpl{a,b}.subjmean.x(c,:) = NaN*ones(1,201);
                
                NTFB1trajrsmpl{a,b}.Pdist{c} = NaN;
                NTFB1trajrsmpl{a,b}.Z{c} = [];
                NTFB1trajrsmpl{a,b}.transform{c} = [];
            else

                X = [templates.tpReachX{a,b}' templates.tpReachY{a,b}'];

                for d = 1:length(inds)
                    
                    if a > 4 && b <= 5
                        Y = [NTFB1trajrsmpl{a,b}.x(inds(d),:)' -NTFB1trajrsmpl{a,b}.y(inds(d),:)'];
                    elseif (a == 1 || a > 4) && b > 5
                        Y = [NTFB1trajrsmpl{a,b}.x(inds(d),:)' -NTFB1trajrsmpl{a,b}.y(inds(d),:)'];
                    else
                        Y = [NTFB1trajrsmpl{a,b}.x(inds(d),:)' NTFB1trajrsmpl{a,b}.y(inds(d),:)'];
                    end
                    
                    figure(a)
                    subplot(2,4,b)
                    plot(Y(:,1),Y(:,2),'b-');
                    
                    [NTFB1trajrsmpl{a,b}.Pdist{c}(d), NTFB1trajrsmpl{a,b}.Z{c}{d}, NTFB1trajrsmpl{a,b}.transform{c}{d}] = procrustes(X,Y,'Reflection',false);
                end
                
                


            end
        end
        
        
        %NTF - B2
        for c = 1:12
            
            if isempty(NTFB2trajrsmpl{a,b}.id)
                NTFB2trajrsmpl{a,b}.Pdist{c} = NaN;
                NTFB2trajrsmpl{a,b}.Z = {};
                NTFB2trajrsmpl{a,b}.transform = {};
                continue;
            end

            
            %first compute the mean for each subject
            inds = find(NTFB2trajrsmpl{a,b}.id(:,1) == c);
            if isempty(inds)
                NTFB2trajrsmpl{a,b}.subjmean.x(c,:) = NaN*ones(1,201);
                
                NTFB2trajrsmpl{a,b}.Pdist{c} = NaN;
                NTFB2trajrsmpl{a,b}.Z{c} = [];
                NTFB2trajrsmpl{a,b}.transform{c} = [];
            else
                X = [templates.tpReachX{a,b}' templates.tpReachY{a,b}'];

                for d = 1:length(inds)
                    
                    if a > 4 && b <= 5
                        Y = [NTFB2trajrsmpl{a,b}.x(inds(d),:)' -NTFB2trajrsmpl{a,b}.y(inds(d),:)'];
                    elseif (a == 1 || a > 4) && b > 5
                        Y = [NTFB2trajrsmpl{a,b}.x(inds(d),:)' -NTFB2trajrsmpl{a,b}.y(inds(d),:)'];
                    else
                        Y = [NTFB2trajrsmpl{a,b}.x(inds(d),:)' NTFB2trajrsmpl{a,b}.y(inds(d),:)'];
                    end

                    figure(a)
                    subplot(2,4,b)
                    plot(Y(:,1),Y(:,2),'r-');
                    
                    [NTFB2trajrsmpl{a,b}.Pdist{c}(d), NTFB2trajrsmpl{a,b}.Z{c}{d}, NTFB2trajrsmpl{a,b}.transform{c}{d}] = procrustes(X,Y,'Reflection',false);
                end

            end
        end
        
        
        %TF - B1
        for c = 1:12
            
            if isempty(TFB1trajrsmpl{a,b}.id)
                TFB1trajrsmpl{a,b}.Pdist{c} = NaN;
                TFB1trajrsmpl{a,b}.Z = {};
                TFB1trajrsmpl{a,b}.transform = {};
                continue;
            end
            
            %first compute the mean for each subject
            inds = find(TFB1trajrsmpl{a,b}.id(:,1)-12 == c);
            if isempty(inds)
                TFB1trajrsmpl{a,b}.subjmean.x(c,:) = NaN*ones(1,201);
                
                TFB1trajrsmpl{a,b}.Pdist{c} = NaN;
                TFB1trajrsmpl{a,b}.Z{c} = [];
                TFB1trajrsmpl{a,b}.transform{c} = [];
            else
                X = [templates.tpReachX{a,b}' templates.tpReachY{a,b}'];

                for d = 1:length(inds)
                    
                    if a > 4 && b <= 5
                        Y = [TFB1trajrsmpl{a,b}.x(inds(d),:)' -TFB1trajrsmpl{a,b}.y(inds(d),:)'];
                    elseif (a == 1 || a > 4) && b > 5
                        Y = [TFB1trajrsmpl{a,b}.x(inds(d),:)' -TFB1trajrsmpl{a,b}.y(inds(d),:)'];
                    else
                        Y = [TFB1trajrsmpl{a,b}.x(inds(d),:)' TFB1trajrsmpl{a,b}.y(inds(d),:)'];
                    end
                    
                    figure(a+8)
                    subplot(2,4,b)
                    plot(Y(:,1),Y(:,2),'b-');
                    
                    [TFB1trajrsmpl{a,b}.Pdist{c}(d), TFB1trajrsmpl{a,b}.Z{c}{d}, TFB1trajrsmpl{a,b}.transform{c}{d}] = procrustes(X,Y,'Reflection',false);
                end
                
            end
        end
        
        
        %TF - B2
        for c = 1:12
            
            if isempty(TFB2trajrsmpl{a,b}.id)
                TFB2trajrsmpl{a,b}.Pdist{c} = NaN;
                TFB2trajrsmpl{a,b}.Z = {};
                TFB2trajrsmpl{a,b}.transform = {};
                continue;
            end
            
            %first compute the mean for each subject
            inds = find(TFB2trajrsmpl{a,b}.id(:,1)-12 == c);
            if isempty(inds)
                TFB2trajrsmpl{a,b}.subjmean.x(c,:) = NaN*ones(1,201);
                
                TFB2trajrsmpl{a,b}.Pdist{c} = NaN;
                TFB2trajrsmpl{a,b}.Z{c} = [];
                TFB2trajrsmpl{a,b}.transform{c} = [];
            else

                X = [templates.tpReachX{a,b}' templates.tpReachY{a,b}'];

                for d = 1:length(inds)
                    
                    if a > 4 && b <= 5
                        Y = [TFB2trajrsmpl{a,b}.x(inds(d),:)' -TFB2trajrsmpl{a,b}.y(inds(d),:)'];
                    elseif (a == 1 || a > 4) && b > 5
                        Y = [TFB2trajrsmpl{a,b}.x(inds(d),:)' -TFB2trajrsmpl{a,b}.y(inds(d),:)'];
                    else
                        Y = [TFB2trajrsmpl{a,b}.x(inds(d),:)' TFB2trajrsmpl{a,b}.y(inds(d),:)'];
                    end
                    
                    figure(a+8)
                    subplot(2,4,b)
                    plot(Y(:,1),Y(:,2),'r-');
                    
                    [TFB2trajrsmpl{a,b}.Pdist{c}(d), TFB2trajrsmpl{a,b}.Z{c}{d}, TFB2trajrsmpl{a,b}.transform{c}{d}] = procrustes(X,Y,'Reflection',false);
                end
            end
        end
        
        
    end
end



%% 

for c = 1:12
    
    pdntfb1 = [];
    pdntfb2 = [];
    pdtfb1 = [];
    pdtfb2 = [];
    
    
    for a = 1:8
        for b = 1:8
            
            pdntfb1 = [pdntfb1; nanmean(NTFB1trajrsmpl{a,b}.Pdist{c})];
            pdntfb2 = [pdntfb2; nanmean(NTFB2trajrsmpl{a,b}.Pdist{c})];
            pdtfb1 = [pdtfb1; nanmean(TFB1trajrsmpl{a,b}.Pdist{c})];
            pdtfb2 = [pdtfb2; nanmean(TFB2trajrsmpl{a,b}.Pdist{c})];
            
        end
    end
    
    NTFB1.Pdist(c,:) = pdntfb1';
    NTFB2.Pdist(c,:) = pdntfb2';
    TFB1.Pdist(c,:) = pdtfb1';
    TFB2.Pdist(c,:) = pdtfb2';

end
            


figure(21)

subplot(2,1,1)
x = [0.001:0.001:.499];
y1 = [];
y2 = [];
for a = 1:size(NTFB1.Pdist,1)
    if a == 1
        y1 = ksdensity(NTFB1.Pdist(a,:),x,'bandwidth',0.008);
        y2 = ksdensity(NTFB2.Pdist(a,:),x,'bandwidth',0.008);
    else
        y1(a,:) = ksdensity(NTFB1.Pdist(a,:),x,'bandwidth',0.008);
        y2(a,:) = ksdensity(NTFB2.Pdist(a,:),x,'bandwidth',0.008);
    end
end
Y1 = nanmean(y1);
Y2 = nanmean(y2);
Y1std = nanstd(y1)/sqrt(size(NTFB1.Pdist,1));
Y2std = nanstd(y2)/sqrt(size(NTFB2.Pdist,1));
[~,x1] = max(Y1);
x1 = x(x1);
[~,x2] = max(Y2);
x2 = x(x2);
errorfield(x,Y1,Y1std,'b-');
hold on;
errorfield(x,Y2,Y2std,'c-');
ylims = get(gca,'ylim');
plot([x1 x1],ylims,'b--',[x2 x2],ylims,'c--');
hold off;
xlabel('Procrustes distance');
ylabel('No Trace First')
legend('No Trace','Trace');
set(gca,'xlim',[0 0.2])

subplot(2,1,2)
for a = 1:size(TFB1.Pdist,1)
    if a == 1
        y1 = ksdensity(TFB2.Pdist(a,:),x,'bandwidth',0.008);
        y2 = ksdensity(TFB1.Pdist(a,:),x,'bandwidth',0.008);
    else
        y1(a,:) = ksdensity(TFB2.Pdist(a,:),x,'bandwidth',0.008);
        y2(a,:) = ksdensity(TFB1.Pdist(a,:),x,'bandwidth',0.008);
    end
end
Y1 = nanmean(y1);
Y2 = nanmean(y2);
Y1std = nanstd(y1)/sqrt(size(TFB2.Pdist,1));
Y2std = nanstd(y2)/sqrt(size(TFB1.Pdist,1));
[~,x1] = max(Y1);
x1 = x(x1);
[~,x2] = max(Y2);
x2 = x(x2);
errorfield(x,Y1,Y1std,'b-');
hold on;
errorfield(x,Y2,Y2std,'c-');
ylims = get(gca,'ylim');
hold on;
plot([x1 x1],ylims,'b--',[x2 x2],ylims,'c--');
hold off;
xlabel('Procrustes distance');
ylabel('Trace First')
legend('No Trace','Trace');
set(gca,'xlim',[0 0.2])

[pNTF,~,statsNTF] = signrank(nanmean(NTFB1.Pdist,2),nanmean(NTFB2.Pdist,2),'tail','right');
[pTF,~,statsTF] = signrank(nanmean(TFB2.Pdist,2),nanmean(TFB1.Pdist,2),'tail','right');


%%

if (true)

clear Data;
    
idata = 1;
Data{1,1} = 'PDist';
Data{1,2} = 'Group'; %NTF / TF
Data{1,3} = 'Cond';  %Trace / NoTrace
Data{1,4} = 'TB';    %Trajectory
Data{1,5} = 'Subj';

for c = 1:12
    
    for b = 1:64
        
        if all(isnan(NTFB1trajrsmpl{b}.Pdist{c}))
            continue;
        end
        
        for d = 1:length(NTFB1trajrsmpl{b}.Pdist{c})
            
            idata = idata+1;
            
            Data{idata,1} = NTFB1trajrsmpl{b}.Pdist{c}(d);
            Data{idata,2} = 1; %Group - NTF
            Data{idata,3} = 1; %Condition - NT
            Data{idata,4} = b;
            Data{idata,5} = sprintf('S%d',c); %Subject ID
        end
        
    end  %end for all reaches
    

    for b = 1:64
        
        if all(isnan(NTFB2trajrsmpl{b}.Pdist{c}))
            continue;
        end
        
        for d = 1:length(NTFB2trajrsmpl{b}.Pdist{c})
            
            idata = idata+1;
            
            Data{idata,1} = NTFB2trajrsmpl{b}.Pdist{c}(d);
            Data{idata,2} = 1; %Group - NTF
            Data{idata,3} = 0; %Condition - T
            Data{idata,4} = b;
            Data{idata,5} = sprintf('S%d',c); %Subject ID
        end
        
    end  %end for all reaches
end

for c = 1:12
    
    for b = 1:64
        
        if all(isnan(TFB1trajrsmpl{b}.Pdist{c}))
            continue;
        end
        
        for d = 1:length(TFB1trajrsmpl{b}.Pdist{c})
            
            idata = idata+1;
            
            Data{idata,1} = TFB1trajrsmpl{b}.Pdist{c}(d);
            Data{idata,2} = 0; %Group - TF
            Data{idata,3} = 0; %Condition - T
            Data{idata,4} = b;
            Data{idata,5} = sprintf('S%d',c); %Subject ID
        end
        
    end  %end for all reaches
    
    
    for b = 1:64
        
        if all(isnan(TFB2trajrsmpl{b}.Pdist{c}))
            continue;
        end
        
        for d = 1:length(TFB2trajrsmpl{b}.Pdist{c})
            
            idata = idata+1;
            
            Data{idata,1} = TFB2trajrsmpl{b}.Pdist{c}(d);
            Data{idata,2} = 0; %Group - TF
            Data{idata,3} = 1; %Condition - NT
            Data{idata,4} = b;
            Data{idata,5} = sprintf('S%d',c); %Subject ID
        end
        
    end  %end for all reaches
    
end  %end for all non-control subjects


fpath = [pwd() '\r data analysis\'];

fid = fopen([fpath 'pdistdata.txt'],'wt');
a = 1;
fprintf(fid,'"%s" "%s" "%s" "%s" "%s"\n',Data{a,1},Data{a,2},Data{a,3},Data{a,4},Data{a,5});
for a = 2:size(Data,1)
    if isnan(Data{a,1})
        tmp = 'NA';
    else
        tmp = sprintf('%.5f',Data{a,1});
    end
    
    fprintf(fid,'%d %s "%d" "%d" "%d" "%s"\n',(a-1),tmp,Data{a,2},Data{a,3},Data{a,4}, Data{a,5});
end

fclose(fid);

end


clear a b c inds h pd* X Y x y xy RotMat;

save([pwd() '\resampled_trajectories_PDist.mat']);