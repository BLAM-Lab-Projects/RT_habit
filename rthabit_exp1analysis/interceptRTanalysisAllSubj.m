%This code compiles data across subjects for the interception task. It can
%  be used to compile both the inward or the outward interception task
%  separately.

clear all;
close all;

rtdelay = 105;

%full experimental version: control and task
for iter = 1:2

    clear Amp* Chase* delta* End* err* Init* Int* lat* Lat* Mvmt* p* stat* Subj* temp Tgt* v* V* wil*
    
    if iter == 1
        %outward chase experiment (to decrease RT) - uncomment to run
        Chasefiles = {
            [pwd() '\outward\20161212af\chase_allblk.mat'];  %s1
            [pwd() '\outward\20161213cy\chase_allblk.mat'];  %s2
            [pwd() '\outward\20161213jc\chase_allblk.mat'];  %s3
            [pwd() '\outward\20161214jx\chase_allblk.mat'];  %s4
            [pwd() '\outward\20161214ah\chase_allblk.mat'];  %s5
            [pwd() '\outward\20161214rh\chase_allblk.mat'];  %s6
            [pwd() '\outward\20161219di\chase_allblk.mat'];  %s7
            [pwd() '\outward\20161219ej\chase_allblk.mat'];  %s8
            [pwd() '\outward\20161220di\chase_allblk.mat'];  %s9
            [pwd() '\outward\20161220ni\chase_allblk.mat'];  %s10
            };
        chasetype = 'out';
        plotadd = 0;
    
    
    elseif iter == 2
        
        
        %inward intercept experiment (to increase RT) - uncomment to run
        Chasefiles = {
            [pwd() '\inward\20161220lw\chase_allblk.mat'];  %s1
            [pwd() '\inward\20161221le\chase_allblk.mat'];  %s2
            [pwd() '\inward\20161222fn\chase_allblk.mat'];  %s3
            [pwd() '\inward\20161222kb\chase_allblk.mat'];  %s4
            [pwd() '\inward\20170104fl\chase_allblk.mat'];  %s5
            [pwd() '\inward\20170104bi\chase_allblk.mat'];  %s6
            [pwd() '\inward\20170110lk\chase_allblk.mat'];  %s7
            [pwd() '\inward\20170112nx\chase_allblk.mat'];  %s8
            [pwd() '\inward\20170112mn\chase_allblk.mat'];  %s9
            [pwd() '\inward\20170119ms\chase_allblk.mat'];  %s10
            };
        chasetype = 'in';
        plotadd = 50;
        
    end

Latency = [];
VPeak = [];
InterceptErr = [];
MvmtTime = [];
InitDir = [];
Amp = [];
TgtAmp = [];

LatencyPre = [];
VPeakPre = [];
EndPtErrPre = [];
MvmtTimePre = [];
InitDirPre = [];
AmpPre = [];

LatencyPst = [];
VPeakPst = [];
EndPtErrPst = [];
MvmtTimePst = [];
InitDirPst = [];
AmpPst = [];

