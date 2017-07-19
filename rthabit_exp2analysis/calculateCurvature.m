function [complexity] = calculateCurvature(x,y,tgtcode,spath,tpath,varargin)

a = 1;
doplot = 0;
delta = 0;
dSflag = 0;
dN = 3;
while a <= length(varargin)
    switch(varargin{a})
        case 'doplot'
            doplot = varargin{a+1};
            a = a+2;
        case 'delta'
            delta = varargin{a+1};
            a = a+2;  
        case 'dS' %data are resampled by fractional arc-length, so treat differently when calculating curvature
            a = a+1;
            dSflag = 1;
        case 'dN' %data are resampled by fractional arc-length, so treat differently when calculating curvature
            dN = varargin{a+1};
            a = a+2;
        otherwise
            disp('Unrecognized input to processKinTrial');
            a = a+1;
    end
end

if delta < dN
    delta = dN;
end

%calculate path curvature

%we will do this computation by hand.  for every N points, we will fit
%   a circle through it and take 1/R as the local curvature (note, this
%   will be unsigned).  we can compute the sign by determining if the
%   circle opens cw or ccw, although it's possibly likely that we want the
%   average unsigned curvature (so that an s shape does not have an average
%   curvature of zero).  note, the above computation does not work well
%   because you can get caught in the noise.  as a work-around solution, we
%   will try a few options.  first, we can see if we can define N according
%   to a radius (distance from the current point) criterion plus a time
%   criterion (must be consecutive points), which avoids the problem of
%   someone moving very slowly and having a lot of noise in the data. 

%dN = 3;
if doplot > 0
    figure(doplot)
    h = plot(x,y,'b-');
    set(h,'linewidth',3.0);
end
if dSflag == 0
    for a = 1+delta:length(x)-delta
        %if a <= dN
        %    curv(a) = NaN;
        %elseif a > length(x)-dN
        %    curv(a) = NaN;
        %else
        %    par = CircleFitByPratt([x(a-dN:a+dN) y(a-dN:a+dN)]);
        
        %     thresh = 0.006;  %distance threshold in meters: this is a problem
        %     because you need large thresh when vel is large, and small thresh
        %     when vel is small (otherwise you pick up sharp curves as 2-3 sides of
        %     the circle)
        %
        %     inds = find(sqrt((x-x(a)).^2+(y-y(a)).^2) < thresh);
        %     if size(inds,1) > size(inds,2)
        %         inds = inds';
        %     end
        %     if any(abs(diff(inds))>2)
        %         ind1 = find(abs(diff([0 inds])) > 2);  %now we have the start indices of the sections
        %         ind2 = [ind1(2:end)-1 length(inds)];  %these are the end indices of the sections
        %
        %         %%if there is a gap, we want the longest run
        %         %[~,ind3] = sort(ind2-ind1,'descend');  %sorted by size, in case we want to search for the section that includes a
        %
        %         %if there is a gap, we want the run that includes 'a'
        %         ind3 = [];
        %         for b = 1:length(ind1)
        %             if ind1(b)<=a && ind2(b)>=a
        %                 ind3 = b;
        %             end
        %         end
        %
        %         %failsafe to find SOMETHING
        %         if isempty(ind3)
        %             [~,ind3] = sort(ind2-ind1,'descend');  %sorted by size
        %         end
        %
        %         inds = inds(ind1(ind3(1)):ind2(ind3(1)));
        %
        %         if length(inds) <= 1
        %             inds = find(sqrt((x-x(a)).^2+(y-y(a)).^2) < thresh);
        %         end
        %     end
        %     par = CircleFitByPratt([x(inds) y(inds)]);
        
        
        %threshold along the *path* length: this could be a problem if the hand
        %doesn't move for a while.
        thresh = 0.006;
        b = 0;
        c = 0;
        pathlength = 0;
        while pathlength < thresh
            b = b+1;
            c = c+1;
            if (a-b) <= 0
                b = b-1;
            else
                pathlength = pathlength + sqrt( (x(a-b)-x(a-(b-1)))^2+(y(a-b)-y(a-(b-1)))^2 );
            end
            
            if (a+c)>=length(x)
                c = c-1;
            else
                pathlength = pathlength + sqrt( (x(a+c)-x(a+(c-1)))^2+(y(a+c)-y(a+(c-1)))^2 );
            end
        end
        inds = [a-b:a+c];
        par = CircleFitByPratt([x(a-b:a+c) y(a-b:a+c)]);
        
        if doplot > 0
            if mod(a,5) == 0
                figure(doplot)
                hold on;
                h = plot(x(a),y(a),'ro');
                set(h,'linewidth',2.0);
                th = 0:pi/50:2*pi;
                xunit = par(3) * cos(th) + par(1);
                yunit = par(3) * sin(th) + par(2);
                plot(xunit, yunit,'r-');
                plot(x(inds),y(inds),'m.');
                hold off;
                axis('equal');
            end
        end
        %radius is in m; we will get rid of the extra decimal places
        %(measure in cm) so the value doesn't blow up so large
        %curv(a) = 1/abs(par(3)*100);
        curv(a) = 1/abs(par(3));
        %end
        
        %we will assign a sign to the curvature; the sign is determined by
        %whether the center of the circle is to the right or left of the
        %line.  we can do this by taking the cross product of the radius of
        %the circle and the vector represnting the chord of the arc. we
        %assign the sign of the cross product to the sign curvature.
        c = cross([x(a)-par(1) y(a)-par(2) 0],[x(a+dN)-x(a-dN) y(a+dN)-y(a-dN) 0]);
        if sign(c(end)) ~= 0
            curv(a) = curv(a)*sign(c(end));
        end

    end
    
    
    
    % %the problem with this simple version (above) seems to be that if the
    % %  movement is slower, the algorithm will fit too much noise and make the
    % %  circle radius very small; this means "straight line" movements can have
    % %  large apparent curvature.  we need to correct this by maybe using a
    % %  sliding window that is a fixed percentage of the total number of points,
    % %  or maybe fit a circle to all the points found within a circle of radius
    % %  R; thus, slower trajectories will include more points in the fit, and
    % %  hence are more likely to be more accurate to the true curvature of the
    % %  line without noise.
    
