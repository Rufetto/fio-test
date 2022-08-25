#!/bin/bash
# This script parse BlackMagic DaVinciResolve TestIO output
# Generate csv file

#Set variables
file_name=$1
pattern=""
bw=""
fps=""
line=""

#check arguments
if [ -z "$*" ]; then
  echo "No argument. Please select file."
  echo "Example:"
  echo "parser-TestIO.sh <file name pr path to the file>"
  exit 
fi
echo 'filename='$filename

#parse TestIO Output
echo "Pattern;Bandwidth;FPS;"
while IFS= read -r line
do
  if echo $line | grep -q '\bREAD-WRITE\b'; then
    pattern=$(echo $line | grep -o '\bREAD-WRITE\b')
    continue
  elif echo $line | grep -q '\bWRITE\b'; then
    pattern=$(echo $line | grep -o '\bWRITE\b')
    continue
  elif echo $line | grep -q '\bREAD-reverse\b'; then
    pattern=$(echo $line | grep -o '\bREAD-reverse\b')
    continue
  elif echo $line | grep -q '\bRANDOM READ\b'; then
    pattern=$(echo $line | grep -o '\bRANDOM READ\b')
    continue
  elif echo $line | grep -q '\bREAD\b'; then
    pattern=$(echo $line | grep -o '\bREAD\b')
    continue
  elif echo $line | grep -q '\bTotal throughput\b'; then
    bw=$(echo $line | awk '{print $4}')
    fps=$(echo $line | awk '{print $7}')
    echo $pattern';'$bw';'$fps';'
  fi
done < "$file_name"