rootDir = '/Users/graywr1/code/image2graph_v29/output';
pVal = csvread(fullfile(rootDir,'graph_metric_pvalF1.csv')); %16x100
gScore = csvread(fullfile(rootDir,'graph_metric_scoreF1.csv'));
prec = csvread(fullfile(rootDir,'graph_metric_prec.csv'));
rec = csvread(fullfile(rootDir,'graph_metric_rec.csv'));

%Cleanup
filename = fullfile(rootDir, 'seg_metrics.csv');
segErr = segmetrics_import(filename);
segErr = segErr(3,:);
filename = fullfile(rootDir,'syn_metrics.csv');

synErr = synmetrics_import(filename);
synErr(1,end-1:end) = 1;
synErr = synErr(:,end-1:end);




filename = fullfile(rootDir, 'edge_params.csv');
edgeParamImport %TODO - hardcoded

filename = fullfile(rootDir,'node_params.csv');
nodeParamImport %TODO - hardcoded
gScore2 = gScore;
gScore2(pVal >= 0.001) = -1;  %10^-3

[a, idx] = sort(segErr,'ascend');
gScore2b = gScore2(:,idx);
f1 = 2*(synErr(:,1).*synErr(:,2))./(synErr(:,1)+synErr(:,2));
[b, idx2] = sort(f1,'descend');
gScore2c = gScore2b(idx2,:);

figure(100), h = imagesc(gScore2c)
caxis([0,0.3])%000^.5])
set(gcf,'color',[1 1 1])

%%
gScore2d = gScore2c;
mVal = max(gScore2c(:))
%gScore2d(pVal >= 0.0001) = -100;

jj = [repmat([0.6, 0.6, 0.6],1,1);jet(100)];

% TODO TODO TODO
%gScore2d([12,5,2],:) = [];
figure, imagesc(gScore2d), colormap(jj)
caxis([0,0.3])%, 'YTick', [])
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
%idx = 1:size(gScore2f,1);
%idx([2,5,12]) = [];
figure(100), plot(gScore2f(2:end,76),'o')
figure(101), plot(gScore2f(2,2:end),'o')


% figure(100), plot(gScore2d(1,:),'o')
% figure(101), plot(gScore2d(:,1),'o')

