function [pos,vel,acc,complexity] = processComplexTraj(t,x,y,starttgt,tgt,tgtcode,spath,tpath,varargin)
% This function processes a single "trial" of kinereach data defined as a
%    single complex trajectory in the RTtgtbox task.
%
% Pulling out the peak velocity (v_pk)
% reaction time (t_takeoff) and 
% end-point timing (t_vend)
%
%dimensions are in meters, velocity in m/s, time in msec

fig = 0;
a = 1;
doplot = 0;
doverifyvel = 0;
irdcriterion = 1;
while a <= length(varargin)
    switch(varargin{a})
        case 'fig'
            fig = varargin{a+1};
            a = a+2;
        case 'doplot'
            doplot = varargin{a+1};
            a = a+2;
        case 'verifyvel'
            doverifyvel = varargin{a+1};
            a = a+2;
        case 'irdcriterion'
            irdcriterion = varargin{a+1};
            a = a+2;
        otherwise
            disp('Unrecognized input to processKinTrial');
            a = a+1;
    end
end

dist_thresh = 0.05;     %threshold for "reaching" the target

start_x = starttgt(1);
start_y = starttgt(2);
target_x = tgt(1);
target_y = tgt(2);

dt = mean(diff(t))/1000; %sampling interval, sec

% filter position trace
smoothedX = sgolayfilt(x,2,19);
smoothedY = sgolayfilt(y,2,19);

% get velocity
vel.velX = gradient(smoothedX,dt);
vel.velY = gradient(smoothedY,dt);       % non-filtered velocity
vel.velXY = sqrt(vel.velX.^2+vel.velY.^2);	% 2D (tangental) velocity

%get acceleration
dx2dt = sgolayfilt(vel.velX,2,19);     % filtered y velocity
acc.accX = gradient(dx2dt,dt);	%acceleration
dy2dt = sgolayfilt(vel.velY,2,19);      % filterred y velocity
acc.accY = gradient(dy2dt,dt);	%acceleration
acc.accXY = sqrt(acc.accX.^2+acc.accY.^2);   %tangential acceleration

%the end of the reach is the point where the hand reached the target
pos.endpointX = x(end);
pos.endpointY = y(end);

%calculate the distance from movement endpoint to the target
pos.end_dist = sqrt((target_x-x(end)).^2 + (target_y-y(end)).^2); 
pos.end_ang = (atan2((y(end)-target_y),(x(end)-target_x))) * 180/pi; 

% getting the index of the first peak velocity, for actual timing use
% using tangental velocity
[vel.vpeak,vel.vpeakt] = max(vel.velXY);
vel.vpeakt = vel.vpeakt(1);
vel.vpeak = vel.vpeak(1);

%find the first max acceleration (btwn the start of the reach and the vpeak
[acc.apeak,acc.apeakt] = max(acc.accXY(1:vel.vpeakt));
acc.apeakt = acc.apeakt;

%calculate the perpendicular deviation errors from straight-line movements

%d = abs(det([Q2-Q1;P-Q1]))/norm(Q2-Q1); %distance from a point to a line;
%   q1 and q2 are two points on the line, p is the point, all specified as row vectors 
%for all points on the trajectory, we want to calculate the perpendicular
%  distance to the target line, along the outbound movement from t_start to
%  the turnaround point.  note, this is *absolute* error!

mvstartpos = [x(1) y(1)];
for a = 1:length(x)
    p = [x(a) y(a)];
    pos.perpdist(a) = abs(det([tgt-mvstartpos;p-mvstartpos]))/norm(tgt-mvstartpos); %unsigned!
end


%compute the initial movement direction
t_start = 1;
switch (irdcriterion)
    case 1
        %150 ms after movement onset.
        t_threshi = find((t-t(t_start))<150);
        t_threshi = t_threshi(end);
    case 2
        %1/3 of the way into the movement
        tmpdist = sqrt( (x-start_x).^2 + (y-start_y).^2 );
        t_threshi = find(tmpdist < (1/3)*sqrt(target_x^2+target_y^2));
        t_threshi = t_threshi(end);
    case 3
        %250 ms after movement onset
        t_threshi = find((t-t(t_start))<250);
        t_threshi = t_threshi(end);        
    otherwise
        %default: 100 ms after movement onset.
        t_threshi = find((t-t(t_start))<100);
        t_threshi = t_threshi(end);
end

pos.initang = atan2(vel.velY(t_threshi),vel.velX(t_threshi))*180/pi;

vel.initvel = sqrt(sum([vel.velY(t_threshi) vel.velX(t_threshi)].^2));


%***define movement complexity***

%1.) as a first cut, we will count velocity peaks.  we want the number of x
%    and y velocity peaks, as well as the number of magnitude-velocity peaks
[maxi,mini] = peakdet(vel.velXY/max(vel.velXY),0.01);
%indi=markdata1(vel.velXY,length(vel.velXY),1,sort([maxi(:,1); mini(:,1)]));
maxval = maxi(:,2);
maxi = maxi(:,1)';
maxi(abs(maxval)<(0.1/max(vel.velXY))) = NaN;
maxi(maxi<10) = NaN;
maxi(maxi>length(x)-9) = NaN;
maxi(isnan(maxi)) = [];
if doverifyvel > 0
    figure(doverifyvel);
    indi=markdata1(vel.velXY,length(vel.velXY),1,maxi,'Name','Mark VelXY peaks','plotxax',1);
