from config import *
import os
import sys
import time


print "Ortholog identification"
os.system('find ../reannotation -name "*faa" |xargs -i cp {} ../00_seq_folder')
os.system('find ../reannotation -name "*ffn" |xargs -i cp {} ../nuc')

os.system('rm slurm*')
os.system('sbatch orthoFinder.sh')
os.system('rm -r ../reannotation')


