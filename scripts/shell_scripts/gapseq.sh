#!/bin/bash

## This code generates a gapseq.sh script for each *.fna file

for file in ./*.fna
  do
    #cp template.sh $file.gapseq.sh
    #echo "gapseq find -p all $file" >> $file.gapseq.sh
    #echo "#End of file" >> $file.gapseq.sh
     sbatch "$file.gapseq.sh"
  done
