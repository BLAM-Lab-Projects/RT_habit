% Place markers in data for 2D reaches.
% Plot data (top 3 subplots) and the 2D trace (4th subplot),
% and interactively edit the markers.
% Display different marks for both traces, although only those in the
% second pannel are changeable.
%
% ind=markdata3tp(t,x,y,z,sssize,ind0,gridflag,varargin)
% t=sampling time in msec
% x=data,plot1 (may be a matrix, with multiple data streams in columns))
% y=data,plot2
% z=data,plot3
% sssize=number of marked points to plot per screen
% ind0 corresponds to y, indx corresponds to x (may be empty array)
% extra parameters: 'Name', 'n1', 'idx', 'ylim1', 'ylim2'
% note that changes can only be made to the y data set markings (ind0)
% When the data and markers are displayed:
% Left mouse button = add a fast phase marker
% Right mouse button = remove a fast phase marker
% 'n' = advance to next data section
% 'x' = end
% 'r' = redraw screen (needed after several removals)
% '1' = invert upper pannel
% '2' = invert lower pannel
% 'u' = undo remove (last) mark
% 'h' = remove every other data point (1:2:end)
% 'v' = adVance (when having deleted a point, refresh the screen with the next set of marks

% MS  May 1993
% Jan 1995 - changed button code for deletion from 2 to 3
% Jan 1997 - changes for MATLAB 5 (clf and colors)
% Jan 2007 - changed to single data set

function ind=markdata3tp(t,x,y,z,sssize,ind0,gridflag,varargin)

omit = [];

% if nargin > 8
%     set(gcf,'Name',varargin{1})
%     if nargin > 9
%         n1 = round(varargin{2}/1000)*1000+1;
%     else
%         n1 = 1;
%     end
% end

indx = [];
indz = [];
markx = 0;
markz = 0;
ylim1 = [];
ylim2 = [];
dplot = [];
stgt = [];
impath = [];
tracenum = [];
dopaths = 0;
doputmark = 1;
reachonly = 0;
plotaxes = [0.4 0.8 0 0.4];

Fs = 1000/mean(diff(t));  %assume time in msec

for a = 1:2:length(varargin)
    switch(lower(varargin{a}))
        case 'name'
            set(gcf,'Name',varargin{a+1});
        case 'indx'
            indx = varargin{a+1};
            markx = 1;
        case 'indz'
            indz = varargin{a+1};
            markz = 1;            
        case 'ylim1'
            ylim1 = varargin{a+1};
        case 'ylim2'
            ylim2 = varargin{a+1};
        case 'dplot'
            dplot = varargin{a+1};
        case 'stgt'
            stgt = varargin{a+1};
            plotaxes = [stgt(1)-.2 stgt(1)+.2 stgt(2)-0.2 stgt(2)+0.2];
        case 'impath'
            impath = varargin{a+1};
        case 'tracenum'
            tracenum = varargin{a+1};
        case 'paths'
            dopaths = 1;
            spath = varargin{a+1}(:,1);
            tpath = varargin{a+1}(:,2);
            tgtX = varargin{a+1}(:,3);
            tgtY = varargin{a+1}(:,4);
        case 'mark'
            doputmark = varargin{a+1};
        case 'reachonly'
            reachonly = varargin{a+1};
        case 'pax'
            plotaxes = varargin{a+1};
    end
end

if size(ind0,1) > size(ind0,2)
    ind0 = ind0';
end

if size(x,2) > size(x,1)
    x = x';
end


if ~isempty(impath) && ~isempty(tracenum)
    trace = imread([impath 'Trace0.png']);  %all the traces are the same size so just pick one to get the dimensions
    trace(trace == 0) = 255;
    
    SCREEN_WIDTH = 1920;  %pixels
    PHYSICAL_WIDTH = 1.21;  %meters
    PHYSICAL_RATIO = (PHYSICAL_WIDTH / SCREEN_WIDTH);
    
    imax = size(trace) * PHYSICAL_RATIO;
    %imax = [0 imax(1); 0 imax(2)];
    if ~isempty(stgt)
        imax = [stgt(1)-imax(1)/2 stgt(1)+imax(1)/2;
                stgt(2)-imax(2)/2 stgt(2)+imax(2)/2];
        
        %imax = [imax(1,1)+stgt(1) imax(1,2)+stgt(1);
        %        imax(2,1)+stgt(2) imax(2,2)+stgt(2)];
    end
    
    tracenum = double(tracenum);
    
    tracenum(tracenum == -1) = NaN;
    
    dotrace = 1;
else
    dotrace = 0;
    
end

if dopaths > 0
    pathpath = 'C:\Users\Aaron\Documents\kinereach\kinereach code\trtraj_v1\Resources\paths\allpaths\';
    for a = 0:7
        tmpstr = ['Path' num2str(a) '.txt'];
        fid = fopen([pathpath tmpstr]);
        fgetl(fid);
        Path(a+1).lineWidth = str2num(fgetl(fid));
        
        Path(a+1).Vertices = textscan(fid,'%f',inf);
        Path(a+1).Vertices = Path(a+1).Vertices{1};
        Path(a+1).Vertices = reshape(Path(a+1).Vertices',6,[])';
        
        Path(a+1).verts = [Path(a+1).Vertices(:,1); Path(a+1).Vertices(end,3)];
        Path(a+1).verts(:,2) = [Path(a+1).Vertices(:,2); Path(a+1).Vertices(end,4)];
        
        fclose(fid);
    end
    
    spath(spath<0) = NaN;
    tpath(tpath<0) = NaN;
end



ssize=sssize*2; %2 indices = 1 reach; input is in terms of number of reaches
N=size(x,1);
xdats = size(x,2);

ipts = 1;  %index of the first point of the group shown
if isempty(dplot)
    dplot = 70;  %number of samples to plot before and after the region of interest
end

if ~isempty(ind0)
    n1=max(1,ind0(1)-dplot);
    n2=min(N,ind0(min(ssize,length(ind0)))+dplot);
else
    n1 = 1;
    n2 = min(N,1000);
end

ii=ind0;
kk=indx;
mm = indz;

% if isempty(kk) & ~exist('markx')
%     markx = 0;
% else
%     markx = 1;
% end
% 



%figure

% plot and edit until 'x' is pressed
but='n';
while(but~='x')
    % plot position data with markers

    if(but=='n')
        ii1=ii(1:2:length(ii));
        ii2=ii(2:2:length(ii));
        iii1=ii1(find(ii1>=n1 & ii1<=n2));
        iii2=ii2(find(ii2>=n1 & ii2<=n2));
        if (ipts < length(ii))
            iii1(iii1<ii(ipts)) = [];
            iii2(iii2<ii(ipts)) = [];
        end
        %iii2 = ii(ipts:ipts+ssize/2-1);
        
        %iii1 = iii1(1:ssize/2);
        %iii2 = iii2(1:ssize/2);
       
        clf;hold off;
        ax1 = subplot(4,1,1);
        hold on;
        for a = 1:xdats
            %disp([n1 n2]);
            plot((n1:n2),x(n1:n2,a),'-');
        end
        axlim = axis;
        axis([n1 n2 axlim(3) axlim(4)]);
        xlim = get(gca,'xlim');
        ylim = get(gca,'ylim');
        dtx = diff(xlim)/500;
        dty = diff(ylim)/500*10;
        if markx == 1
            kk1=kk(1:2:length(kk));
            kk2=kk(2:2:length(kk));
            kkk1=kk1(find(kk1>=n1 & kk1<=n2));
            kkk2=kk2(find(kk2>=n1 & kk2<=n2));

            if(~isempty(kkk1))
                for a = 1:xdats
                    plot(kkk1,x(kkk1,a),'xr'); 
                end
            end
            if(~isempty(kkk2))
                for a = 1:xdats
                    plot(kkk2,x(kkk2,a),'or'); 
                end
            end
            %text(sort([kkk1 kkk2])+dtx,x(sort([kkk1 kkk2]))+dty,num2cell([1:length(sort([kkk1 kkk2]))])); 
            for a = 1:xdats
                text(kkk1'+dtx,x(kkk1,a)+dty,num2cell([1:length(kkk1)]));
                text(kkk2'+dtx,x(kkk2,a)-dty,num2cell([1:length(kkk2)]));
            end
        else
            if(~isempty(iii1))
                for a = 1:xdats
                    plot(iii1,x(iii1,a),'xr'); 
                end
            end
            if(~isempty(iii2)) 
                for a = 1:xdats
                    plot(iii2,x(iii2,a),'or'); 
                end
            end
            %text(sort([iii1 iii2])'+dtx,x(sort([iii1 iii2]))+dty,num2cell([1:length(sort([iii1 iii2]))])); 
            for a = 1:xdats
                text(iii1'+dtx,x(iii1,a)+dty,num2cell([1:length(iii1)]));
                text(iii2'+dtx,x(iii2,a)-dty,num2cell([1:length(iii2)]));
            end
        end
        if(~isempty(ylim1)) set(gca,'Ylim',ylim1); end
        hold off;

        ax2 = subplot(4,1,2);
        plot((n1:n2),y(n1:n2),'-')
        axlim = axis;
        axis([n1 n2 axlim(3) axlim(4)]);
        xlim = get(gca,'xlim');
        ylim = get(gca,'ylim');
        dtx = diff(xlim)/500;
        dty = diff(ylim)/500*10;
        hold on
        if(~isempty(iii1)) plot(iii1,y(iii1),'xr'); end
        if(~isempty(iii2)) plot(iii2,y(iii2),'or'); end
        %text(sort([iii1 iii2])+dtx,y(sort([iii1 iii2]))+dty,num2cell([1:length(sort([iii1 iii2]))])); 
        text(iii1'+dtx,y(iii1)+dty,num2cell([1:length(iii1)]));
        text(iii2'+dtx,y(iii2)-dty,num2cell([1:length(iii2)]));
        hold off
        if(gridflag) grid; end
        if(~isempty(ylim2)) set(gca,'Ylim',ylim2); end            
        hold off;

        
        ax3 = subplot(4,1,3);
        plot((n1:n2),z(n1:n2),'-');
        axlim = axis;
        axis([n1 n2 axlim(3) axlim(4)]);
        xlim = get(gca,'xlim');
        ylim = get(gca,'ylim');
        dtx = diff(xlim)/500;
        dty = diff(ylim)/500*10;
        hold on;
        if markz == 1
            mm1=mm(1:2:length(mm));
            mm2=mm(2:2:length(mm));
            mmm1=mm1(find(mm1>=n1 & mm1<=n2));
            mmm2=mm2(find(mm2>=n1 & mm2<=n2));

            if(~isempty(mmm1))
                plot(mmm1,z(mmm1),'xr');
            end
            if(~isempty(mmm2))
                plot(mmm2,z(mmm2),'or');
            end
            %text(sort([kkk1 kkk2])+dtx,x(sort([kkk1 kkk2]))+dty,num2cell([1:length(sort([kkk1 kkk2]))])); 
            text(mmm1'+dtx,z(mmm1)+dty,num2cell([1:length(mmm1)]));
            text(mmm2'+dtx,z(mmm2)-dty,num2cell([1:length(mmm2)]));
        else
            if(~isempty(iii1))
                plot(iii1,z(iii1),'xr');
            end
            if(~isempty(iii2)) 
                plot(iii2,z(iii2),'or');
            end
            %text(sort([iii1 iii2])'+dtx,x(sort([iii1 iii2]))+dty,num2cell([1:length(sort([iii1 iii2]))])); 
            text(iii1'+dtx,z(iii1)+dty,num2cell([1:length(iii1)]));
            text(iii2'+dtx,z(iii2)-dty,num2cell([1:length(iii2)]));
        end
        if(~isempty(ylim1)) set(gca,'Ylim',ylim1); end
        hold off;
        
        ax4 = subplot(4,1,4);
        
        axis equal;
        axis(plotaxes);
        hold on;
        
        if (dotrace == 1)
            
            %trnum = max(double(tracenum(iii1:iii2)));
            trnum = mode(double(tracenum(n1:n2)));
            if ~isempty(trnum) && trnum >= 0 %&& trnum <= 128
                
                trace = imread([impath 'Trace' num2str(trnum) '.png']);  %all the traces are the same size so just pick one to get the dimensions
                trace(trace == 0) = 255;
                
                %this must be flipped up-down because imshow reverses the
                %axis!
                trace(:,:,1) = flipud(trace(:,:,1));
                trace(:,:,2) = flipud(trace(:,:,2));
                trace(:,:,3) = flipud(trace(:,:,3));
                
                imshow(trace,'Xdata',imax(1,:),'Ydata',imax(2,:));
                set(gca, 'YDir', 'normal')
                %subimage(trace,'Xdata',imax(1,:),'Ydata',imax(2,:));
                
                %disp(['Trace' num2str(max(double(tracenum(n1:n2)))) ]);
                
                
                
                hold on;
            end
            plot(y(iii1:iii2),z(iii1:iii2),'-');  %plot only the marked reach
            
        elseif dopaths > 0
            %[n1 n2]
            spathn = abs(mode(double(spath(n1:n2))));
            tpathn = abs(mode(double(tpath(n1:n2))));
            %tpathn
            
            tgtxn = double(tgtX(n1:n2));
            %tgtxn(abs(tgtxn-stgt(1))<0.0001) = [];
            tgtxn(abs(tgtxn)<0.0001) = [];
            tgtyn = double(tgtY(n1:n2));
            %tgtyn(abs(tgtyn-stgt(2))<0.0001) = [];
            tgtyn(abs(tgtyn)<0.0001) = [];
            
            tgtxn = mode(tgtxn);
            tgtyn = mode(tgtyn);

            %[iii1 iii2]
            %[spathn tpathn tgtxn tgtyn]
            
            hold on;
            
            if ~isnan(spathn)
                plot(Path(spathn+1).verts(:,1)+stgt(1),Path(spathn+1).verts(:,2)+stgt(2),'k-');
            end
            plot(Path(tpathn+1).verts(:,1)+tgtxn,Path(tpathn+1).verts(:,2)+tgtyn,'k-');
            
            plot(y(iii1:iii2),z(iii1:iii2),'-');  %plot only the marked reach
            hold off;
        elseif reachonly == 1
            plot(y(iii1:iii2),z(iii1:iii2),'-');  %plot only the marked reach
        else %do not display trace and plot the entire displayed data stream -- this is the original 
            plot(y(n1:n2),z(n1:n2),'-');        
        end
        
        
        %plot(y(iii1:iii2),z(iii1:iii2),'-');
        %axis equal;
        %axis([0.4 0.8 0 0.4]);
        xlim = get(gca,'xlim');
        ylim = get(gca,'ylim');
        dtx = diff(xlim)/500;
        dty = diff(ylim)/500*10;
        hold on
        if(~isempty(iii1)) plot(y(iii1),z(iii1),'xr'); end
        if(~isempty(iii2)) plot(y(iii2),z(iii2),'or'); end
        %text(x(sort([iii1 iii2]))+dtx,y(sort([iii1 iii2]))+dty,num2cell([1:length(sort([iii1 iii2]))])); 
        text(y(iii1)+dtx,z(iii1)+dty,num2cell([1:length(iii1)]));
        text(y(iii2)+dtx,z(iii2)-dty,num2cell([1:length(iii2)]));
        if ~isempty(stgt)
            plot(stgt(1),stgt(2),'go');
        end
        hold off
        if(gridflag) grid; end
        hold off;
        
    end;
    
    % edit the indices
    [xx,~,but]=ginput(1);
    curax = gca;
%     if curax == ax3
%         but = 'n';
%     end
%     else
        
        % left button - add a point
        if(but==1 && doputmark)
            if curax ~= ax4
                inew=fix(xx);
                if inew <= 0
                    %inew = 1;
                    inew = [];
                elseif inew > length(x)
                    %inew = length(x);
                    inew = [];
                end
                
                ii=sort([ii inew]);
            end
            %         if markx == 0
            %             subplot(2,1,1); hold on ; plot(inew,x(inew),'or'); hold off;
            %         end
            %         subplot(2,1,2); hold on ; plot(inew,y(inew),'or'); hold off;
            but = 'r';
        end;
        
        
        % right button - delete a point
        if(but==3)
            if xx > 1 && xx < length(x) && curax ~= ax4
                dii=abs(ii-fix(xx));       % distances from cursor to each index
                iomit=find(dii==min(dii)); % min dist is the one to remove
                omit=ii(iomit);
                %ii=[ii(1:iomit-1) ii(iomit+1:length(ii))];
                ii(iomit) = [];
            end
            %         if markx == 0
            %             subplot(2,1,1); hold on; plot(omit,x(omit),'xw',omit,x(omit),'ow'); hold off;
            %         end
            %         subplot(2,1,2); hold on; plot(omit,y(omit),'xw',omit,y(omit),'ow'); hold off;
            but = 'r';
        end;
%     end

    % key 'n' - advance to next data section
    if(but=='n')
        %n1=n2+1;
        %if(n1>=N) n1=N-ssize; end
        %n2=min(n1+ssize-1,N);
        ipts = ipts+ssize;
        if ipts+ssize > length(ii)
            ipts = max(1,length(ii)-ssize+1);
        end
        n1 = ii(ipts)-dplot;
        if n1 < 1
            n1 = 1;
        end
        
        n2 = ii(min(length(ii),ipts+ssize-1))+dplot;
        if n2 > N
            n2 = N;
        end
        if n1 >= n2
            n1 = n2-dplot*2;
        end
        
        %disp([n1 n2]);
    end

    % key 'b' - back to last data section
    if(but=='b') 
        %n1=max(1,n1-ssize); 
        %n2=min(n1+ssize-1,N); 
        ipts = ipts - ssize;
        if ipts <= 0
            ipts = 1;
        end
        
        n1 = ii(ipts)-dplot;
        if n1 < 1
            n1 = 1;
        end
        
        n2 = ii(min(length(ii),ipts+ssize-1))+dplot;
        if n2 > N
            n2 = N;
        end

        but='n'; 
    end
    
    %adVance the screen (equal to a 'b' + 'n')
    if(but == 'v')
        if ipts > length(ii)
            ipts = length(ii)-ssize+1;
        end
        n1 = ii(ipts)-dplot;
        if n1 < 1
            n1 = 1;
        end
        
        n2 = ii(min(length(ii),ipts+ssize-1))+dplot;
        if n2 > N
            n2 = N;
        end
        
        but='n'; 
    end

   
    % key 'r' - redraw screen
    % act as if 'n' pressed, but don't change indices
    if(but=='r') 
        but='n'; 
    end

    
    %key 'u' - undo remove mark
    if(but=='u')
        if ~isempty(omit) && isempty(find(ii==omit))
            ii = sort([ii omit]);
        end
        but = 'n';
    end
    
    if(but=='h')
        ii = ii(1:2:end);
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
    
    
    if (but=='e')
        ipts = length(ii)-ssize+1;
        n1 = ii(end-ssize+1)-dplot;
        if n1 < 1
            n1 = 1;
        end
        
        n2 = ii(end)+dplot;
        if n2 > N
            n2 = N;
        end

        but='n'; 
    end
    
    if (but=='s')
        ipts = 1;
        n1 = ii(1)-dplot;
        if n1 < 1
            n1 = 1;
        end
        
        n2 = ii(ssize)+dplot;
        if n2 > N
            n2 = N;
        end

        but='n'; 
    end
    
end

hold off
%subplot
ind=ii;
return
