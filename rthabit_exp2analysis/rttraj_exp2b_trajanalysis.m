function rttraj_exp2b_trajanalysis()

%analyze the trajectory context data by comparing each trajectory to the
% template (which is derived directly from the mean trajectory produced in
% the original barrier experiment in the no-trace condition).
%
%Code by: Aaron L. Wong

templates = load([pwd() '\resampled_trajectories_ALL.mat']);

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

load([pwd() '\cnc\rtbox_context_cnc_allSubj.mat']);

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

        
        %CNC - B1
        for c = 1:12
            
            %first compute the mean for each subject
            if isempty(CNCB1trajrsmpl{a,b}.id)
                CNCB1trajrsmpl{a,b}.Pdist{c} = NaN;
                CNCB1trajrsmpl{a,b}.Z = {};
                CNCB1trajrsmpl{a,b}.transform = {};
                continue;
            end
            
            inds = find(CNCB1trajrsmpl{a,b}.id(:,1) == c);
            if isempty(inds)
                CNCB1trajrsmpl{a,b}.subjmean.x(c,:) = NaN*ones(1,201);
                
                CNCB1trajrsmpl{a,b}.Pdist{c} = NaN;
                CNCB1trajrsmpl{a,b}.Z{c} = [];
                CNCB1trajrsmpl{a,b}.transform{c} = [];
            else
                X = [templates.tpReachX{a,b}' templates.tpReachY{a,b}'];

                for d = 1:length(inds)
                    
                    if a > 4 && b <= 5
                        Y = [CNCB1trajrsmpl{a,b}.x(inds(d),:)' -CNCB1trajrsmpl{a,b}.y(inds(d),:)'];
                    elseif (a == 1 || a > 4) && b > 5
                        Y = [CNCB1trajrsmpl{a,b}.x(inds(d),:)' -CNCB1trajrsmpl{a,b}.y(inds(d),:)'];
                    else
                        Y = [CNCB1trajrsmpl{a,b}.x(inds(d),:)' CNCB1trajrsmpl{a,b}.y(inds(d),:)'];
                    end
                    
                    figure(a)
                    subplot(2,4,b)
                    plot(Y(:,1),Y(:,2),'b-');
                    
                    [CNCB1trajrsmpl{a,b}.Pdist{c}(d), CNCB1trajrsmpl{a,b}.Z{c}{d}, CNCB1trajrsmpl{a,b}.transform{c}{d}] = procrustes(X,Y,'Reflection',false);
                end
                
                


            end
        end
        
        
        %CNC - B2
        for c = 1:12
            
            if isempty(CNCB2trajrsmpl{a,b}.id)
                CNCB2trajrsmpl{a,b}.Pdist{c} = NaN;
                CNCB2trajrsmpl{a,b}.Z = {};
                CNCB2trajrsmpl{a,b}.transform = {};
                continue;
            end

            
            %first compute the mean for each subject
            inds = find(CNCB2trajrsmpl{a,b}.id(:,1) == c);
            if isempty(inds)
                CNCB2trajrsmpl{a,b}.subjmean.x(c,:) = NaN*ones(1,201);
                
                CNCB2trajrsmpl{a,b}.Pdist{c} = NaN;
                CNCB2trajrsmpl{a,b}.Z{c} = [];
                CNCB2trajrsmpl{a,b}.transform{c} = [];
            else
                X = [templates.tpReachX{a,b}' templates.tpReachY{a,b}'];

                for d = 1:length(inds)
                    
                    if a > 4 && b <= 5
                        Y = [CNCB2trajrsmpl{a,b}.x(inds(d),:)' -CNCB2trajrsmpl{a,b}.y(inds(d),:)'];
                    elseif (a == 1 || a > 4) && b > 5
                        Y = [CNCB2trajrsmpl{a,b}.x(inds(d),:)' -CNCB2trajrsmpl{a,b}.y(inds(d),:)'];
                    else
                        Y = [CNCB2trajrsmpl{a,b}.x(inds(d),:)' CNCB2trajrsmpl{a,b}.y(inds(d),:)'];
                    end

                    figure(a)
                    subplot(2,4,b)
                    plot(Y(:,1),Y(:,2),'r-');
                    
                    [CNCB2trajrsmpl{a,b}.Pdist{c}(d), CNCB2trajrsmpl{a,b}.Z{c}{d}, CNCB2trajrsmpl{a,b}.transform{c}{d}] = procrustes(X,Y,'Reflection',false);
                end

            end
        end
        
        
        %CNC - B3
        for c = 1:12
            
            if isempty(CNCB3trajrsmpl{a,b}.id)
                CNCB3trajrsmpl{a,b}.Pdist{c} = NaN;
                CNCB3trajrsmpl{a,b}.Z = {};
                CNCB3trajrsmpl{a,b}.transform = {};
                continue;
            end
            
            %first compute the mean for each subject
            inds = find(CNCB3trajrsmpl{a,b}.id(:,1)-12 == c);
            if isempty(inds)
                CNCB3trajrsmpl{a,b}.subjmean.x(c,:) = NaN*ones(1,201);
                
                CNCB3trajrsmpl{a,b}.Pdist{c} = NaN;
                CNCB3trajrsmpl{a,b}.Z{c} = [];
                CNCB3trajrsmpl{a,b}.transform{c} = [];
            else
                X = [templates.tpReachX{a,b}' templates.tpReachY{a,b}'];

                for d = 1:length(inds)
                    
                    if a > 4 && b <= 5
                        Y = [CNCB3trajrsmpl{a,b}.x(inds(d),:)' -CNCB3trajrsmpl{a,b}.y(inds(d),:)'];
                    elseif (a == 1 || a > 4) && b > 5
                        Y = [CNCB3trajrsmpl{a,b}.x(inds(d),:)' -CNCB3trajrsmpl{a,b}.y(inds(d),:)'];
                    else
                        Y = [CNCB3trajrsmpl{a,b}.x(inds(d),:)' CNCB3trajrsmpl{a,b}.y(inds(d),:)'];
                    end
                    
                    figure(a)
                    subplot(2,4,b)
                    plot(Y(:,1),Y(:,2),'c-');
                    
                    [CNCB3trajrsmpl{a,b}.Pdist{c}(d), CNCB3trajrsmpl{a,b}.Z{c}{d}, CNCB3trajrsmpl{a,b}.transform{c}{d}] = procrustes(X,Y,'Reflection',false);
                end
                
            end
        end
        
        
    end
