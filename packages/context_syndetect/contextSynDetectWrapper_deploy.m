function contextSynDetectWrapper_deploy(imgServer, imgToken, vesicleServer, vesicleToken, membraneServer, membraneToken, annoServer, annoToken, ...
    queryFile, intensity_bounds, classifier_file, upload_author, threshold, minSize2D, maxSize2D, minSize3D, padX, padY, padZ, useSemaphore)
% contextSynDetectWrapper - this function addes OCP annotation
% database upload to the detector

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

if ~exist('padX','var')
    padX = 0;
end
if ~exist('padY','var')
    padY = 0;
end
if ~exist('padZ','var')
    padZ = 0;
end

%% Setup OCP
if useSemaphore == 1
    oo = OCP('semaphore');
else
    oo = OCP();
end

if ~exist('errorPageLocation','var')
    % set to server default
    oo.setErrorPageLocation('/mnt/pipeline/errorPages');
else
    oo.setErrorPageLocation(errorPageLocation);
end

%% Download Vesicle Cube

oo.setServerLocation(vesicleServer);
oo.setAnnoToken(vesicleToken);
load(queryFile);
query.setType(eOCPQueryType.annoDense);
vesicles = oo.query(query);

%% Download Membrane Cube
oo.setServerLocation(membraneServer);
oo.setAnnoToken(membraneToken);
query.setType(eOCPQueryType.probDense);
membraneCube = oo.query(query);

%% Download EM Data
oo.setServerLocation(imgServer);
oo.setImageToken(imgToken);
query.setType(eOCPQueryType.imageDense);
cube = oo.query(query);

%% Run Detector
[~,~,data,~,~,~] = contextSynDetect_v6(cube, intensity_bounds, classifier_file, vesicles, membraneCube);

% unevaluated pixels are NaNs...fix
data(isnan(data)) = 0;


%% Upload inscribed probability cube, removing padded region
oo.setServerLocation(imgServer);
oo.setImageToken(imgToken);
img_size = oo.imageInfo.DATASET.IMAGE_SIZE(query.resolution);

