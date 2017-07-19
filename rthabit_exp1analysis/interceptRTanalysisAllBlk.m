%This code compiles data for all blocks from one subject, for the
%  RT-accuracy paradigm. This code assumes the data from all blocks to be
%  compiled resides in a single folder. Run the code, navigate to the
%  appropriate folder, and and select all the files to be compiled. The
%  code will automatically compile the data and save it.
%
%Code by Aaron L. Wong


clear all;
close all;

%allow the user to select files, order them, and return the data to the
%  workspace as a char array pathname and a cell filename with the list of
%  selected files.
global exten
exten = '*.mat';
inputGUI;
uiwait(guih.figure1);
clear exten guih;

if length(filename) == 1
    load([pathname filename{1}]);
    dosave = 0;
else
    dosave = 1;


    
%load all blocks
iS = 0;
iC = 0;
for a = 1:length(filename)
    if ~isempty(strfind(filename{a},'static'))  %we assume there are 2 static blocks, pre and post, tested in order.
        iS = iS+1;
        blocksS{iS} = load([pathname filename{a}]);
        
        for b = 1:length(blocksS{iS}.reach)
            if ~isempty(blocksS{iS}.reach(b).handx) && ~any(isnan(blocksS{iS}.reach(b).handx))
                blocksS{iS}.Amp(b,1) = sqrt( (blocksS{iS}.reach(b).handx(end)-blocksS{iS}.reach(b).handx(1))^2 + (blocksS{iS}.reach(b).handy(end)-blocksS{iS}.reach(b).handy(1))^2);
                blocksS{iS}.TgtAmp(b,1) = sqrt( sum((blocksS{iS}.reach(b).tgt(end,:)-blocksS{iS}.reach(b).starttgt).^2));
            else
                blocksS{iS}.Amp(b,1) = NaN;
                blocksS{iS}.TgtAmp(b,1) = NaN;
            end
        end
        
    elseif ~isempty(strfind(filename{a},'chase')) || ~isempty(strfind(filename{a},'intcpt'))
        iC = iC+1;
        blocksC{iC} = load([pathname filename{a}]);
        
        for b = 1:length(blocksC{iC}.reach)
            if ~isempty(blocksC{iC}.reach(b).handx) && ~any(isnan(blocksC{iC}.reach(b).handx))
                blocksC{iC}.Amp(b,1) = sqrt( (blocksC{iC}.reach(b).handx(end)-blocksC{iC}.reach(b).handx(1))^2 + (blocksC{iC}.reach(b).handy(end)-blocksC{iC}.reach(b).handy(1))^2);
                blocksC{iC}.TgtAmp(b,1) = sqrt( sum((blocksC{iC}.reach(b).tgt(end,:)-blocksC{iC}.reach(b).starttgt).^2));
            else
                blocksC{iC}.Amp(b,1) = NaN;
                blocksC{iC}.TgtAmp(b,1) = NaN;
            end
        end

    end
end

end

Latency = [];
VPeak = [];
InterceptErr = [];
MvmtTime = [];
InitDir = [];
TargetDir = [];
Amp = [];
TgtAmp = [];


iplt = 1;

