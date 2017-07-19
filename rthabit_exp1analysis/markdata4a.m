% Place markers in data and interactively edit the markers.  Four traces
% are displayed, with marks from the changeable (second) trace also
% appearing on the other traces for alignment purposes.
%
% ind=markdata4(x,y,z,w,sssize,ind0,gridflag,Fs,'arg',param)
% x,y,z,w=data
% sssize=screen size - number of points to plot per screen
% ind0 = y; varargin: indx = x, indz = z, indw = w;
% extra parameters: 'Name', 'n1', 'idx', 'idz', 'idw'
% note that changes can only be made to the y data set markings (ind0)
% When the data and markers are displayed:
% Left mouse button = add a fast phase marker
% Right mouse button = remove a fast phase marker
% 'n' = advance to next data section
% 'x' = end
% 'r' = redraw screen (needed after several removals)
% 'g' = go to (prompts for sample number to go to)
% '1' = invert upper pannel
% '2' = invert middle pannel
% '3' = invert lower pannel
% 'u' = undo remove mark

% MS  May 1993
% Jan 1995 - changed button code for deletion from 2 to 3
% Jan 1997 - changes for MATLAB 5 (clf and colors)
% Jan 2007 - changed to single data set

function ind=markdata4(x,y,z,w,sssize,ind0,gridflag,Fs,varargin)

n1 = 1;
indx = [];
indz = [];
indw = [];

for a = 1:2:length(varargin)
    switch(lower(varargin{a}))
        case 'name'
            set(gcf,'Name',varargin{a+1})
        case 'n1'
            n1 = round(varargin{a+1}/1000)*1000+1;
        case 'indx'
            indx = varargin{a+1};
            markx = 1;
        case 'indz'
            indz = varargin{a+1};
            markz = 1;
        case 'indw'
            indw = varargin{a+1};
            markw = 1;
    end
end

ssize=sssize;
N=length(x);

%n1=1;
n2=min(N,ssize+n1-1);



ii=ind0;

kk=indx;
if isempty(kk) & ~exist('markx')
    markx = 0;
else
    markx = 1;
end

mm=indz;
if isempty(mm) & ~exist('markz')
    markz = 0;
else
    markz = 1;
end

nn=indw;
if isempty(nn) & ~exist('markw')
    markw = 0;
else
    markw = 1;
end


%figure

