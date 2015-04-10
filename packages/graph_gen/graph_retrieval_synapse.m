function edgeList = graph_retrieval_synapse(synToken, synServer, attrEdgeFile, graphFile)
% This builds a segment graphs

edgeList = [];
oo = OCP('semaphore');
oo.setServerLocation(synServer);
oo.setAnnoToken(synToken);

f = OCPFields;
q = OCPQuery;
q.setType(eOCPQueryType.RAMONIdList);

idAll = oo.query(q); %do all in one chunk for simplicity


skipCount = 0;
errCount = 0;
c = 1;


% break up query because too large

q = OCPQuery;
q.setType(eOCPQueryType.RAMONMetaOnly);

chunkSize = 100;
nChunk = ceil(length(idAll)/chunkSize);

for j = 1:nChunk
    j
    idChunk = idAll((j-1)*chunkSize+1:min(j*chunkSize,length(idAll)));
    q.setId(idChunk);
    synAll = oo.query(q);
    
    for i = 1:length(synAll)
        
        % Get all segments for this synapse
        z = cell2mat(synAll{i}.segments.keys);
        
        if length(z) == 2
            %two segments found, add to edge list
            
            edgeList(c,:) = [min(z), max(z), idChunk(i), 0]; % direction still unknown
            c = c + 1;
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
end
    % Make LG and NG
    [neuGraph, nId, synGraph, synId] = graphMatrix(edgeList); %#ok<ASGLU>
    save(graphFile, 'neuGraph','nId','synGraph','synId','edgeList')
    
    if size(edgeList,1) > 0
        attredgeWriter(edgeList, attrEdgeFile);
    end

skipCount
errCount
