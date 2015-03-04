% Setup script for I2G "toolbox"
% This should be run during each matlab session 

addpath(pwd) %top level directory
addpath('./data')
addpath(genpath('packages'))
addpath('test')
addpath(genpath('external/tools'))

run('external/vlfeat/toolbox/vl_setup')