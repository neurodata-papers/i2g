function edgeList = graph_retrieval_synapse(synToken, synServer, attrEdgeFile, graphFile)
% This builds a segment graphs


oo = OCP('semaphore');
oo.setServerLocation(synServer);
oo.setAnnoToken(synToken);

f = OCPFields;
q = OCPQuery;
q.setType(eOCPQueryType.RAMONIdList);

id = oo.query(q); %do all in one chunk for simplicity


q = OCPQuery;
q.setType(eOCPQueryType.RAMONMetaOnly);
synAll = q.setId(id);

c = 1;
skipCount = 0;
errCount = 0;

for i = 1:length(synAll)
    
    % Get all segments for this synapse 
    z = cell2mat(synAll{i}.segments.keys);
    
    if length(z) == 2
        %two segments found, add to edge list
    
    edgeList(c,:) = [min(z), max(z), id(i), 0]; % direction still unknown
    
    elseif isempty(z)
        %no segments found, skip synapse
        disp('Skipping Synapse')
        skipCount = skipCount + 1;
    else
        disp('Error - an incorrect number of segment pairs found')
        % Synapses with one edge have no meaning as we are currently
        % defining a graph!
        errCount = errCount + 1;
    end
end

% Make LG and NG
[neuGraph, nId, synGraph, synId] = graphMatrix(edgeList, varargin); %#ok<ASGLU>
save(graphFile, 'neuGraph','nId','synGraph','synId','edgeList')
attredgeWriter(edgeList, attrEdgeFile);
skipCount
errCount
    