else
    indi = maxi;
end
vel.velmagpeaks = indi';
vel.nvelmagpeaks = length(indi);

[maxi,mini] = peakdet(abs(vel.velX)/max(abs(vel.velX)),0.01);
maxval = maxi(:,2);
maxi = maxi(:,1)';
maxi(abs(maxval)<(0.1/max(vel.velXY))) = NaN;
maxi(maxi<10) = NaN;
maxi(maxi>length(x)-9) = NaN;
maxi(isnan(maxi)) = [];
if doverifyvel > 0
    figure(doverifyvel);
    indi=markdata1(vel.velX,length(vel.velX),1,maxi,'Name','Mark VelX peaks','plotxax',1);
else
    indi = maxi;
end
vel.velXpeaks = indi';
vel.nvelXpeaks = length(indi);

[maxi,mini] = peakdet(abs(vel.velY)/max(abs(vel.velY)),0.01);
maxval = maxi(:,2);
maxi = maxi(:,1)';
maxi(abs(maxval)<(0.1/max(vel.velXY))) = NaN;
maxi(maxi<10) = NaN;
maxi(maxi>length(x)-9) = NaN;
maxi(isnan(maxi)) = [];
if doverifyvel > 0
    figure(doverifyvel);
    indi=markdata1(vel.velY,length(vel.velY),1,maxi,'Name','Mark VelY peaks','plotxax',1);
else
    indi = maxi;
end
vel.velYpeaks = indi';
vel.nvelYpeaks = length(indi);
vel.nvelpeaks = vel.nvelXpeaks+vel.nvelYpeaks;

%2.) Calculate curvature, and other measures of complexity.
complexity = calculateCurvature(x,y,tgtcode,spath,tpath,'doplot',doplot);



if(fig>0)
    figure(fig);
    subplot(3,1,1);
    plot(x,y); hold on;
    plot(start_x,start_y,'gx',x(1),y(1),'go',target_x,target_y,'bx',...
         x(end),y(end),'bo',x(vel.vpeakt),y(vel.vpeakt),'m*');
    hold off;
    
    subplot(3,1,2)
    plot(time,[vel.velX vel.velY]);hold on; 
    plot(time(vel.vpeakt),vel.velX(vel.vpeakt),'m*',time(vel.vpeakt),vel.velY(vel.vpeakt),'m*',...
         time(end),vel.velX(end),'bo',time(end),vel.velY(end),'bo',...
         time(1),vel.velX(1),'go',time(1),vel.velY(1),'go');
    hold off;
    
    subplot(3,1,3);
    plot(time,[acc.accX acc.accY]);hold on; 
    plot(time(acc.apeakt),acc.accX(acc.apeakt),'m*',time(acc.apeakt),acc.accY(acc.apeakt),'m*',...
         time(end),acc.accX(end),'bo',time(end),acc.accY(end),'bo',...
         time(1),acc.accX(1),'go',time(1),acc.accY(1),'go');
    hold off;
    
    
end
