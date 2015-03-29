#watershed example, based on code from Neal and Juan 

# imports
from gala import classify, features, agglo, evaluate as ev, optimized #imio
import scipy
import scipy.io
from gala import morpho
import scipy.ndimage as ndimage
import numpy as np
import scipy.signal as ssignal
import time
from gala import evaluate

start = time.time()
# read in OCP training data
inFileImage = '/mnt/pipeline/tools/i2g/packages/gala/em_ac4_short.mat'
inFileMembrane = '/mnt/pipeline/tools/i2g/packages/gala/membrane_ac4_short.mat'
inFileTruth = '/mnt/pipeline/tools/i2g/packages/gala/labels_ac4_short.mat'

im = scipy.io.loadmat(inFileImage)['im']
im = im.astype('int32')
membraneTrain = scipy.io.loadmat(inFileMembrane)['membrane']
membraneTrain = membraneTrain.astype('float32')
	
gt_train = scipy.io.loadmat(inFileTruth)['truth']
gt_train = gt_train.astype('int64') #just in case!

xdim, ydim, zdim = (im.shape)

# Do watershed

min_seed_size = 2
connectivity = 2
smooth_thresh = 0.02
override = 0
membraneTrain = membraneTrain.astype('float32')
# THIS ASSUMES MEMBRANES ARE ON 0 1 
#membraneTrain = membraneTrain/255
ws_train=np.zeros(membraneTrain.shape)
cur_max = 0
for ii in range(membraneTrain.shape[0]):
    print ii
    ws_train[ii,:,:] = morpho.watershed(membraneTrain[ii,:,:],
    connectivity=connectivity, smooth_thresh=smooth_thresh,
    override_skimage=override,minimum_seed_size=min_seed_size) + cur_max
        
    cur_max = ws_train[ii,:,:].max()

ws_train = ws_train.astype('int64')
print "unique labels in ws:",np.unique(ws_train).size
    
ws_train = optimized.despeckle_watershed(ws_train)
print "unique labels after despeckling:",np.unique(ws_train).size
ws_train, _, _ = evaluate.relabel_from_one(ws_train)
    
if ws_train.min() < 1: 
    ws_train += (1-ws_train.min())

#ws_train = ws_train.astype('int32')
print "Training watershed complete"

print "Watershed train (VI, ARI)"
vi_ws_train = ev.split_vi(ws_train, gt_train),
ari_ws_train = ev.adj_rand_index(ws_train, gt_train)
print vi_ws_train
print ari_ws_train

scipy.io.savemat('/mnt/pipeline/tools/CAJAL3D/packages/gala/isbi_rfr2015_full/train_watershed.mat', mdict={'ws_train':ws_train})
scipy.io.savemat('/mnt/pipeline/tools/CAJAL3D/packages/gala/isbi_rfr2015_full/membraneTrain.mat', mdict={'membraneTrain':membraneTrain})
scipy.io.savemat('/mnt/pipeline/tools/CAJAL3D/packages/gala/isbi_rfr2015_full/gtTrain.mat', mdict={'gt_train':gt_train})
###############################
## New stuff
###############################
fc = features.base.Composite(children=[features.moments.Manager(), features.histogram.Manager(25, 0, 1, [0.1, 0.5, 0.9]), 
    features.graph.Manager(), features.contact.Manager([0.1, 0.5, 0.9]) ])

#membraneTrain = membraneTrain * 255
#feature_manager=features.base.Composite(children=[features.moments.Manager])
print "Creating RAG..."
# create graph and obtain a training dataset
g_train = agglo.Rag(ws_train, membraneTrain, feature_manager=fc)
print 'Learning agglomeration...'
(X, y, w, merges) = g_train.learn_agglomerate(gt_train, fc,min_num_epochs=5)[0]
y = y[:, 0] # gala has 3 truth labeling schemes, pick the first one
print(X.shape, y.shape) # standard scikit-learn input format

print "Training classifier..."
# train a classifier, scikit-learn syntax
rf = classify.DefaultRandomForest().fit(X, y)
# a policy is the composition of a feature map and a classifier
learned_policy = agglo.classifier_probability(fc, rf)
classify.save_classifier(rf,'/mnt/pipeline/tools/i2g/packages/gala/ac4_short_classifier.rf')