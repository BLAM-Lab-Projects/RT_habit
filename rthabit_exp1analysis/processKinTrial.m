function [good_data,pos,vel,acc,varargout] = processKinTrial(t,x,y,starttgt,tgt,varargin)
% This function processes a single trial of kinereach data defined as an
% outward reach.
%
% Pulling out the peak velocity (v_pk)
% reaction time (t_takeoff) and 
% end-point timing (t_vend)
%
%dimensions are in meters, velocity in m/s, time in msec

fig = 0;
a = 1;
trtype = 1;
rotang = [0 0];
mirror = 0;
multiseg = 0;   %this is a flag notifying that there may be more than one peak velocity in the movement (e.g., a multi-segmented reach, as in the go-before-you-know task), and to compute the initial movement direction accordingly
v_start = [];
irdcriterion = 0;
while a <= length(varargin)
    switch(varargin{a})
        case 'fig'
            fig = varargin{a+1};
            a = a+2;
        case 'trtype'
            trtype = varargin{a+1};
            a = a+2;
        case 'rotang'
            rotang = varargin{a+1};
            a = a+2;
        case 'mirror'
            mirror = varargin{a+1};
            a = a+2;
        case 'multiseg'
            multiseg = 1;
            a = a+1;
        case 'irdcriterion'
            irdcriterion = varargin{a+1};
            a = a+2;
        case 'vstart'
            v_start = varargin{a+1};
            a = a+2;
        otherwise
            disp('Unrecognized input to processKinTrial');
            a = a+1;
    end
end

dist_thresh = 0.0075;     %radius threshold for "reaching" the target

if isempty(v_start)
    v_start = 0.075; % movement onset, used for initial cut-off & searching backwards from peak velocity
end
vmaxthresh = 0.15;

start_x = starttgt(1);
start_y = starttgt(2);
target_x = tgt(1);  %this is a relative position, i.e. the start target has already been subtracted
target_y = tgt(2);


mirrorInversion = [0 1;
                   1 0
                  ];


rotMat = [ cosd(rotang(1)-rotang(2)) -sind(rotang(1)-rotang(2));
           sind(rotang(1)-rotang(2))  cosd(rotang(1)-rotang(2))
         ];
