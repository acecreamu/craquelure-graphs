warning('off','all')

% load skeleton (+ original image for visualization)
list = dir('imgs/*.tif');
list2 = dir('imgs/*.jpg');
i = 1;

skel = imread([list(i).folder '\' list(i).name]);
image = imread([list2(i).folder '\' list2(i).name])/2;

if size(skel,1) > size(skel,2); skel = imrotate(skel,90); end
if size(image,1) > size(image,2); image = imrotate(image,90); end

% ########### PARAMETERS #############
order = 3;
minLenBranch = 20;
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


% display result
figure();
imshow(image);
hold on;

for i=1:length(node) 
    % draw all connections of each node
    for j=1:length(node(i).links) 
        forceLinear = 0;
        
        % define colors for links and branches 
        if(node(node(i).conn(j)).ep==1) && (node(node(i).conn(j)).bord==0)
            col='y'; % branches are yellow
        elseif (node(i).ep==1) && (node(i).bord==0)
            col='y';
        else
            col='r'; % links are red
        end

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
                if abs(max(d2(node(i).links(j)))) < 1e3
                    plot(xx+meanY,f(xx)+meanX,col,'LineWidth', 1)
                else
                    forceLinear = 1;
                end
            else
                f = fit(x', y', poly{order}, 'Weights', we');
                xx = linspace(x(1),x(end),100);
                [~,d2(node(i).links(j),:)] = differentiate(f, xx);
                if abs(max(d2(node(i).links(j)))) < 1e3
                    plot(f(xx)+meanY,xx+meanX,col,'LineWidth', 1)
                else
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
            plot(f(xx)+meanY,xx+meanX,col,'LineWidth', 1)
        end

        % to plot edges pixel-wise use
%         for k=1:length(link2(node2(i).links(j)).point)-1            
%             [x3,y3,z3]=ind2sub([w,l,h],link(node(i).links(j)).point(k));
%             [x2,y2,z2]=ind2sub([w,l,h],link(node(i).links(j)).point(k+1));
%             plot([y3 y2],[x3 x2],col,'LineWidth',1);
%         end
    end
end


% plot nodes
typeO = 0; typeY = 0; typeX = 0;

for i=1:length(node)
    if node(i).bord == 1
        continue
    elseif length(node(i).conn) == 1 
        scatter(node(i).comx,node(i).comy,40,'w', 'o', 'filled');
        typeO = typeO + 1;
    elseif length(node(i).conn) == 3
        scatter(node(i).comx,node(i).comy,40, 'w', '^', 'filled');
        typeY = typeY + 1;
    elseif length(node(i).conn) >= 4
        scatter(node(i).comx,node(i).comy,90, 'w', 'x','LineWidth',2);
        typeX = typeX + 0.5;
    end   
end
print('-r300','output1','-dtiff')

% plot triangle
addpath('alchemyst-ternplot-9c72b90');
s = typeO + typeY + typeX;
figure; 
subplot(121); 
ternplot(typeO/s, typeX/s, typeY/s, 'ro', 'majors', 0, ...
    'MarkerFaceColor','r','MarkerEdgeColor','k');
ternlabel('O', 'X', 'Y');
title('Topography');

% plot orientations
theta = [];
for k=1:length(link)   
    [x1,y1,~]=ind2sub([w,l,h],link(k).point(1));
    [x2,y2,~]=ind2sub([w,l,h],link(k).point(end));
    f = fit([y1; y2], [x1; x2], 'poly1');
    coeff =  coeffvalues(f);
    theta(k) = (atan(coeff(1)));
end
subplot(122);
hist = polarhistogram([theta theta+pi],72,'DisplayStyle','stairs');
title('Orientation');




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
set(gcf,'Position',[300 200 925 450])
uitable('Data',T{:,:},'ColumnName',fieldnames(stat),...
    'Position',[0 0 926 40], 'BackgroundColor', [0.94 0.94 0.94],...
    'ColumnWidth', {100 100 100 100 100 100 100 100 100});
print('-r300','output2','-dtiff')
