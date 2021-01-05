import os
from config import *

for folder in getFolders():
	try:
		os.mkdir(PATH_TO_OUTPUT + folder)
		print "make folder!\n"+PATH_TO_OUTPUT +  folder
	except OSError:
		print "error with folder: "+PATH_TO_OUTPUT +  folder




