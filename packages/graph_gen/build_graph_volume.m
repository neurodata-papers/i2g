function build_graph_volume(nodeToken, nodeServer, edgeToken, ...
edgeServer, synVolTruth, queryFile, resolution, useSemaphore, attredgeFile, edgeListFile, graphFileName)

% build graph - this function associates neurons and synapses 
% and builds an edge list
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

% Build Graph from  graph
edgeList = synapse_neuron_association_volume(nodeToken, nodeServer, ...
    edgeToken, edgeServer, synVolTruth, queryFile, [], resolution, 0, useSemaphore);

attredge
Writer(edgeList, attredgeFile);

%% For saving the graph
fid = fopen(graphFileName,'wb');
gName = [nodeToken, '_', edgeToken];
fprintf(fid,gName);
fclose(fid);

save(edgeListFile, 'edgeList')