% Compute padding offsets
if padX ~= 0 || padY ~=0 || padZ ~=0
    % Start edge condition checks
    if (query.xRange(1) == 0) && (query.yRange(1) == 0) && (query.zRange(1) == oo.imageInfo.DATASET.SLICERANGE(1))
        % No x, y, or z start padding
        xstart = 0;
        ystart = 0;
        zstart = oo.imageInfo.DATASET.SLICERANGE(1);
        xend = size(data,2) - padX;
        yend = size(data,1) - padY;
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1), query.yRange(1), query.zRange(1)];
        
    elseif (query.xRange(1) == 0) && (query.yRange(1) == 0)
        % No x or y start padding
        xstart = 1;
        ystart = 1;
        zstart = padZ;
        xend = size(data,2) - padX;
        yend = size(data,1) - padY;
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1), query.yRange(1), query.zRange(1) + padZ];
        
    elseif (query.xRange(1) == 0) && (query.zRange(1) ==  oo.imageInfo.DATASET.SLICERANGE(1))
        % No x or z start padding
        xstart = 1;
        ystart = padY;
        zstart = 1;
        xend = size(data,2) - padX;
        yend = size(data,1) - padY;
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1), query.yRange(1) + padY, query.zRange(1)];
        
    elseif (query.yRange(1) == 0) && (query.zRange(1) ==  oo.imageInfo.DATASET.SLICERANGE(1))
        % No y, or z start padding
        xstart = padX;
        ystart = 1;
        zstart = 1;
        xend = size(data,2) - padX;
        yend = size(data,1) - padY;
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1) + padX, query.yRange(1), query.zRange(1)];
        
    elseif query.xRange(1) == 0
        % No x start padding
        xstart = 1;
        ystart = padY;
        zstart = padZ;
        xend = size(data,2) - padX;
        yend = size(data,1) - padY;
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1), query.yRange(1) + padY, query.zRange(1) + padZ];
        
    elseif query.yRange(1) == 0
        % No y start padding
        xstart = padX;
        ystart = 1;
        zstart = padZ;
        xend = size(data,2) - padX;
        yend = size(data,1) - padY;
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1) + padX, query.yRange(1), query.zRange(1) + padZ];
        
    elseif (query.zRange(1) == oo.imageInfo.DATASET.SLICERANGE(1))
        % No z start padding
        xstart = padX;
        ystart = padY;
        zstart = 1;
        xend = size(data,2) - padX;
        yend = size(data,1) - padY;
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1) + padX, query.yRange(1) + padY, query.zRange(1)];
        
        
        
        % End edge condition checks
    elseif (query.xRange(2) == img_size(1)) && (query.yRange(2) == img_size(2)) && (query.zRange(2) == oo.imageInfo.DATASET.SLICERANGE(2))
        % No x, y, or z end padding
        xstart = padX;
        ystart = padY;
        zstart = padZ;
        xend = size(data,2);
        yend = size(data,1);
        zend = size(data,3);
        xyzOffset = [query.xRange(1) - padX, query.yRange(1) - padY, query.zRange(1) - padZ];
        
    elseif (query.xRange(2) == img_size(1)) && (query.yRange(2) == img_size(2))
        % No x or y end padding
        xstart = padX;
        ystart = padY;
        zstart = padZ;
        xend = size(data,2);
        yend = size(data,1);
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1) - padX, query.yRange(1) - padY, query.zRange(1) - padZ];
        
    elseif (query.xRange(2) == img_size(1)) && (query.zRange(2) == oo.imageInfo.DATASET.SLICERANGE(2))
        % No x or z end padding
        xstart = padX;
        ystart = padY;
        zstart = padZ;
        xend = size(data,2);
        yend = size(data,1) - padY;
        zend = size(data,3);
        xyzOffset = [query.xRange(1) - padX, query.yRange(1) - padY, query.zRange(1) - padZ];
        
    elseif (query.yRange(2) == img_size(2)) && (query.zRange(2) == oo.imageInfo.DATASET.SLICERANGE(2))
        % No y or z end padding
        xstart = padX;
        ystart = padY;
        zstart = padZ;
        xend = size(data,2) - padX;
        yend = size(data,1);
        zend = size(data,3);
        xyzOffset = [query.xRange(1) - padX, query.yRange(1) - padY, query.zRange(1) - padZ];
        
    elseif query.xRange(2) == img_size(1)
        % No x end padding
        xstart = padX;
        ystart = padY;
        zstart = padZ;
        xend = size(data,2);
        yend = size(data,1) - padY;
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1) - padX, query.yRange(1) - padY, query.zRange(1) - padZ];
        
    elseif query.yRange(2) == img_size(2)
        % No y end padding
        xstart = padX;
        ystart = padY;
        zstart = padZ;
        xend = size(data,2) - padX;
        yend = size(data,1);
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1) - padX, query.yRange(1) - padY, query.zRange(1) - padZ];
        
    elseif query.zRange(2) == oo.imageInfo.DATASET.SLICERANGE(2)
        % No z end padding
        xstart = padX;
        ystart = padY;
        zstart = padZ;
        xend = size(data,2) - padX;
        yend = size(data,1) - padY;
        zend = size(data,3);
        xyzOffset = [query.xRange(1) - padX, query.yRange(1) - padY, query.zRange(1) - padZ];
        
    else
        % Normal padding sitution
        xstart = padX;
        ystart = padY;
        zstart = padZ;
        xend = size(data,2) - padX;
        yend = size(data,1) - padY;
        zend = size(data,3) - padZ;
        xyzOffset = [query.xRange(1) + padX, query.yRange(1) + padY, query.zRange(1) + padZ];
    end
else
    % No padding used so upload whole block
    xstart = 1;
    xend = size(data,2);
    ystart = 1;
    yend = size(data,1);
    zstart = 1;
    zend = size(data,3);
    xyzOffset = [query.xRange(1),query.yRange(1),query.zRange(1)];
end



oo.setServerLocation(annoServer);
oo.setAnnoToken(annoToken);

% Create RAMONVolume for block upload
prob = RAMONVolume();
prob.setCutout(data(ystart:yend,xstart:xend,zstart:zend));
prob.setResolution(query.resolution);
prob.setXyzOffset(xyzOffset);
prob.setDataType(eRAMONDataType.prob32);

%% Hardcoded here

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

end