rothand = rotMat*[x'-start_x;y'-start_y];
%mirrorInversion
rothandx1 = rothand(1,:)'+start_x;
rothandy1 = rothand(2,:)'+start_y;
rottgt1 = (rotMat*tgt')';

rotMat = [ cosd(rotang(1)) -sind(rotang(1));
           sind(rotang(1))  cosd(rotang(1))
         ];
rothand = rotMat*[x'-start_x;y'-start_y];
rothandx2 = rothand(1,:)'+start_x;
rothandy2 = rothand(2,:)'+start_y;
rottgt2 = (rotMat*tgt')';

origx = x;
origy = y;
origtgt = tgt;

% t
x = rothandx1;
y = rothandy1;
tgt = rottgt1;arget_x = tgt(1);  %this is a relative position, i.e. the start target has already been subtracted
% target_y = tgt(2);

xR = rothandx2;
yR = rothandy2;
tgtR = rottgt2;

% %if the mirror is set, invert the x axis
% if mirror
%     xp = -(x-starttgt(1))+starttgt(1);
%     xRp = -(xR-starttgt(1))+starttgt(1);
% end


mvmtvecdir = (atan2((start_y-target_y),(start_x-target_x))) * 180/pi;

dt = mean(diff(t))/1000; %sampling interval, sec

% filter position trace
smoothedX = sgolayfilt(x,2,min([19,2*floor((length(x)-2)/2)+1]));
smoothedY = sgolayfilt(y,2,min([19,2*floor((length(y)-2)/2)+1]));

smoothedXR = sgolayfilt(xR,2,min([19,2*floor((length(xR)-2)/2)+1]));
smoothedYR = sgolayfilt(yR,2,min([19,2*floor((length(yR)-2)/2)+1]));


% get velocity
vel.velX = gradient(smoothedX,dt);      % non-filtered velocity
vel.velY = gradient(smoothedY,dt);      % non-filtered velocity
vel.velXY = sqrt(vel.velX.^2+vel.velY.^2);	% 2D (tangental) velocity

vel.velXR = gradient(smoothedXR,dt);      % non-filtered velocity
vel.velYR = gradient(smoothedYR,dt);      % non-filtered velocity

dx2dt = sgolayfilt(vel.velX,2,min([19,2*floor((length(vel.velX)-2)/2)+1]));     % filtered x velocity
acc.accX = gradient(dx2dt,dt);         %non-filtered acceleration
dy2dt = sgolayfilt(vel.velY,2,min([19,2*floor((length(vel.velY)-2)/2)+1]));     % filterred y velocity
acc.accY = gradient(dy2dt,dt);         %non-filtered acceleration
acc.accXY = sqrt(acc.accX.^2+acc.accY.^2);   %tangential acceleration

good_data = 1;
% criteria for bad movements:
% 1. too slow
if max(vel.velXY) < 0.1
    good_data = 0;
end

% find the position of the hand when it crosses the circle of targets
tgtCircRad = sqrt(target_x^2+target_y^2);
centeredx = x-start_x;
centeredy = y-start_y;
rad = sqrt(centeredx.^2+centeredy.^2);
imvmt = find(rad<tgtCircRad);
handx = centeredx(imvmt(end)-2:min(imvmt(end)+2,length(centeredx)));
handy = centeredy(imvmt(end)-2:min(imvmt(end)+2,length(centeredy)));
pos.endptind = imvmt(end)+1;
pos.mvmttime = t(min(imvmt(end)+1,length(t)))-t(1);
pos.tgterr = sqrt( ( (centeredx(imvmt(end))-target_x)^2+(centeredy(imvmt(end))-target_y)^2) - (sqrt(target_x^2+target_y^2) - sqrt(centeredx(imvmt(end))^2+centeredy(imvmt(end))^2) )^2 );
pos.success = (any(sqrt( (centeredx(imvmt)-target_x).^2 + (centeredy(imvmt)-target_y).^2 ) < 0.01));
if pos.success == 0
    	A = (centeredx(imvmt(end-5:end)) - centeredx(imvmt(end-6:end-1))).^2 + (centeredy(imvmt(end-5:end)) - centeredy(imvmt(end-6:end-1))).^2;
		B = 2*((centeredx(imvmt(end-5:end)) - centeredx(imvmt(end-6:end-1))).*(centeredx(imvmt(end-6:end-1)) - target_x) + (centeredy(imvmt(end-5:end)) - centeredy(imvmt(end-6:end-1))).*(centeredy(imvmt(end-6:end-1)) - target_y));
		C = (centeredx(imvmt(end-5:end)) - target_x).^2 + (centeredy(imvmt(end-5:end)) - target_y).^2 - 0.01*0.01;

        if any(B.*B - 4*A.*C > 0) % if real solution exists, infinite line intersects target
            t1 = (-B + sqrt(B.*B - 4*A.*C))./(2*A);
            if(any(t1 < 1 & t1 > 0)) % line intersects target in between the two points
                pos.success = 1;
            else
                pos.success = 0;
            end
        else
            pos.success = 0;
        end
end            


%calculate the equation of the regression line approximating the hand path
sumx = sum(handx);
sumy = sum(handy);
sumxy = sum(handx.*handy);
sumx2 = sum(handx.^2);
sumy2 = sum(handy.^2);

m = (length(handx)*sumxy - sumx*sumy)/(length(handx)*sumx2 - sumx^2);
c = (sumx2*sumy - sumx*sumxy)/(length(handx)*sumx2 - sumx^2);

%now we want the intersection of that line and the circle of the target
%  radius. we are guaranteed by the situation to have 2 intersection
%  points.  The equation of the circle is (x-p)^2 + (y-q)^2 = r^2.

p = 0;
q = 0;
rsqr = tgtCircRad^2;
A = (m^2+1);
B = 2*(m*c-m*q-p);
C = (q^2-rsqr+p^2-2*c*q+c^2);

x1int = (-B+sqrt(B^2-4*A*C))/(2*A);
x2int = (-B-sqrt(B^2-4*A*C))/(2*A);
y1int = m*x1int+c;
y2int = m*x2int+c;

if ( ((handx(3)-x1int)^2+(handy(3)-y1int)^2) <= ((handx(3)-x2int)^2+(handy(3)-y2int)^2) )  %we want the solution that is closest to the hand position
    pos.endpt = [x1int y1int];
else
    pos.endpt = [x2int y2int];
end

if mirror
    pos.mrendpt = pos.endpt; 
    %pos.mrendpt(1) = -(pos.mrendpt(1) - starttgt(1)) + starttgt(1);
    pos.mrendpt(1) = -pos.mrendpt(1);
    
    %calculate the distance to the target, with zero x and y velocity, at the
    %point it crosses the target circle
    mvend_dist = sqrt((target_x-pos.mrendpt(1))^2 + (target_y-pos.mrendpt(2))^2);
    mvend_ang = (atan2((pos.mrendpt(2)-target_y),(pos.mrendpt(1)-target_x))) * 180/pi;
    
    %compute the error sign as: positive = undershoot, negative = overshoot,
    %  along the vector defined as the start target to the end target.  so,
    %  let's project the error onto the movement vector, and compute the sign
    %  of the projection.
    mvend_projang = mvmtvecdir-mvend_ang;   %if |angle| is < 90 deg, this is a positive error.
    mvend_dist(abs(mvend_projang)<=90) = mvend_dist(abs(mvend_projang)<=90)*-1; %assign a sign to the error distance
    
    pos.endpterr = mvend_dist;
    pos.endptang = mvend_ang;
    
else
    
    %calculate the distance to the target, with zero x and y velocity, at the
    %point it crosses the target circle
    mvend_dist = sqrt((target_x-pos.endpt(1))^2 + (target_y-pos.endpt(2))^2);
    if all(isreal(pos.endpt))
        mvend_ang = (atan2((pos.endpt(2)-target_y),(pos.endpt(1)-target_x))) * 180/pi;
    else
        mvend_ang = NaN;
    end
    
    %compute the error sign as: positive = undershoot, negative = overshoot,
    %  along the vector defined as the start target to the end target.  so,
    %  let's project the error onto the movement vector, and compute the sign
    %  of the projection.
    mvend_projang = mvmtvecdir-mvend_ang;   %if |angle| is < 90 deg, this is a positive error.
    mvend_dist(abs(mvend_projang)<=90) = mvend_dist(abs(mvend_projang)<=90)*-1; %assign a sign to the error distance
    
    pos.endpterr = mvend_dist;
    pos.endptang = mvend_ang;
    
end




% getting the index of peak velocity, for actual timing use
% using tangental velocity
[vel.vpeak,vel.vpeakt] = max(vel.velXY);
vel.vpeakt = vel.vpeakt;

[acc.apeak,acc.apeakt] = max(acc.accXY(1:vel.vpeakt));
acc.apeakt = acc.apeakt;

% find the last time stamp before peak that velocity reaches the threshold
if multiseg == 0
    t_start = find(vel.velXY(1:vel.vpeakt)<v_start);%,1,'last');
    
    if isempty(t_start)
        t_start = 1;
    else
        t_start = t_start(end);
    end

elseif multiseg == 1
    %there are multiple reach segments potentially embedded here. We want
    %to pick the last point before the vel exhibits any kind of peak
    t_start = find(vel.velXY(1:vel.vpeakt)<v_start);%,1,'last');
    
    if isempty(t_start)
        t_start = 1;
    else
    
        while any(vel.velXY(1:t_start(end)) > vmaxthresh)
            if length(t_start) == 1
                break;
            else
                t_start(end) = [];
            end
        end
        t_start = t_start(end);
    end
