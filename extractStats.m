function [T, link, node] = extractStats(skel)
warning('off','all')

% ########### PARAMETERS #############
order = 3;
minLenBranch = 14;
minLenFit = 10;
borderDist = 20;
minLenYY = 6;

% order        - order of a polynomial used for fitting 
% minLenBranch - threshold for discarding skeletonization artifacts, 
%                branches of smaller length will not be considered
% minLenFit    - threshold on the length of edges which will be fitted
%                (linear fit is sufficient for very short edges, general 
%                principle: the higher threshold - the less problems)
% borderDis t  - branches on the border of images are just cropped links, 
%                use this parameter to discard false branches on border
% minLenYY     - in most of the cases X-junctions will be presented as
%                two close Y's, use this to join Y-Y with small distance

% #####################################

poly = {'poly1','poly2','poly3','poly4','poly5'};
[w, l, h] = size(skel);
addpath('skel2graph-Philip-Kollmannsberger');

% graph extraction
[~,node1,link1] = Skel2Graph(skel,minLenBranch, borderDist);
wl = sum(cellfun('length',{node1.links}));

skel1 = Graph2Skel(node1,link1,w,l,h);
[~,node,link] = Skel2Graph(skel1,minLenBranch, borderDist);
wl_new = sum(cellfun('length',{node.links}));

while(wl_new ~= wl)
    wl = wl_new;   
    skel1 = Graph2Skel(node,link,w,l,h);
    [~,node,link] = Skel2Graph(skel1,minLenBranch, borderDist);
    wl_new = sum(cellfun('length',{node.links}));
end

% join too close Y-Y in one X
[link, node] = YY2X(link, node, minLenYY);




for i=1:length(node) 
    for j=1:length(node(i).links)    
        forceLinear = 0;

        
        % plot graph edges
        x = [];
        y = [];
        for k=1:length(link(node(i).links(j)).point)-1   
            [x(k),y(k),z]=ind2sub([w,l,h],link(node(i).links(j)).point(k));
        end
        we = [1e3 ones(1,length(y)-2) 1e3];
        % normalize
        meanX = mean([node(i).comx node(node(i).conn(j)).comx]);
        meanY = mean([node(i).comy node(node(i).conn(j)).comy]);
        x = x - meanX;
        y = y - meanY;

        if length(y) > minLenFit
            % if edge is horizontal - fit y, vertical - fit x
            if abs(y(end)-y(1)) > abs(x(end) - x(1))
                f = fit(y', x', poly{order}, 'Weights', we');
                xx = linspace(y(1),y(end),100);
                [~,d2(node(i).links(j),:)] = differentiate(f, xx);
                if abs(max(d2(node(i).links(j)))) > 1e3
                    forceLinear = 1;
                end
            else
                f = fit(x', y', poly{order}, 'Weights', we');
                xx = linspace(x(1),x(end),100);
                [~,d2(node(i).links(j),:)] = differentiate(f, xx);
                if abs(max(d2(node(i).links(j)))) > 1e3
                    forceLinear = 1;
                end
            end
            % if needed:
            % coeff(node(i).links(j),:) = coeffvalues(f);
        else
            forceLinear = 1;
        end
        
        if forceLinear
            f = fit(x', y', poly{1}, 'Weights', we');
            xx = linspace(x(1),x(end),100);
            d2(node(i).links(j),:) = zeros(1,100);
        end
            
    end
end


% plot nodes
typeO = 0; typeY = 0; typeX = 0;

for i=1:length(node)
    if node(i).bord == 1
        continue
    elseif length(node(i).conn) == 1 
        typeO = typeO + 1;
    elseif length(node(i).conn) == 3
        typeY = typeY + 1;
    elseif length(node(i).conn) >= 4
        typeX = typeX + 0.5;
    end   
end
s = typeO + typeY + typeX;

% plot orientations
theta = [];
for k=1:length(link)   
    [x1,y1,~]=ind2sub([w,l,h],link(k).point(1));
    [x2,y2,~]=ind2sub([w,l,h],link(k).point(end));
    f = fit([y1; y2], [x1; x2], 'poly1');
    coeff =  coeffvalues(f);
    theta(k) = (atan(coeff(1)));
end
hist = polarhistogram([theta theta+pi],72,'DisplayStyle','stairs');





% statistics
stat.orientUniformity = std(hist.BinCounts);
stat.lengthMean = mean(cellfun('length',{link.point}));
stat.lengthStd = std(cellfun('length',{link.point}));
stat.ratioEdges2Junc = length(link)/(typeY + typeX);
stat.nodesDensity = s/w/l;
stat.partTypeO = typeO/s;
stat.partTypeY = typeY/s;
stat.partTypeX = typeX/s;
stat.curvatureD2 = mean(abs(d2(:)));

T = struct2table(stat);
