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
  parser.add_argument('graph_filename', action="store", help="The output file name")
  parser.add_argument('output_ext', action="store", help='graphml | ncol | edgelist | lgl | pajek | graphdb | numpy | mat')
  parser.add_argument('graph_raw', action="store", help="The raw graph")
  result = parser.parse_args()
  
  with open (graph_filename, "r") as myfile:
    fileout=myfile.readlines()

  fileout = str(fileout[0])
  
  outFile = os.path.join(output_dir, fileout + '.' + output_ext)
  print graph_raw
  print outFile
  shutil.copyfile(graph_raw,outFile)
  print 'Successfully copied!'  


if __name__ == "__main__":
  main()