for a = 1:length(Chasefiles)
    temp = load(Chasefiles{a});
    
    Subj(a).Latency = temp.Latency-rtdelay;
    Subj(a).VPeak = temp.VPeak;
    Subj(a).InterceptErr = temp.InterceptErr;
    Subj(a).MvmtTime = temp.MvmtTime;
    Subj(a).InitDir = temp.InitDir;
    Subj(a).Amp = temp.Amp;
    Subj(a).TgtAmp = temp.TgtAmp;
   
    Subj(a).PP(1).Latency = temp.blocksS{1}.Latency-rtdelay;
    Subj(a).PP(1).VPeak = temp.blocksS{1}.VPeak;
    Subj(a).PP(1).EndPtErr = temp.blocksS{1}.EndPtErr;
    Subj(a).PP(1).InitDir = temp.blocksS{1}.InitDir;
    Subj(a).PP(1).Amp = temp.blocksS{1}.Amp;
    Subj(a).PP(2).Latency = temp.blocksS{2}.Latency-rtdelay;
    Subj(a).PP(2).VPeak = temp.blocksS{2}.VPeak;
    Subj(a).PP(2).EndPtErr = temp.blocksS{2}.EndPtErr;
    Subj(a).PP(2).InitDir = temp.blocksS{2}.InitDir;
    Subj(a).PP(2).Amp = temp.blocksS{2}.Amp;
    
    Latency(:,a) = Subj(a).Latency;
    VPeak(:,a) = Subj(a).VPeak;
    InterceptErr(:,a) = Subj(a).InterceptErr;
    MvmtTime(:,a) = Subj(a).MvmtTime;
    InitDir(:,a) = Subj(a).InitDir;
    Amp(:,a) = Subj(a).Amp;
    TgtAmp(:,a) = Subj(a).TgtAmp;
    
    LatencyPre(:,a) = Subj(a).PP(1).Latency;
    VPeakPre(:,a) = Subj(a).PP(1).VPeak;
    EndPtErrPre(:,a) = Subj(a).PP(1).EndPtErr;
    InitDirPre(:,a) = Subj(a).PP(1).InitDir;
    AmpPre(:,a) = Subj(a).PP(1).Amp;

    LatencyPst(:,a) = Subj(a).PP(2).Latency;
    VPeakPst(:,a) = Subj(a).PP(2).VPeak;
    EndPtErrPst(:,a) = Subj(a).PP(2).EndPtErr;
    InitDirPst(:,a) = Subj(a).PP(2).InitDir;
    AmpPst(:,a) = Subj(a).PP(2).Amp;

end

deltaChaseLat = nanmean(LatencyPre)-nanmean(Latency(end-59:end,:));
deltaLat = nanmean(LatencyPre)-nanmean(LatencyPst);
pctLat = deltaLat./deltaChaseLat*100;
[~,ppctlat,~,pctlatstats] = ttest(pctLat);


%% plot summary figures

clear itick iticklabel;

figure(1+plotadd)
subplot(3,1,1)
errorfield([1:60],nanmean(LatencyPre,2),nanstd(LatencyPre,[],2)/sqrt(length(Subj)),'b-');
hold on
errorfield(60+[1:size(Latency,1)],nanmean(Latency,2),nanstd(Latency,[],2)/sqrt(length(Subj)),'c-');
errorfield(60+size(Latency,1)+[1:60],nanmean(LatencyPst,2),nanstd(LatencyPst,[],2)/sqrt(length(Subj)),'r-');
plot([1 60],nanmean(nanmean(LatencyPre,2))*[1 1],'k-');
plot(60+size(Latency,1)+[1 60],nanmean(nanmean(LatencyPst,2))*[1 1],'k-');
ylims = get(gca,'ylim');
for a = 1:size(Latency,1)/60
    plot(60*a+[0.5 0.5],ylims,'k:');
    itick(a) = 60*(a-1)+30;
    iticklabel{a} = sprintf('Block%d',a);
end
plot(60+size(Latency,1)+[0.5 0.5],ylims,'k:');
itick(end+1) = size(Latency,1)+30;
itick(end+1) = size(Latency,1)+90;
hold off;
xlabel('Trial');
ylabel('Latency (ms)');
set(gca,'xtick',itick,'xticklabel',[{'Pre'},iticklabel,{'Post'}])
set(gca,'ylim',ylims,'ytick',[0:200:1000],'box','off');

subplot(3,1,2)
errorfield([1:60],nanmean(VPeakPre,2),nanstd(VPeakPre,[],2)/sqrt(length(Subj)),'b-');
hold on
errorfield(60+[1:size(Latency,1)],nanmean(VPeak,2),nanstd(VPeak,[],2)/sqrt(length(Subj)),'c-');
errorfield(60+size(Latency,1)+[1:60],nanmean(VPeakPst,2),nanstd(VPeakPst,[],2)/sqrt(length(Subj)),'r-');
plot([1 60],nanmean(nanmean(VPeakPre,2))*[1 1],'k-');
plot(60+size(Latency,1)+[1 60],nanmean(nanmean(VPeakPst,2))*[1 1],'k-');
ylims = get(gca,'ylim');
for a = 1:size(Latency,1)/60
    plot(60*a+[0.5 0.5],ylims,'k:');