figure(101)
plot([iplt:iplt+length(blocksS{1}.Latency)-1]',blocksS{1}.Latency,'ko');
hold on;
plot([iplt iplt+length(blocksS{1}.Latency)-1]',[1 1]*nanmean(blocksS{1}.Latency(10:end)),'r-');
hold off;

figure(102)
plot([iplt:iplt+length(blocksS{1}.VPeak)-1]',blocksS{1}.VPeak,'ko');
hold on;
plot([iplt iplt+length(blocksS{1}.VPeak)-1]',[1 1]*nanmean(blocksS{1}.VPeak(10:end)),'r-');
hold off;

figure(103)
plot([iplt:iplt+length(blocksS{1}.Amp)-1]',blocksS{1}.Amp,'ko');
hold on;
plot([iplt iplt+length(blocksS{1}.Amp)-1]',[1 1]*nanmean(blocksS{1}.Amp(10:end)),'r-');
hold off;

iplt = iplt+length(blocksS{1}.Latency)-1;


for a = 1:length(blocksC)
    figure(101)
    hold on;
    plot([iplt:iplt+length(blocksC{a}.Latency)-1]',blocksC{a}.Latency,'.');
    plot([iplt iplt+length(blocksC{a}.Latency)-1]',[1 1]*nanmean(blocksC{a}.Latency),'r-');
    hold off;
    
    figure(102)
    hold on;
    plot([iplt:iplt+length(blocksC{a}.VPeak)-1]',blocksC{a}.VPeak,'.');
    plot([iplt iplt+length(blocksC{a}.VPeak)-1]',[1 1]*nanmean(blocksC{a}.VPeak),'r-');
    hold off;

    figure(103)
    hold on;
    plot([iplt:iplt+length(blocksC{a}.Amp)-1]',blocksC{a}.Amp,'.');
    plot([iplt:iplt+length(blocksC{a}.TgtAmp)-1]',blocksC{a}.TgtAmp,'x');
    plot([iplt iplt+length(blocksC{a}.Amp)-1]',[1 1]*nanmean(blocksC{a}.Amp),'r-');
    hold off;
    
    iplt = iplt+length(blocksC{a}.Latency)-1;
    
    
    Latency = [Latency; blocksC{a}.Latency];
    VPeak = [VPeak; blocksC{a}.VPeak];
    InterceptErr = [InterceptErr; blocksC{a}.InterceptErr];
    MvmtTime = [MvmtTime; blocksC{a}.MvmtTime];
    InitDir = [InitDir; blocksC{a}.InitDir];
    TargetDir = [TargetDir; blocksC{a}.TargetDir];
    Amp = [Amp; blocksC{a}.Amp];
    TgtAmp = [TgtAmp; blocksC{a}.TgtAmp];
end

figure(101)
hold on;
plot([iplt:iplt+length(blocksS{2}.Latency)-1]',blocksS{2}.Latency,'ko');
plot([iplt iplt+length(blocksS{2}.Latency)-1]',[1 1]*nanmean(blocksS{2}.Latency),'r-');
hold off;
legend('point-to-point');
xlabel('Trial');
ylabel('Reaction Time');

figure(102)
hold on;
plot([iplt:iplt+length(blocksS{2}.VPeak)-1]',blocksS{2}.VPeak,'ko');
plot([iplt iplt+length(blocksS{2}.VPeak)-1]',[1 1]*nanmean(blocksS{2}.VPeak),'r-');
hold off;
legend('point-to-point');
xlabel('Trial');
ylabel('Peak Velocity');

figure(103)
hold on;
plot([iplt:iplt+length(blocksS{2}.Amp)-1]',blocksS{2}.Amp,'ko');
plot([iplt iplt+length(blocksS{2}.Amp)-1]',[1 1]*nanmean(blocksS{2}.Amp),'r-');
hold off;
legend('point-to-point');
xlabel('Trial');
ylabel('Amplitude');


figure(1)
h(1) = histogram(blocksS{1}.Latency,[150:10:650]-5,'Normalization','pdf');
hold on
h(2) = histogram(blocksS{2}.Latency,[150:10:650]-5,'Normalization','pdf');
hold off;
set(h(1),'FaceColor','b','FaceAlpha',0.75);
set(h(2),'FaceColor','r','FaceAlpha',0.75);
xlabel('Latency');
legend('Pre','Post');

figure(2)
h(1) = histogram(blocksS{1}.VPeak,[0.3:0.02:1.3],'Normalization','pdf');
hold on
h(2) = histogram(blocksS{2}.VPeak,[0.3:0.02:1.3],'Normalization','pdf');
hold off;
set(h(1),'FaceColor','b','FaceAlpha',0.75);
set(h(2),'FaceColor','r','FaceAlpha',0.75);
xlabel('Peak Velocity');
legend('Pre','Post');

figure(3)
h(1) = histogram(blocksS{1}.EndPtErr,[-1:0.1:4]-0.05,'Normalization','pdf');
hold on
h(2) = histogram(blocksS{2}.EndPtErr,[-1:0.1:4]-0.05,'Normalization','pdf');
hold off;
set(h(1),'FaceColor','b','FaceAlpha',0.75);
set(h(2),'FaceColor','r','FaceAlpha',0.75);
xlabel('Endpoint Error');
legend('Pre','Post');

figure(4)
subplot(2,1,1)
h(1) = histogram(blocksS{1}.Amp,[0.1:0.005:0.2]-0.005/2,'Normalization','pdf');
hold on
h(2) = histogram(blocksS{2}.Amp,[0.1:0.005:0.2]-0.005/2,'Normalization','pdf');
hold off;
set(h(1),'FaceColor','b','FaceAlpha',0.75);
set(h(2),'FaceColor','r','FaceAlpha',0.75);
xlabel('Amplitude');
legend('Pre','Post');

subplot(2,1,2)
h(1) = histogram(blocksS{1}.TgtAmp,[0.1:0.005:0.2]-0.005/2,'Normalization','pdf');
hold on
h(2) = histogram(blocksS{2}.TgtAmp,[0.1:0.005:0.2]-0.005/2,'Normalization','pdf');
hold off;
set(h(1),'FaceColor','b','FaceAlpha',0.75);
set(h(2),'FaceColor','r','FaceAlpha',0.75);
xlabel('Target Intersection Amplitude');
legend('Pre','Post');

close all;


%save compiled data
if (dosave)
    clear a tmp* iC iS dosave h iplt 
    
    save([pathname 'chase_allblk.mat']);
    fprintf('\n\nFile saved: %s.\n\n',pathname(end-10:end-1));
end