% plot and edit until 'x' is pressed
but='n';
while(but~='x')
    % plot position data with markers

    if(but=='n')
        clf;hold off;subplot(4,1,1)
        plot((n1:n2),x(n1:n2),'-')
        ii1=ii(1:2:length(ii));
        ii2=ii(2:2:length(ii));
        iii1=ii1(find(ii1>=n1 & ii1<=n2));
        iii2=ii2(find(ii2>=n1 & ii2<=n2));
        plot((n1:n2),x(n1:n2),'-')
        hold on
        if markx == 1
            kk1=kk(1:2:length(kk));
            kk2=kk(2:2:length(kk));
            kkk1=kk1(find(kk1>=n1 & kk1<=n2));
            kkk2=kk2(find(kk2>=n1 & kk2<=n2));
            if(~isempty(kkk1)) plot(kkk1,x(kkk1),'xr'); end
            if(~isempty(kkk2)) plot(kkk2,x(kkk2),'or'); end
        else
            if(~isempty(iii1)) plot(iii1,x(iii1),'xr'); end
            if(~isempty(iii2)) plot(iii2,x(iii2),'or'); end
        end            
        hold off;
        
        subplot(4,1,2)
        plot((n1:n2),y(n1:n2),'-')
        hold on
        if(~isempty(iii1)) plot(iii1,y(iii1),'xr'); end
        if(~isempty(iii2)) plot(iii2,y(iii2),'or'); end
        hold off;
        
        subplot(4,1,3)
        plot((n1:n2),z(n1:n2),'-')
        hold on
        if markz == 1
            mm1=mm(1:2:length(mm));
            mm2=mm(2:2:length(mm));
            mmm1=mm1(find(mm1>=n1 & mm1<=n2));
            mmm2=mm2(find(mm2>=n1 & mm2<=n2));
            if(~isempty(mmm1)) plot(mmm1,z(mmm1),'xr'); end
            if(~isempty(mmm2)) plot(mmm2,z(mmm2),'or'); end
        else
            if(~isempty(iii1)) plot(iii1,z(iii1),'xr'); end
            if(~isempty(iii2)) plot(iii2,z(iii2),'or'); end
        end            
        hold off
        
        subplot(4,1,4)
        plot((n1:n2),w(n1:n2),'-')
        hold on
        if markw == 1
            nn1=nn(1:2:length(nn));
            nn2=nn(2:2:length(nn));
            nnn1=nn1(find(nn1>=n1 & nn1<=n2));
            nnn2=nn2(find(nn2>=n1 & nn2<=n2));
            if(~isempty(nnn1)) plot(nnn1,w(nnn1),'xr'); end
            if(~isempty(nnn2)) plot(nnn2,w(nnn2),'or'); end
        else
            if(~isempty(iii1)) plot(iii1,w(iii1),'xr'); end
            if(~isempty(iii2)) plot(iii2,w(iii2),'or'); end
        end            
        hold off
       
        if(gridflag) grid; end
    end;

    % edit the indices
    [xx,~,but]=ginput(1);
    % left button - add a point
    if(but==1)
        inew=fix(xx);
        ii=[ii inew];
        ii=sort(ii);
        if markx == 0
            subplot(4,1,1); hold on ; plot(inew,x(inew),'or'); hold off;
        end
        subplot(4,1,2); hold on ; plot(inew,y(inew),'or'); hold off;
        if markz == 0
            subplot(4,1,3); hold on ; plot(inew,z(inew),'or'); hold off;
        end
        if markw == 0
            subplot(4,1,4); hold on ; plot(inew,w(inew),'or'); hold off;
        end
    end;

    % right button - delete a point
    if(but==3)
        dii=abs(ii-fix(xx));       % distances from cursor to each index
        iomit=find(dii==min(dii)); % min dist is the one to remove
        omit=ii(iomit);
        ii=[ii(1:iomit-1) ii(iomit+1:length(ii))];
        if markx == 0
            subplot(4,1,1); hold on; plot(omit,x(omit),'xw',omit,x(omit),'ow'); hold off;
        end
        subplot(4,1,2); hold on; plot(omit,y(omit),'xw',omit,y(omit),'ow'); hold off;
        if markz == 0
            subplot(4,1,3); hold on; plot(omit,z(omit),'xw',omit,z(omit),'ow'); hold off;
        end
        if markw == 0
            subplot(4,1,4); hold on; plot(omit,w(omit),'xw',omit,w(omit),'ow'); hold off;
        end
    end;

    % key 'n' - advance to next data section
    if(but=='n')
        n1=n2+1;
        if(n1>=N) n1=max(1,N-ssize); end
        n2=min(n1+ssize-1,N);
    end

    % key 'b' - back to last data section
    if(but=='b') n1=max(1,n1-ssize); n2=min(n1+ssize-1,N); but='n'; end

    % key 'r' - redraw screen
    % act as if 'n' pressed, but don't change indices
    if(but=='r') but='n'; end

    %key 'u' - undo remove mark
    if(but=='u')
        if isempty(find(ii==omit))
            ii = sort([ii omit]);
        end
        but = 'n';
    end
    
    if(but=='1')
        x = -x;
        but = 'n';
    end
    
    if(but=='2')
        y = -y;
        but = 'n';
    end
    
    if(but=='3')
        z = -z;
        but = 'n';
    end
    
    if(but=='4')
        w = -w;
        but = 'n';
    end
    

end

hold off
subplot
ind=ii;
return