end
plot(60+size(Latency,1)+[0.5 0.5],ylims,'k:');
if ~isempty(strfind(Chasefiles{1},'outward'))
    plot(60+[1 60],[0.15 0.15],'k-');
    plot(120+[1 60],[0.225 0.225],'k-');
    plot(180+[1 240],[0.3 0.3],'k-');
elseif ~isempty(strfind(Chasefiles{1},'inward'))
    plot(60+[1 size(Latency,1)],[0.12 0.12],'k-');
end
hold off;
xlabel('Trial');
ylabel('Peak Velocity (m/s)');
set(gca,'box','off');
set(gca,'xtick',itick,'xticklabel',[{'Pre'},iticklabel,{'Post'}])
set(gca,'xlim',[0 120+size(Latency,1)+1]);

subplot(3,1,3)
errorfield([1:60],nanmean(AmpPre,2),nanstd(AmpPre,[],2)/sqrt(length(Subj)),'b-');
hold on
errorfield(60+[1:size(Latency,1)],nanmean(Amp,2),nanstd(Amp,[],2)/sqrt(length(Subj)),'c-');
errorfield(60+size(Latency,1)+[1:60],nanmean(AmpPst,2),nanstd(AmpPst,[],2)/sqrt(length(Subj)),'r-');
plot([1 60],nanmean(nanmean(AmpPre,2))*[1 1],'k-');
plot(60+size(Latency,1)+[1 60],nanmean(nanmean(AmpPst,2))*[1 1],'k-');
ylims = get(gca,'ylim');
for a = 1:size(Latency,1)/60
    plot(60*a+[0.5 0.5],ylims,'k:');
end
plot(60+size(Latency,1)+[0.5 0.5],ylims,'k:');
plot([1 60],[0.15 0.15],'g--');
plot(60+[1:size(Latency,1)],nanmean(TgtAmp,2),'g--');
plot(60+size(Latency,1)+[1 60],[0.15 0.15],'g--');
hold off;
xlabel('Trial');
ylabel('Amplitude (m)');
set(gca,'ylim',ylims,'ytick',[0:0.1:0.4],'box','off');
set(gca,'xtick',itick,'xticklabel',[{'Pre'},iticklabel,{'Post'}])
set(gca,'xlim',[0 120+size(Latency,1)+1]);