end
    

%t_start = 1;  %the criterion for a reach, defined in findReach, is 0.06
%m/s. So if we wanted to use that criterion we could just pick t_start = 1.

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




%calculate the heading errors after movement start
mvstartx = x(t_start);
mvstarty = y(t_start);
mvstartpos = [mvstartx mvstarty];
mvtgtvec = tgt - [mvstartx, mvstarty];
mvtgtvec = mvtgtvec/norm(mvtgtvec);
%mvidealvec = tgt - starttgt;    %should i use the true bearing from the hand start point, or the ideal bearing from the target start point?
%mvidealvec = mvidealvec/norm(mvidealvec);

mvearlyx = x(t_threshi);
mvearlyy = y(t_threshi);

if mirror
    
    pos.initang = atan2(vel.velYR(t_threshi),-vel.velXR(t_threshi))*180/pi; %+rotang(2)
    
    %the initial error should also account for the rotation.
    pos.initangerr = atan2(vel.velY(t_threshi),-vel.velX(t_threshi))*180/pi;
    
    mvvpeakx = x(vel.vpeakt);
    mvvpeaky = y(vel.vpeakt);
    pos.vpeakang = atan2(vel.velY(vel.vpeakt),-vel.velX(vel.vpeakt))*180/pi;
    
    vel.initvel = sqrt(sum([vel.velYR(t_threshi) vel.velXR(t_threshi)].^2));
    
    %compute the median heading angle along the initial phase of the reach
    mvearlyang = atan2(vel.velYR(1:vel.vpeakt),-vel.velXR(1:vel.vpeakt))*180/pi;
    pos.medearlyang = median(mvearlyang);
    
    mvearlyangerr = atan2(vel.velY(1:vel.vpeakt),-vel.velX(1:vel.vpeakt))*180/pi;
    pos.medearlyangerr = median(mvearlyangerr);
    
