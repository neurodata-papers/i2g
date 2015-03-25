function edgeList = synapse_neuron_association_volume_upload(neuToken, neuLocation, synToken, synLocation, resolution, queryFile, useSemaphore)

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

disp('with new edits 2')
load(queryFile)


if useSemaphore == 1
    ocpS = OCP('semaphore');
    ocpN = OCP('semaphore');
else
    ocpS = OCP();
    ocpN = OCP();
end

ocpS.setServerLocation(synLocation);
ocpS.setAnnoToken(synToken);
ocpS.setDefaultResolution(resolution);

ocpN.setServerLocation(neuLocation);
ocpN.setAnnoToken(neuToken);
ocpN.setDefaultResolution(resolution);

query.setType(eOCPQueryType.annoDense);

% Need to download each cube
tic
sMtxCube = ocpS.query(query);

nMtxCube = ocpN.query(query);
toc


synDil = 5;

% This isn't scalable, but is much faster

sMtx = imdilate(sMtxCube.data,strel('disk',synDil));
uid = unique(sMtxCube.data);

% Any pixels that are not in the original set get removed
% Any original pixels that got overwritten are restored
sMtx(~ismember(sMtx,uid)) = 0;
sMtx(sMtxCube.data > 0) = sMtxCube.data(sMtxCube.data  >0);

% Clip boundaries
bSyn = [unique(sMtx(:,:,1)), unique(sMtx(:,:,end)), unique(sMtx(:,1,:)), ...
    unique(sMtx(:,end,:)), unique(sMtx(1,:,:)), unique(sMtx(end,:,:))];

bSyn = unique(bSyn);

uid = unique(sMtx); %all IDs

% remove unique IDs that are on borders
uid(ismember(uid,bSyn)) = [];

rp = regionprops(sMtx,'PixelIdxList','Area');
edgeList = double(zeros(length(rp),5));

q = OCPQuery;
q.setType(eOCPQueryType.RAMONMetaOnly);

for i = 1:uid %uid%length(rp) TODO: can clean this up to be more efficient
    if rp(uid(i)).Area > 0
        q.setId(uid(i));
        ss = ocpS.query(q);
        if length(cell2mat(ss{i}.segments.keys)) == 0 % not yet processed
        % Find overlaps x2
        sId = nMtxCube.data(rp(uid(i)).PixelIdxList);
        sId(sId == 0) = [];
        sp1 = mode(sId);
        sId(sId == sp1) = [];
        sp2 = mode(sId);
        
        % Skipping direction
        direction = 0;
        synDatabaseId = double(uid(i));     
        
        ss.addSegment(sp1,eRAMONFlowDirection.unknown)
        ss.addSegment(sp2,eRAMONFlowDirection.unknown)
    end
    end
end