function gErr = compute_graph_error(lgTest, lgTruth)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) [2014] The Johns Hopkins University / Applied Physics Laboratory All Rights Reserved. Contact the JHU/APL Office of Technology Transfer for any additional rights.  www.jhuapl.edu/ott
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lgTruthF = matrixFull(lgTruth);
lgTestF = matrixFull(lgTest);

%using binary undirected graphs, no self loops for now TODO
lgTruthFB = uint8(lgTruthF > 0);
lgTestFB = uint8(lgTestF > 0);

gErr.scoreFrob = norm(single(lgTruthFB-lgTestFB),'fro');%  sum(sum(abs(logical(lgTruth)-logical(lgTest))));

%mtxDiff = lgTruthFB - lgTestFB;

% for i = 1:size(mtxDiff,1)
%     for j = 1:size(mtxDiff,2)
%         if i >= j
%             mtxDiff(i,j) = NaN;
%         end
%     end
% end
%nel = size(mtxDiff,1);

gErr.TP = sum(sum(lgTestFB == 1 & lgTruthFB == 1));
gErr.FP = sum(sum(lgTestFB == 1 & lgTruthFB == 0));
gErr.FN = sum(sum(lgTestFB == 0 & lgTruthFB == 1));
gErr.TN = sum(sum(lgTestFB == 0 & lgTruthFB == 0));
gErr.sum = gErr.FP + gErr.FN + gErr.TN + gErr.TP;
gErr.connFound = sum(lgTestFB(:));
gErr.connTrue = sum(lgTruthFB(:));
gErr.nSynapse = length(lgTest); %fixed
gErr.avgSynDegreeTest = mean(sum(lgTestF,2));
gErr.avgSynDegreeTruth = mean(sum(lgTruthF,2));
gErr.prec = gErr.TP/(gErr.TP + gErr.FP);
gErr.rec = gErr.TP/(gErr.TP + gErr.FN);
gErr.scoreF1 = 2 * (gErr.prec * gErr.rec) / (gErr.prec + gErr.rec);

FPR = gErr.FP/(gErr.FP+gErr.TN);
FNR = gErr.FN/(gErr.FN+gErr.TP);

gErr.micro = (FPR+FNR)/2;

%% PERMUTATION TEST

nIter = 10000;

nEntry = find(lgTest > 0);

ss = size(lgTest);
q = ones(size(lgTest));
q = triu(q,1);

idx = find(q > 0);

tic
for i = 1:nIter
    chooseIdx = idx(randperm(length(idx)));
    
    ptest = zeros(size(lgTest));
    ptest(chooseIdx(1:length(nEntry))) = 1;
    ptest = matrixFull(ptest);
    pscoreFrob(i) = norm(single(lgTruthFB-lgTestFB),'fro');
    
    TP = sum(ptest == 1 & lgTruthFB == 1);
    FP = sum(ptest == 1 & lgTruthFB == 0);
    FN = sum(ptest == 0 & lgTruthFB == 1);
    prec = TP/(TP + FP);
    rec = TP/(TP + FN);
    pscoreF1(i) =  2 * (prec * rec) / (prec + rec);
 end

toc

gErr.pvalFrob = sum(gErr.scoreFrob > pscoreFrob)/nIter;
gErr.pvalF1 = sum(gErr.scoreF1 < pscoreF1)/nIter;  % Here the numbers go the other way




