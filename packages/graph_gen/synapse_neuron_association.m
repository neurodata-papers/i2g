function edgeList = synapse_neuron_association(neuToken, neuLocation, synToken, synLocation, synIdList, resolution, uploadFlag, useSemaphore, varargin)

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

error('Reworking file for hardcoding')
edgeList = int32([]);

synDil = 9;
method = 2;

f = OCPFields;

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


if isempty(synIdList)
    q1 = OCPQuery(eOCPQueryType.RAMONIdList);
    q1.setResolution(resolution);
    
    q1.addIdListPredicate(eOCPPredicate.type, eRAMONAnnoType.synapse);
    synIdList = ocpS.query(q1);
end

%%

if method == 1
    
    for i = 1:length(synIdList)
        fprintf('Now processing synapse %d of %d...\n', i,length(synIdList))
        qs = OCPQuery(eOCPQueryType.RAMONDense,synIdList(i));
        qs.setResolution(resolution);
        ss = ocpS.query(qs);
        %ocpN.getAnnoToken
        q = getOCPAnnoQuery(ss,'annoDense');
        
        nn = ocpN.query(q);
        
        sVal = imdilate(ss.data,strel('disk',5));
        
        sId = nn.data(sVal>0);
        
        sId = unique(sId);
        %        sId = unique(labelIn(rp(i).PixelIdxList));
        sId(sId == 0) = [];
        
        sp1 = mode(sId);
        sp1 = sp1(1);
        
        sId(sId == sp1) = [];
        
        sp2 = mode(sId);
        sp2 = sp2(1);
        
        % Skipping direction
        direction = 0;
        
        if isempty(ss.seeds | ss.seeds == 0)
            parentSyn = -1 * synIdList(i);
        else
            parentSyn = ss.seeds;
        end
        
        edgeList(i,:) = [sp1; sp2; synIdList(i); direction; parentSyn]; %NaNs if empty ?
        
        %% Do upload
        if uploadFlag
            try
                if ~isnan(sp1)
                    segsyn1 = ocpN.getField(sp1, f.segment.synapses);
                    ocpN.setField(sp1, f.segment.synapses, [segsyn1, synIdList(i)]);
                    %TODO
                    ss.addSegment(sp1,eRAMONFlowDirection.unknown);
                end
                
                if ~isnan(sp2)
                    segsyn2 = ocpN.getField(sp2, f.segment.synapses);
                    ocpN.setField(sp2, f.segment.synapses, [segsyn2, synIdList(i)]);
                    ss.addSegment(sp2,eRAMONFlowDirection.unknown);
                end
                
                ss.setCutout([]); %Test to speed upload
                ocpS.updateAnnotation(ss);
            catch
                disp('problem uploading edge metadata')
            end
        else disp('skipping upload...')
        end
    end
elseif method == 2
    % This isn't scalable, but is much faster
    f = OCPFields;
    
        ocpSF = OCP(); %No Semaphore...
ocpSF.setServerLocation(synLocation);
ocpSF.setAnnoToken(synToken);
ocpSF.setDefaultResolution(resolution);


    % Hardcoded for now - can pass in query file
    q = OCPQuery;
    q.setType(eOCPQueryType.annoDense);
    q.setCutoutArgs([4400,5424],[5440,6464],[1100,1200],1);
    
    % Need to download each cube
    tic
    sMtxCube = ocpS.query(q);
    
    ocpS.setAnnoToken('cshl_baseline_ac4_synapse_truth');
    sMtxTruth = ocpS.query(q);
    
    nMtxCube = ocpN.query(q);
    t = toc
    
    uid = unique(sMtxCube.data); %all IDs
    sMtx = imdilate(sMtxCube.data,strel('disk',5));
    
    % Any pixels that are not in the original set get removed
    % Any original pixels that got overwritten are restored
    sMtx(~ismember(sMtx,uid)) = 0;
    sMtx(sMtxCube.data > 0) = sMtxCube.data(sMtxCube.data  >0);
    
    % relabel
    [sMtx2, n] = relabel_id(sMtx);
    
    uidNew = unique(sMtx2);
    
    %uid and uidNew form the lookup table
    
    rp = regionprops(sMtx2,'PixelIdxList');
    
    for i = 1:length(rp)
        % Find overlaps x2
        
        sId = nMtxCube.data(rp(i).PixelIdxList);
        sId = unique(sId);
        
        sId(sId == 0) = [];
        
        sp1 = mode(sId);
        sp1 = sp1(1);
        
        sId(sId == sp1) = [];
        
        sp2 = mode(sId);
        sp2 = sp2(1);
        
        % Skipping direction
        direction = 0;
        
        
        % Map back to true
        % Do synapse correspondence with lookup 1 per synapse
        
        synDatabaseId = sMtxCube.data(rp(i).PixelIdxList(1));
        
        %tSyn = ocpS.getField(synDatabaseId,f.synapse.seeds);
        
        %qs = OCPQuery;
        %qs.setType(eOCPQueryType.RAMONMetaOnly);
        %qs.setId(synDatabaseId);
        %ss = ocpS.query(qs);
        %tSyn = ss.seeds;
        temp = sMtxTruth.data(rp(i).PixelIdxList);
        tSyn = mode(temp(temp > 0));

        if isempty(tSyn) || isnan(tSyn) || tSyn == 0  
            parentSyn = -1 * synDatabaseId;
        else
            parentSyn = tSyn;
        end
        
        % Write edge list row
        edgeList(i,:) = [sp1; sp2; synDatabaseId; direction; parentSyn]; %NaNs if empty ?
       
    end
end

