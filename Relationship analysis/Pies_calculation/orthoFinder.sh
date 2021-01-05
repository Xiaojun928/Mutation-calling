#!/bin/bash
#SBATCH -n 8

#	usage
#mkdir 00_seq_folder
#rename protein faa *protein
#mv *faa 00_seq_folder
echo "sh this.sh"
echo "require protein seqs namely .faa in 00_seq_folder\n\n"

#	initialization
threadsT=8 #diamond threads
threadsA=8

#	operation
time /home-user/software/OrthoFinder/OrthoFinder-2.2.1/orthofinder.py -og -1 -t $threadsT -a $threadsA -S diamond -M msa -f ../00_seq_folder -n 01_blast_folder
