#!/bin/bash

dir=$1
echo $dir

for i in `ls $dir/*mafft`
do
j=$(basename $i .faa.mafft)
perl trans_fasta_2_one_line.pl $i
mv $dir/$j.msa $i
done