figure(11+plotadd)
subplot(1,3,1)
lat = [nanmean(LatencyPre(11:end,:))' nanmean(LatencyPst(11:end,:))'];
bar([1 2],nanmean(lat));
hold on;
plot(lat','ko-');
hold off;
xlabel('Block');
ylabel('Latency (ms)');
set(gca,'xtick',[1 2],'xticklabel',{'Pre','Post'},'xlim',[0.5 2.5]);
set(gca,'ylim',[150 450]);
set(gca,'box','off')
[~,plat,~,latstats] = ttest(lat(:,1),lat(:,2));
[pwilcoxlat,~,wilcoxlatstats] = signrank(lat(:,1),lat(:,2));

subplot(1,3,2)
vp = [nanmean(VPeakPre(11:end,:))' nanmean(VPeakPst(11:end,:))'];
bar([1 2],nanmean(vp));
hold on;
plot(vp','ko-');
hold off;
xlabel('Block');
ylabel('Peak Velocity (m/s)');
set(gca,'xtick',[1 2],'xticklabel',{'Pre','Post'},'xlim',[0.5 2.5]);
set(gca,'ylim',[0.4 0.8]);
set(gca,'box','off')
[~,pvel,~,velstats] = ttest(vp(:,1),vp(:,2));
[pwilcoxvel,~,wilcoxvelstats] = signrank(vp(:,1),vp(:,2));

subplot(1,3,3)
err = [nanmean(EndPtErrPre(11:end,:))' nanmean(EndPtErrPst(11:end,:))'];
bar([1 2],nanmean(err));
hold on;
plot(err','ko-');
hold off;
xlabel('Block');
ylabel('Endpoint Error (cm)');
set(gca,'xtick',[1 2],'xticklabel',{'Pre','Post'},'xlim',[0.5 2.5]);
set(gca,'ylim',[0 4.0]);
set(gca,'box','off')
[~,perr,~,errstats] = ttest(err(:,1),err(:,2));
[pwilcoxerr,~,wilcoxerrstats] = signrank(err(:,1),err(:,2));


ps = padjust([plat pvel perr]');

LatEndTrain = nanmean(Latency(end-59:end,:))';
VPEndTrain = nanmean(VPeak(end-59:end,:))';

[~,plattrain,~,statslattrain] = ttest(lat(:,1),LatEndTrain);
[~,pveltrain,~,statsveltrain] = ttest(vp(:,1),VPEndTrain);

ps1 = padjust([plattrain pveltrain]');

fprintf('\n\n');
fprintf('Stats for %sward intercept experiment\n',chasetype);

fprintf('\n\n');
fprintf('Latency: Pre: %.3f +/- %.3f\n',nanmean(lat(:,1)),nanstd(lat(:,1))/sqrt(length(lat(:,1))));
fprintf('Latency: Pst: %.3f +/- %.3f\n',nanmean(lat(:,2)),nanstd(lat(:,2))/sqrt(length(lat(:,2))));
fprintf('Latency: t(%d) = %.3f, p = %.3f\n',latstats.df,latstats.tstat,ps(1));

fprintf('Latency: EndTrain: %.3f +/- %.3f\n',nanmean(LatEndTrain),nanstd(LatEndTrain)/sqrt(length(lat(:,2))));
fprintf('  PctLat: %.3f +/- %.3f\n',nanmean(pctLat),nanstd(pctLat)/sqrt(length(pctLat)));
fprintf('  PctLat: t(%d) = %.3f, p = %.3f\n',pctlatstats.df,pctlatstats.tstat,ppctlat);

fprintf('\n\n');

fprintf('Peak Vel: Pre: %.3f +/- %.3f\n',nanmean(vp(:,1)),nanstd(vp(:,1))/sqrt(length(vp(:,1))));
fprintf('Peak Vel: Pst: %.3f +/- %.3f\n',nanmean(vp(:,2)),nanstd(vp(:,2))/sqrt(length(vp(:,2))));
fprintf('Peak Vel: t(%d) = %.3f, p = %.3f\n',velstats.df,velstats.tstat,ps(2));
fprintf('Peak Vel: EndTrain: %.3f +/- %.3f\n',nanmean(VPEndTrain),nanstd(VPEndTrain)/sqrt(length(vp(:,2))));


fprintf('\n\n');

fprintf('Endpt Err: Pre: %.3f +/- %.3f\n',nanmean(err(:,1)),nanstd(err(:,1))/sqrt(length(err(:,1))));
fprintf('Endpt Err: Pst: %.3f +/- %.3f\n',nanmean(err(:,2)),nanstd(err(:,2))/sqrt(length(err(:,2))));
fprintf('Endpt Err: t(%d) = %.3f, p = %.3f\n',errstats.df,errstats.tstat,ps(3));



figure(100)
hold on;
errorbar([1 2], nanmean(lat), nanstd(lat)/sqrt(size(lat,1)),'o-');
xlabel('Block');
ylabel('Reaction time (ms)');
legend('Outward','Inward');
set(gca,'xtick',[1 2],'xticklabel',{'Pre','Post'});


%% output to R

if (true)  %change to true to output a compact data text file for running R statistical analyses

path = [pwd() '\r data analysis\'];

fid = fopen([path 'chase' chasetype '.txt'],'wt');

iline = 0;

fprintf(fid,'Lat Vpeak Err Block Subj Trial\n');
for a = 1:length(Subj)
    for b = 11:length(Subj(a).PP(1).Latency)
        iline = iline+1;
        fprintf(fid,'%d %.3f %.3f %.3f 1 %d %d\n',iline,Subj(a).PP(1).Latency(b),Subj(a).PP(1).VPeak(b),Subj(a).PP(1).EndPtErr(b),a,b);
    end
    for b = 11:length(Subj(a).PP(2).Latency)
        iline = iline+1;
        fprintf(fid,'%d %.3f %.3f %.3f 2 %d %d\n',iline,Subj(a).PP(2).Latency(b),Subj(a).PP(2).VPeak(b),Subj(a).PP(2).EndPtErr(b),a,b+60);
    end
end


fclose(fid);

end



end