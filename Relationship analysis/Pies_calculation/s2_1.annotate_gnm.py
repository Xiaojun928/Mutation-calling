from config import *
import os
import sys
import time


print " ---Pies_Cal_pipeline---"
print " "



#print "Generate ftp for known panmictic population"
#os.system('sed -i "s/\.[0-9]//" ../../gcf_list') ## To ensure all genomes be found
#os.system('sed -i "s/GCF//" ../../gcf_list') ##To ensure all genomes be found
#os.system('for i in `cat ../../gcf_list`;do grep $i /home-user/xjwang/Thermococcus/A501_MA/MA_strains/01_genbank.txt | cut -f 20 >> ../../ftp; done')
#os.system('perl complete_ftp.pl '+ USER_PATH + PIPE_CHAR + USER_PATH + 'ftp.txt')


print "Making folders"
os.system('python folders.py')

#print "Download fna for known panmictic population"
#os.system('wget -i ' + USER_PATH + 'ftp.txt -P ../genomes')

print "select the genomes from the panmictic population identified by PopCOGenT"
os.system('for i in `cat ../../panmictic_gnm_list`;do cp $i' + PATH_TO_OUT + '../genomes')

print "Annotate genomes"
#os.system('gunzip ../genomes/*gz')
os.system('./reannotation.pl ' + PATH_TO_OUT)

print "Parse gbk file"
os.system('rename gbff gbk *gbff')
os.system('perl ../scripts/genbank2fasta4general_v3.pl ./')
os.system('rm *genome *rna')
os.system('rename protein faa *protein')
os.system('mv *gene ' + PATH_TO_OUT + '/nuc')
os.system('mv *faa ' + PATH_TO_OUT + '/00_seq_folder')




