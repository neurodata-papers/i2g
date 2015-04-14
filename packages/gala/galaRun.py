#!/usr/bin/python2.7
# Gala Driver Script
# To resolve:
# Figure out optimal watershed parameters

# Based on example script from Gala Master

from gala import classify, features, agglo, evaluate as ev, optimized #imio
import scipy
import scipy.io
from gala import morpho
import scipy.ndimage as ndimage
import numpy as np
import scipy.signal as ssignal
import time
from gala import evaluate
import sys
import os.path
import os

start = time.time()

#doWatershed
doWatershed = 1

#InputDir:  Probably need both image and membrane as separate files
inFileImage = sys.argv[1]
inFileMembrane = sys.argv[2]

#OutputDir
outputFile = sys.argv[3]

# Params
thresh = sys.argv[4]  
algo = sys.argv[5]

# Cast to correct types
thresh = float(thresh)
algo = int(float(algo))
mat_contents = scipy.io.loadmat(inFileImage)
im = mat_contents['im']

mat_contents2 = scipy.io.loadmat(inFileMembrane)
membrane = mat_contents2['membrane']
	
xdim, ydim, zdim = (im.shape)

mat_contents3 = scipy.io.loadmat(sys.argv[7])
ws = mat_contents3['ws']	
# Do watershed

ws = ws.astype('int64')
print "unique labels in ws:",np.unique(ws).size
    
print "Creating RAG..."
#membraneInt = membrane * 255

# create graph and obtain a training dataset

if algo == 1: #run gala
    fc = features.base.Composite(children=[features.moments.Manager(), features.histogram.Manager(25, 0, 1, [0.1, 0.5, 0.9]), 
        features.graph.Manager(), features.contact.Manager([0.1, 0.5, 0.9]) ])

    rf = classify.load_classifier(sys.argv[6])
    learned_policy = agglo.classifier_probability(fc, rf)
    
    print 'applying classifier...'
    g_test = agglo.Rag(ws, membrane, learned_policy, feature_manager=fc)
    print 'choosing best operating point...'
    g_test.agglomerate(thresh) # best expected segmentation
    labels = g_test.get_segmentation()
    labels, _, _ = evaluate.relabel_from_one(labels)
    print "Completed Gala Run"


# gala allows implementation of other agglomerative algorithms, including
# the default, mean agglomeration

if algo == 2: #mean agglomeration
    print 'mean agglomeration step...'

    g_testm = agglo.Rag(ws, membrane, merge_priority_function=agglo.boundary_mean)
    g_testm.agglomerate(thresh)
    labels = g_testm.get_segmentation()
    labels, _, _ = evaluate.relabel_from_one(labels)

    print "Completed Mean Agglo"

fileOut = open(outputFile, "w")
data = {}
data['labels'] = labels

scipy.io.savemat(fileOut,data)

end = time.time()
print 'Total Time Elapsed: ' + str(end-start)


