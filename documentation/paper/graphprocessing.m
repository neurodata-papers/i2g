rootDir = '/Users/graywr1/Desktop/image2graph_v26/output';
pVal = csvread(fullfile(rootDir,'graph_metric_pvalF1.csv')); %16x100
gScore = csvread(fullfile(rootDir,'graph_metric_scoreF1.csv'));

%Cleanup
filename = fullfile(rootDir, 'seg_metrics.csv');
importSegMetrics
segErr = cell2mat(segmetrics(3,:));

filename = fullfile(rootDir,'syn_metrics.csv');
importSynMetrics
synErr = cell2mat(synmetrics(:,end-1:end));
synErr(1,1:2) = 1;

filename = fullfile(rootDir, 'edge_params.csv');
edgeParamImport

filename = fullfile(rootDir,'node_params.csv');
nodeParamImport
gScore2 = gScore;
gScore2(pVal >= 0.001) = -100;  %10^-3

[a, idx] = sort(segErr,'ascend');
gScore2b = gScore2(:,idx);
f1 = 2*(synErr(:,1).*synErr(:,2))./(synErr(:,1)+synErr(:,2));
[b, idx2] = sort(f1,'descend');
gScore2c = gScore2b(idx2,:);

figure(100), h = imagesc(gScore2c)
caxis([0,1])%000^.5])
set(gcf,'color',[1 1 1])

%%%
gScore2d = gScore2c;
mVal = max(gScore2c(:))
%gScore2d(pVal >= 0.0001) = -100;

jj = [repmat([0.6, 0.6, 0.6],1,1);jet(17000)];

% TODO TODO TODO
%gScore2d([12,5,2],:) = [];
figure, imagesc(gScore2d), colormap(jj)
caxis([-1,1])%, 'YTick', [])
lineslines
ch = colorbar; set(ch,'YTick',[])
set(gca,'XTick',[],'YTick',[])
set(gcf,'Color',[1 1 1])

gScore2e = gScore2d;

% Corr plot

[a, idx] = sort(segErr,'ascend');
gScore2f = gScore(:,idx);
f1 = 2*(synErr(:,1).*synErr(:,2))./(synErr(:,1)+synErr(:,2));
[b, idx2] = sort(f1,'descend');
gScore2f = gScore2f(idx2,:);

% TODOTODOTODO
idx = 1:size(gScore2f,1);
%idx([2,5,12]) = [];
figure(100), plot(gScore2f(idx,4),'o')
figure(101), plot(gScore2f(13,2:end),'o')


figure(100), plot(gScore2d(1,:),'o')
figure(101), plot(gScore2d(:,1),'o')

