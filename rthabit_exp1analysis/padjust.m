%function to adjust the p values according to the appropriate method.  the
%  input an array of p values, and returns an array of corrected p values.
%  the default method used for correction is the step-down bonferroni-holm
%  method; other methods are available.
function p = padjust(p,varargin)

method = 'holm';

a = 1;
while a <= length(varargin)
    switch(varargin{a})
        case 'method'
            method = lower(varargin{a+1});
            a = a+2;
        otherwise
            disp('Unrecognized input to padjust');
            a = a+1;
    end
end

switch(method)
    case 'holm'  %step-down Bonferroni-Holm correction
        [sortedp, ip] = sort(p);
        for a = 1:length(sortedp)
            tmp1 = sortedp(1:a);
            tmp2 = [1:a]';
            adjustedp(a) = max(min( (length(p)-tmp2+1).*tmp1,ones(size(tmp1)) ));  
        end
        for a = 1:length(ip)
            p(ip(a)) = adjustedp(a);
        end
    case 'sidak'  %step-down Sidak correction
        [sortedp, ip] = sort(p);
        for a = 1:length(sortedp)
            tmp1 = sortedp(1:a);
            tmp2 = [1:a]';
            adjustedp(a) = max( 1-(1-tmp1).^(length(p)-tmp2+1) );  
        end
        for a = 1:length(ip)
            p(ip(a)) = adjustedp(a);
        end
    case 'bonferroni' %bonferroni correction
        p = min(p*length(p),ones(size(p)));
    case 'sidaksimple';  %simple sidak correction
        p = 1-(1-p).^length(p);
    otherwise
        disp('Requested method not currently implemented.  No p-value adjustment performed.');
end