end



%% 

for c = 1:12
    
    pdCNCB1 = [];
    pdCNCB2 = [];
    pdCNCB3 = [];
    
    for a = 1:8
        for b = 1:8
            
            pdCNCB1 = [pdCNCB1; nanmean(CNCB1trajrsmpl{a,b}.Pdist{c})];
            pdCNCB2 = [pdCNCB2; nanmean(CNCB2trajrsmpl{a,b}.Pdist{c})];
            pdCNCB3 = [pdCNCB3; nanmean(CNCB3trajrsmpl{a,b}.Pdist{c})];
            
        end
    end
    
    CNCB1.Pdist(c,:) = pdCNCB1';
    CNCB2.Pdist(c,:) = pdCNCB2';
    CNCB3.Pdist(c,:) = pdCNCB3';
    
end
            


figure(21)
x = [0.001:0.001:.499];
y1 = ksdensity(reshape(CNCB1.Pdist,[],1),x,'bandwidth',0.008);
y2 = ksdensity(reshape(CNCB2.Pdist,[],1),x,'bandwidth',0.008);
y3 = ksdensity(reshape(CNCB3.Pdist,[],1),x,'bandwidth',0.008);
[~,x1] = max(y1);
x1 = x(x1);
[~,x2] = max(y2);
x2 = x(x2);
[~,x3] = max(y3);
x3 = x(x3);
plot(x,y1,'b-',x,y2,'r-',x,y3,'c-');
ylims = get(gca,'ylim');
hold on;
plot([x1 x1],ylims,'b--',[x2 x2],ylims,'r--',[x3 x3],ylims,'c--');
hold off;
xlabel('Procrustes distance');
ylabel('CNC')
legend('Trace1','No Trace','Trace2');
set(gca,'xlim',[0 0.2])


[pCNCB1b3,~,statsCNCB1b3] = signrank(nanmean(CNCB1.Pdist,2),nanmean(CNCB3.Pdist,2),'tail','right');


%%

if (false)

clear Data;
    
idata = 1;
Data{1,1} = 'PDist';
Data{1,2} = 'Block'; %1 (T), 2 (NT), 3 (T)
Data{1,3} = 'Cond';  %Trace / NoTrace
Data{1,4} = 'TB';    %Trajectory
Data{1,5} = 'Subj';

for c = 1:12
    
    for b = 1:64
        
        if all(isnan(CNCB1trajrsmpl{b}.Pdist{c}))
            continue;
        end
        
        for d = 1:length(CNCB1trajrsmpl{b}.Pdist{c})
            
            idata = idata+1;
            
            Data{idata,1} = CNCB1trajrsmpl{b}.Pdist{c}(d);
            Data{idata,2} = 1; %Block - 1 (T)
            Data{idata,3} = 0; %Condition - T
            Data{idata,4} = b;
            Data{idata,5} = sprintf('S%d',c); %Subject ID
        end
        
    end  %end for all reaches
    

    for b = 1:64
        
        if all(isnan(CNCB2trajrsmpl{b}.Pdist{c}))
            continue;
        end
        
        for d = 1:length(CNCB2trajrsmpl{b}.Pdist{c})
            
            idata = idata+1;
            
            Data{idata,1} = CNCB2trajrsmpl{b}.Pdist{c}(d);
            Data{idata,2} = 2; %Block - (NT)
            Data{idata,3} = 1; %Condition - NT
            Data{idata,4} = b;
            Data{idata,5} = sprintf('S%d',c); %Subject ID
        end
        
    end  %end for all reaches

    for b = 1:64
        
        if all(isnan(CNCB3trajrsmpl{b}.Pdist{c}))
            continue;
        end
        
        for d = 1:length(CNCB3trajrsmpl{b}.Pdist{c})
            
            idata = idata+1;
            
            Data{idata,1} = CNCB3trajrsmpl{b}.Pdist{c}(d);
            Data{idata,2} = 3; %Block - T
            Data{idata,3} = 0; %Condition - T
            Data{idata,4} = b;
            Data{idata,5} = sprintf('S%d',c); %Subject ID
        end
        
    end  %end for all reaches
    
    
end  %end for all subjects


fpath = [pwd() '\r data analysis\'];

fid = fopen([fpath 'CNCpdistdata.txt'],'wt');
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

save([pwd() '\cnc\resampled_trajectories_CNC_PDist.mat']);