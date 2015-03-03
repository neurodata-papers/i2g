# Automated Images to Graphs (i2g.io)

## This is the repository for the Images to Graphs Pipeline, the first automated pipeline to estimate graphs from high-resolution serial section electron microscopy tissue.

Leveraging the OCP services, it provides a set of interfaces and tools to estimate and assess automatically generated graphs. 

### The tools provided in our initial release are:


Membrane Detection:

- Theano CNN implementation (based on Ciresan 2012)  
- Cafe CNN implementation (based on Ciresan 2012)  

Vesicle Detection:
- Template Matching 

Neuron Segmentation:
- Gala 
- Rhoana
- Watershed

Synapse Detection:
- Context Synapse Detection
- Carlos Becker's method 
- Ilastik classifier (not yet implemented)

Ilastik and the deep learning frameworks are general tools that may be adapted for other purposes.

For each package, we provide:
- A LONI module
- Relevant functions and scripts
- An example script, with validation (e.g., unit tests)  [Still in progress]
- A separate method for training, when applicable
- Required dependencies and installation instructions
- Package install validation (where available)

These packages are designed to be used in a LONI pipelining framework, with data derivatives stored using the RAMON data standard.  We provide an example integrated with a standalone LONI client for simplicity, although large scale runs are managed by a LONI server.

Workflows are also provided for two cases:  Images to Graphs (aligned image volume through graph estimation), and a parameter tuning workflow, which focuses only on optimizing segmentation and synapse detection methods as an example (following the manuscript).

Workflows should run "out of the box," although assume that the code is installed in /mnt/pipeline/tools/CAJAL3D.  Modules will need to be updated (or batch edited) to reflect the appropriate root directory.

### General prerequisites:
- Centos 6.x (6.6 recommended)
- MATLAB  
- Anaconda (Python 2.7) - this takes care of most of the python dependencies
- LONI (client or server)
- OCP MATLAB API 
- I2G Repo

### Algorithms included:
- Gala 
- Rhoana
-- CPLEX
- Becker CCBoost
- Ilastik
- Caffe
- Theano
- VLFeat
- 3D SLIC code

Outstanding TODOs:
- Ilastik issue with glib 2.14
- How to point to python2.7
- Deep learning not integrated
- Matlab compiler setup

## ----------------------------
## GENERAL INSTALLATION INSTRUCTIONS
## ----------------------------

#Configure a basic Centos installation, along with a non-root user account (sudo privileges)

#Configure and install MATLAB (this is a required dependency - your install process will vary)

#Get OCP Matlab 
wget https://github.com/openconnectome/ocpMatlab/archive/master.zip
#Unzip to: /mnt/pipeline/tools/CAJAL3D

# Do the following as root
#Update all packages:
yum -y update  

## ---------------------------------
## ALGORITHM INSTALLATION INSTRUCTIONS
## ---------------------------------

# Carlos' algorithm
wget https://documents.epfl.ch/groups/c/cv/cvlab-unit/www/data/synapses/ccboost-precompiled-v0.2.tar.bz2

# Download and Install LONI (Client) into home directory
http://www.loni.usc.edu/Software/Pipeline
# TODO:  Add code to unzip and move

# Download CC Boost
cd /mnt/pipeline/tools/CAJAL3D/external/
wget https://documents.epfl.ch/groups/c/cv/cvlab-unit/www/data/synapses/ccboost-precompiled-v0.2.tar bz2

tar -xvf ccboost-precompiled-v0.2.tar

# Download VL Feat
wget http://www.vlfeat.org/download/vlfeat-0.9.20-bin.tar.gz
tar -xvf vlfeat-0.9.20-bin.tar.gz
rm vlfeat-0.9.20-bin.tar.gz
# Need to run('VLFEATROOT/toolbox/vl_setup')

# Download Ilastik
wget http://files.ilastik.org/ilastik-1.1.5-Linux.tar.gz
tar -xvf ilastik-1.1.5-Linux.tar.gz
rm ilastik-1.1.5-Linux.tar.gz

# Install Anaconda
wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-2.1.0-Linux-x86_64.sh

bash Anaconda-2.1.0-Linux-x86_64.sh

#accept license
#install in /usr/bin/local/anaconda (TODO)

#export path in ~/.bashrc file
#export PATH="/usr/local/bin/anaconda/bin:$PATH"

# Gala
# When using anaconda, just need the gala package itself
# wget https://github.com/janelia-flyem/gala/archive/master.zip
# Install manually to link to anaconda
# unzip master.zip
# mv gala-master /mnt/pipeline/tools/CAJAL3D/external/gala
# cd /mnt/pipeline/tools/CAJAL3D/external/gala
# python /usr/local/bin/anaconda/bin/python/setup.py install 

# Download Viridis
wget https://github.com/jni/viridis/archive/master.zip
unzip master.zip
cd viridis-master
/usr/local/bin/anaconda/bin/python setup.py install

\# Rhoana
\# Original hoana package (not needed, because we wrapped it)
\# Also need mahotas, pymaxflow, fast64counter, cplex

# Mahotas
wget https://pypi.python.org/packages/source/m/mahotas/mahotas-1.2.4.tar.gz
tar -xvf mahotas-1.2.4.tar.gz
cd mahotas-1.2.4.tar.gz
sudo /usr/local/bin/anaconda/bin/python setup.py install

# Download pymaxflow from github.com/Rhoana/pymaxflow - can send you the tar if you want
wget https://github.com/Rhoana/pymaxflow/archive/master.zip
unzip master.zip #make sure we cleanup each time
cd pymaxflow-master
sudo /usr/local/bin/anaconda/bin/python setup.py install
rm ~/Downloads/master.zip  #make sure we download to this location

# Download fast64counter from github.com/Rhoana/fast64counter
wget https://github.com/Rhoana/fast64counter/archive/master.zip
unzip master.zip #make sure we cleanup each time
cd fast64counter
sudo /usr/local/bin/anaconda/bin/python setup.py install
rm ~/Downloads/master.zip

# Download cplex bin file
# TODO - for now hosted privately
scp will@braingraph1.cs.jhu.edu:/data/scratch/will/cplex_studio126.linux-x86-64.bin
sudo sh cplex_studio126.linux-x86-64.bin
(interactive prompts - maybe a headless mode?  language, accept license, install location, etc...)
#Then do python bindings:
cd /opt/ibm/ILOG/CPLEX_Studio126/cplex/python/x86-64_linux
sudo python setup.py install

# Clone repo
cd /mnt/pipeline/tools/CAJAL3D/
git clone https://github.com/openconnectome/i2g.git
