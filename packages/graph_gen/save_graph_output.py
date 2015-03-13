#!/usr/bin/python27

# (c) [2014] The Johns Hopkins University / Applied Physics Laboratory All Rights Reserved. Contact the JHU/APL Office of Technology Transfer for any additional rights.  www.jhuapl.edu/ott
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import sys
import os
import shutil

def main():

  parser = argparse.ArgumentParser(description='Save Graph')
  parser.add_argument('output_dir', action="store", help="output directory to target")
  parser.add_argument('prefix', action="store", help="file prefix")
  parser.add_argument('graph_filename', action="store", help="The output file name")
  parser.add_argument('output_ext', action="store", help='graphml | ncol | edgelist | lgl | pajek | graphdb | numpy | mat')
  parser.add_argument('graph_raw', action="store", help="The raw graph")

  parser.add_argument('attredge', action="store", help="attrEdge file")
  parser.add_argument('gstats', action="store", help="gstat")
  result = parser.parse_args()
  
  with open (result.graph_filename, "r") as myfile:
    fileout=myfile.readlines()

  fileout = str(fileout[0])
  
  # Copy MROCP file 
  outFile1 = os.path.join(result.output_dir, result.prefix + fileout + '.' + result.output_ext)
  shutil.copyfile(result.graph_raw,outFile1)
  
  # Copy AttrEdge file
  outFile2 = os.path.join(result.output_dir, result.prefix + fileout + '.attredge')  
  shutil.copyfile(result.attredge, outFile2)

  # Copy Graph Error and Graphs MAT file
  outFile3 = os.path.join(result.output_dir, 'gstats_i2g' + fileout + '.mat')  
  shutil.copyfile(result.gstats, outFile3)
  
  print 'Successfully copied!'  


if __name__ == "__main__":
  main()