else
    
    pos.initang = atan2(vel.velYR(t_threshi),vel.velXR(t_threshi))*180/pi; %+rotang(2)
    
    %the initial error should also account for the rotation.
    pos.initangerr = atan2(vel.velY(t_threshi),vel.velX(t_threshi))*180/pi;
    
    mvvpeakx = x(vel.vpeakt);
    mvvpeaky = y(vel.vpeakt);
    pos.vpeakang = atan2(vel.velY(vel.vpeakt),vel.velX(vel.vpeakt))*180/pi;
    
    vel.initvel = sqrt(sum([vel.velYR(t_threshi) vel.velXR(t_threshi)].^2));
    
    %compute the median heading angle along the initial phase of the reach
    mvearlyang = atan2(vel.velYR(1:vel.vpeakt),vel.velXR(1:vel.vpeakt))*180/pi;
    pos.medearlyang = median(mvearlyang);
    
    mvearlyangerr = atan2(vel.velY(1:vel.vpeakt),vel.velX(1:vel.vpeakt))*180/pi;
    pos.medearlyangerr = median(mvearlyangerr);

end


%calculate the perpendicular deviation errors from straight-line movements

%d = abs(det([Q2-Q1;P-Q1]))/norm(Q2-Q1); %distance from a point to a line;
%   q1 and q2 are two points on the line, p is the point, all specified as row vectors 
%for all points on the trajectory, we want to calculate the perpendicular
%  distance to the target line, along the outbound movement from t_start to
%  the turnaround point.  note, this is *absolute* error!

for a = t_start:1:length(x)
    p = [x(a) y(a)];
    pos.perpdist(a) = abs(det([tgt-mvstartpos;p-mvstartpos]))/norm(tgt-mvstartpos); %unsigned!
end

    
if(fig>0)
    figure(fig);
    subplot(3,1,1);
    plot(x,y); hold on;
    plot(start_x,start_y,'gx',x(t_start),y(t_start),'go',target_x,target_y,'bx',...
         x(end),y(end),'bo',x(vel.vpeakt),y(vel.vpeakt),'m*',x(t100_i),y(t100_i),'m^');
    hold off;
    
    subplot(3,1,2)
    plot(time,[vel.velX vel.velY]);hold on; 
    plot(time(vel.vpeakt),vel.velX(vel.vpeakt),'m*',time(vel.vpeakt),vel.velY(vel.vpeakt),'m*',...
         time(t100_i),vel.velX(t100_i),'m^',time(t100_i),vel.velY(t100_i),'m^',...
         time(t_start),vel.velX(t_start),'go',time(t_start),vel.velY(t_start),'go');
    hold off;
    
    subplot(3,1,3);
    plot(time,[acc.accX acc.accY]);hold on; 
    plot(time(acc.apeakt),acc.accX(acc.apeakt),'m*',time(acc.apeakt),acc.accY(acc.apeakt),'m*',...
         time(t100_i),acc.accX(t100_i),'m^',time(t100_i),acc.accY(t100_i),'m^',...
         time(t_start),acc.accX(t_start),'go',time(t_start),acc.accY(t_start),'go');
    hold off;
    
end


if (nargout > 4)
    varargout{1} = [x,y];
end
