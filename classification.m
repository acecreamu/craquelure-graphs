list = dir('imgs2/*.tif');

n = 10;
a = 800;


rng('default')

for i = 1:length(list) 
    % read image
    skel = imread([list(i).folder '\' list(i).name]);
    
    for j = 1:n
        % crop n patches
        colLim = size(skel,2) - a;
        rowLim = size(skel,1) - a;
        c = ceil(rand * colLim);
        r = ceil(rand * rowLim);
        patch = skel(r:r+a-1, c:c+a-1, :);
        
        if round(rand)
            patch = flip(patch, 1);
        end
        
        if round(rand)
            patch = flip(patch, 2);
        end
        
        % extract features from each patch
        [T,~] = extractStats(patch);
        stats((i-1)*n+j,:) = table2array(T);
    end
    
end

%% Combine features?

% load pre-computed
load('stats.mat');
load('graph-features-263.mat');

% concatenation
statsAndFeatures = [stats features];


% specify the features to use further
% either {statsAndFeatures} or just {stats} or just {features} 
data = statsAndFeatures; 

%% Visualize PCA
labels = [repmat([0.2 0.6 0.6],8*n,1) 
    repmat([0.4 0.6 0.1],9*n,1)
    repmat([0.6 0.1 0.6],6*n,1)
    repmat([0.8 0.1 0.1],5*n,1)
    repmat([1.0 0.8 0.8],8*n,1)];

[coeff,score,latent,tsquared,explained] = pca(data);

figure;
scatter(score(:,1),score(:,2),50,labels, 'filled')

%% Clissify SVM + 10-fold CV

rng('default')
labelsC = labels(:,1);
labelsC = categorical(labelsC, [0.2 0.4 0.6 0.8 1], {'DU' 'FL' 'FR' 'GE' 'IT'});

svm = templateSVM('KernelFunction','linear','Standardize', true);
Mdl = fitcecoc(data, labelsC, 'Learners', svm, ...
    'ClassNames',{'DU', 'FL', 'FR', 'GE', 'IT'});

cvMdl = crossval(Mdl,'kfold',10);
error = kfoldLoss(cvMdl)
preds = categorical(kfoldPredict(cvMdl));
ConfMat = confusionmat(labelsC,preds);
plotConfMat(ConfMat, {'DU', 'FL', 'FR', 'GE', 'IT'})







%% for visualization

function plotConfMat(varargin)
% CREDITS: https://github.com/vtshitoyan/plotConfMat
%PLOTCONFMAT plots the confusion matrix with colorscale, absolute numbers
%   and precision normalized percentages
%
%   usage: 
%   PLOTCONFMAT(confmat) plots the confmat with integers 1 to n as class labels
%   PLOTCONFMAT(confmat, labels) plots the confmat with the specified labels
%
%   Vahe Tshitoyan
%   20/08/2017
%
%   Arguments
%   confmat:            a square confusion matrix
%   labels (optional):  vector of class labels

% number of arguments
switch (nargin)
    case 0
       confmat = 1;
       labels = {'1'};
    case 1
       confmat = varargin{1};
       labels = 1:size(confmat, 1);
    otherwise
       confmat = varargin{1};
       labels = varargin{2};
end

confmat(isnan(confmat))=0; % in case there are NaN elements
numlabels = size(confmat, 1); % number of labels

% calculate the percentage accuracies
confpercent = 100*confmat./repmat(sum(confmat, 1),numlabels,1);

% plotting the colors
figure;
imagesc(confpercent);
title(sprintf('Accuracy: %.2f%%', 100*trace(confmat)/sum(confmat(:))));
ylabel('Output Class'); xlabel('Target Class');

% set the colormap
colormap(flipud(gray));

% Create strings from the matrix values and remove spaces
textStrings = num2str([confpercent(:), confmat(:)], '%.1f%%\n%d\n');
textStrings = strtrim(cellstr(textStrings));

% Create x and y coordinates for the strings and plot them
[x,y] = meshgrid(1:numlabels);
hStrings = text(x(:),y(:),textStrings(:), ...
    'HorizontalAlignment','center');

% Get the middle value of the color range
midValue = mean(get(gca,'CLim'));

% Choose white or black for the text color of the strings so
% they can be easily seen over the background color
textColors = repmat(confpercent(:) > midValue,1,3);
set(hStrings,{'Color'},num2cell(textColors,2));

% Setting the axis labels
set(gca,'XTick',1:numlabels,...
    'XTickLabel',labels,...
    'YTick',1:numlabels,...
    'YTickLabel',labels,...
    'TickLength',[0 0]);
end