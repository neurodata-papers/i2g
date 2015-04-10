function contextSynDetectRAMONify_integrated(uploadToken, uploadServer, upload_author, prob,...
    threshold, minSize2D, maxSize2D, minSize3D, doEdgeCrop,...
    useSemaphore, errorPage)
%
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

%% Check inputs
if ~exist('errorPage','var')
    % set to server default
    errorPage = '/mnt/pipeline/errorPages';
end

%% Create probability data access object
if useSemaphore == 1
    oo = OCP('semaphore');
else
    oo = OCP();
end

oo.setErrorPageLocation(errorPage);


% Upload setup
oo.setServerLocation(uploadServer);
oo.setAnnoToken(uploadToken);

%% Threshold probabilities
% if using membranes, first mask
temp_prob = prob.data;

% POST PROCESSING
% threshold prob
temp_prob(temp_prob >= threshold) = 1;
temp_prob(temp_prob < 1) = 0;

% Check 2D size limits first
cc = bwconncomp(temp_prob,4);

%Apply object size filter
for jj = 1:cc.NumObjects
    if length(cc.PixelIdxList{jj}) < minSize2D || length(cc.PixelIdxList{jj}) > maxSize2D
        temp_prob(cc.PixelIdxList{jj}) = 0;
    end
end

% get size of each region in 3D
cc = bwconncomp(temp_prob,6);

% check 3D size limits and edge hits
for ii = 1:cc.NumObjects
    %to be small
    if length(cc.PixelIdxList{ii}) < minSize3D
        temp_prob(cc.PixelIdxList{ii}) = 0;
    end
end

%Drop all that touch an edge
if doEdgeCrop
    % get inds of edges
    ind_block = zeros(size(prob));
    ind_block(:,:,1) = 1;
    ind_block(:,:,end) = 1;
    ind_block(1,:,:) = 1;
    ind_block(end,:,:) = 1;
    ind_block(:,1,:) = 1;
    ind_block(:,end,:) = 1;
    inds = find(ind_block == 1);
    
    for ii = 1:cc.NumObjects
        
        if any(ismember(cc.PixelIdxList{ii},inds))
            temp_prob(cc.PixelIdxList{ii}) = 0;
            %continue;
        end
    end
end

% re-run connected components
cc = bwconncomp(temp_prob,18);

fprintf('Number Synapses detected: %d\n',cc.NumObjects);

%% Upload RAMON objects as voxel lists with preserve write option
fprintf('Creating Synapse Objects...');
synapses = cell(cc.NumObjects,1);
for ii = 1:cc.NumObjects
    
    s = RAMONSynapse();
    s.setResolution(prob.resolution);
    s.setXyzOffset(prob.xyzOffset);
    s.setDataType(eRAMONDataType.anno32);
    s.setAuthor(upload_author);
    
    [r,c,z] = ind2sub(size(prob.data),cc.PixelIdxList{ii});
    voxel_list = cat(2,c,r,z);
    
    s.setVoxelList(prob.local2Global(voxel_list));
    
    
    % Approximate absolute centroid
    approxCentroid = prob.local2Global(round(mean(voxel_list,1)));
    
    %metadata - for convenience
    s.addDynamicMetadata('approxCentroid', approxCentroid);
    
    synapses{ii} = s;
end
fprintf('done.\n');

if cc.NumObjects ~= 0
    fprintf('Uploading %d synapses\n\n',length(synapses));
    synapses
    ids = oo.createAnnotation(synapses,eOCPConflictOption.preserve);
    
    for ii = 1:length(ids)
        fprintf('Uploaded synapse id: %d\n',ids(ii));
    end
    
    fprintf('Uploaded %d synapses\n\n',length(ids));
else
    fprintf('No Synapses Detected\n');
end

fprintf('@@start@@%s##end##\n', uploadToken)
fprintf('$$token$$%s**stop**\n', uploadServer)
end

