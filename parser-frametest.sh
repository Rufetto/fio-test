#!/bin/bash
# This script parses frametes output and generates CSV file.
#Set variables
file_name=$1
open_time=""
IO_time=""
Frame_read=""
Data_rate=""
Frame_rate=""
#frametest output examples with awk arguments numbering underline
#           Open         I/O         Frame    Data rate      Frame rate
#Overall:   0.003 ms     6.28 ms     1.59 ms  30609.67 MB/s  628.7 fps 
#  1          2   3       4   5       6   7      8      9     10   11

#check arguments
if [ -z "$*" ]; then
  echo "No argument. Please select file."
  echo "Example:"
  echo "parser-frametest.sh <file name pr path to the file>"
  exit 
fi

#parse TestIO Output
echo "Open File (ms);I\O (ms);Frame (ms);Data rate (MB\s);Frame rate (fps);"
while IFS= read -r line
do
  if echo $line | grep -q '\bOverall: \b'; then
    #pattern=$(echo $line | grep -Ro '\bOverrall: \b')
    open_time=$(echo $line | awk '{print $2}')
    IO_time=$(echo $line | awk '{print $4}')
    Frame_read=$(echo $line | awk '{print $6}')
    Data_rate=$(echo $line | awk '{print $8}')
    Frame_rate=$(echo $line | awk '{print $10}')
    echo $open_time';'$IO_time';'$Frame_read';'$Data_rate';'$Frame_rate';'
    continue
  fi
done < "$file_name"