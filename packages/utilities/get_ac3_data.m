function [eData, mData, sData, vData] = get_ac3_data(zSlice, zSliceEnd)
oo = OCP();
oo.setServerLocation('http://braingraph1dev.cs.jhu.edu/');
oo.setImageToken('kasthuri11cc');

%AC3
xTrainExt = [5472, 6496];
yTrainExt = [8712, 9736];
zTrainExt = [zSlice,zSliceEnd]; %1256

q = OCPQuery();
q.setResolution(1);
q.setType(eOCPQueryType.imageDense);
q.setXRange(xTrainExt);
q.setYRange(yTrainExt);
q.setZRange(zTrainExt);

try
    eData = oo.query(q);
    
catch
    eData = download_big_cuboid(oo,q);
end
%% Synapse Data

oo.setServerLocation('http://openconnecto.me/');
oo.setAnnoToken('ac3_synTruth_v4');
q.setType(eOCPQueryType.annoDense);

try
    sData = oo.query(q);
catch
    sData = download_big_cuboid(oo,q);
end

%% Membranes
oo.setServerLocation('http://dsp061.pha.jhu.edu/');
oo.setAnnoToken('ac3_membranes');

q.setType(eOCPQueryType.probDense);

try
    mData = oo.query(q);
catch
    mData = download_big_cuboid(oo,q);
end
%% Vesicles

oo.setServerLocation('http://dsp061.pha.jhu.edu/');
oo.setAnnoToken('kasthuri11_inscribed_vesicles');
q.setType(eOCPQueryType.annoDense);

try
    vData = oo.query(q);
catch    
    vData = download_big_cuboid(oo,q);
end
