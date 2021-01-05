from config import *
import re
import numpy as np
import os
import sys
import time


print "get core gene families"
files = os.listdir(PATH_TO_OUTPUT + '00_seq_folder')
for file in files:
	if re.search("Results_01_*",file):
		ortho_re = file
os.system('perl extract_seq_for_scp.pl ' + PATH_TO_OUTPUT + ' ' + PATH_TO_OUTPUT + '00_seq_folder/' + ortho_re)


print "get aa alignment"
os.system('python launch_mafft_build.py')
os.system('python launch_mafft_multi.py')
os.system('rm mafft.txt')


print "get nuc alignment"
os.system('sh multi2oneline.sh ' + PATH_TO_OUTPUT + 'core_genes')
os.system('perl impose.DNA.on.pep_alignment.pl ' + PATH_TO_OUTPUT + 'core_genes')
os.system('perl rm.gap.pl ' + PATH_TO_OUTPUT + 'core_genes')


print "calculate dS values"
os.system('cp -r /home-user/xjwang/Thermococcus/A501_MA/MA_strains/1_defined_BSC/scripts/YN00 ' + PATH_TO_OUTPUT)
num_dirs = 0
num_files =0
tmp = PATH_TO_OUTPUT + '00_seq_folder'
for root,dirs,files in os.walk(tmp):
        for name in dirs:
                num_dirs += 1
for fn in os.listdir(tmp):
        num_files += 1
num_genome = str(num_files - num_dirs)
print num_genome
os.system('perl cal_dNdS_YN00.pl ' + num_genome + ' ' + PATH_TO_OUTPUT)
os.system('perl summarize_dS.pl ' + PATH_TO_OUTPUT)

os.chdir(PATH_TO_OUTPUT)
ds = []
with open('dS_summary.txt', 'r') as f:
	next(f)
	for line in f:
		tmp = line.split('\t')[1].strip('\n')
		if (tmp == 'nan'):
			print "nan"
		else:
			ds_tmp = float(tmp)
			ds.append(ds_tmp)

mean_ds = np.mean(ds)
median_ds= np.median(ds)
out = open('Pie_S.txt','w')
out.write('mean_dS\tmedian_dS\n');
out.write(str(mean_ds) + '\t' + str(median_ds) + '\n')
out.close()

print "remove temp files..."
os.chdir(PATH_TO_OUTPUT + '00_seq_folder/' + ortho_re)
os.system('rm -r WorkingDirectory/')
os.chdir(PATH_TO_OUTPUT + 'core_genes/')
os.system('rm *nucalign *dna *faa *mafft')

print "Done."

