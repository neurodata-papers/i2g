% Setup script for I2G "toolbox"
% This should be run during each matlab session 

i2gDir = '/mnt/pipeline/tools/CAJAL3D/i2g';

addpath(i2gDir) %top level directory
addpath([i2gDir, filesep, 'data'])
addpath(genpath([i2gDir, filesep, 'packages']))
addpath([i2gDir,'test'])
addpath(genpath([i2gDir,filesep,'external', filesep, 'tools']))
run(['external', filesep, 'vlfeat', filesep, 'toolbox', filesep, 'vl_setup'])