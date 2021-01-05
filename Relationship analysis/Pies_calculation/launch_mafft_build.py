from config import *
import re


out = open('mafft.txt','w')
out.seek(0)
#for sp in species:
files = os.listdir(PATH_TO_OUTPUT + '/core_genes/')
files = files[::-1]

for fichier in files:
	if str(fichier).endswith('.faa.mafft'):
		#We've already done it, we'll let them know
		continue
	if fichier+'.align' not in files:
		matched = re.search('faa',fichier)
		if matched:
			out.write(fichier + '\n');

out.truncate()
out.close()