else  %trajectory is already resampled by arc length, so we want to use a fraction of the curve
    for a = 1+dN:length(x)-dN
        %we will try this with 5 points (2 on each side)
        par = CircleFitByPratt([x(a-dN:a+dN) y(a-dN:a+dN)]);
        %curv(a-dN) = 1/abs(par(3)*100);
        curv(a-dN) = 1/abs(par(3));
        
        if doplot > 0
            if mod(a,5) == 0
                figure(doplot)
                hold on;
                h = plot(x(a),y(a),'ro');
                set(h,'linewidth',2.0);
                th = 0:pi/50:2*pi;
                xunit = par(3) * cos(th) + par(1);
                yunit = par(3) * sin(th) + par(2);
                plot(xunit, yunit,'r-');
                %plot(x(a),y(indsam.');
                hold off;
                axis('equal');
            end
        end
        
        %we will assign a sign to the curvature; the sign is determined by
        %whether the center of the circle is to the right or left of the
        %line.  we can do this by taking the cross product of the radius of
        %the circle and the vector represnting the chord of the arc. we
        %assign the sign of the cross product to the sign curvature.
        c = cross([x(a)-par(1) y(a)-par(2) 0],[x(a+dN)-x(a-dN) y(a+dN)-y(a-dN) 0]);
        if sign(c(end)) ~= 0
            curv(a-dN) = curv(a-dN)*sign(c(end));
        end
        
    end
end
complexity.mvmtcurv = curv;
complexity.mvmt = nanmean(abs(curv));
if doplot > 0
    figure(doplot)
    set(gca,'xlim',[0.3 0.9],'ylim',[0,0.45]);
    xlims = get(gca,'xlim');
    ylims = get(gca,'ylim');
    hold on;
    text(xlims(2)-diff(xlims)*.1,ylims(2)-diff(ylims)*.1,sprintf('Mean Curv: %.2f',complexity.mvmt));
    hold off;
end



%altnernatively, we can use the method proposed by McKeague (2005) in
%   which, for an arc-length-parameterized curve, curvature is defined as:
%   k(t) = x'(t)y"(t) - x"(t)y'(t)
[complexity.arclen,complexity.seglen] = arclength(x,y);
dS = nanmean(complexity.seglen);
% xvel = gradient(x,dS);
% yvel = gradient(y,dS);
% xacc = gradient(xvel,dS);
% yacc = gradient(yvel,dS);
xvel = diffilt(dN*2+1,x,dS);
yvel = diffilt(dN*2+1,y,dS);
xacc = diffilt(dN*2+1,xvel,dS);
yacc = diffilt(dN*2+1,yvel,dS);
complexity.k = xvel.*yacc - xacc.*yvel;

% %define solution complexity, according to tpath and spath 
% solncomplexity = NaN*ones(8,8,8);
% 
% complexity.soln = solncomplexity(tgtcode,spath,tpath);

