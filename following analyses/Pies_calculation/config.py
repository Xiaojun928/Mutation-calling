import os
import sys
import platform



############### VARIABLES USERS WILL NEED TO CHANGE ###############


# Where the full database will be built
# This path is only used in the database building version.
# -> does not need to be changed for runner_personal mode
PATH_TO_OUT = "/home-user/xjwang/Thermococcus/A501_MA/MA_strains/1_defined_BSC/04_download_1423/dS_calculation/"
USER_PATH = "/home-user/xjwang/Thermococcus/A501_MA/MA_strains/1_defined_BSC/04_download_1423/"
# your local instalations for the following programs,
# or simply the name of the program if it can be accessed from the command line
# for example:
# 	RAXML_PATH = '/Users/Admin/programs/standard-RAxML-master/raxmlHPC-SSE3'

USEARCH_PATH = '/home-user/xjwang/software/usearch11' 
MAFFT_PATH = '/home-user/software/MAFFT/latest/core/mafft'
MCL_PATH = '/home-user/software/mcl/bin/mcl'
RAXML_PATH = '/home-user/software/RAxML/latest/raxmlHPC-PTHREADS-SSE3'

# command line character to pipe output to a file.
# on Macs, use ' &> ' to pipe more output to the logs/
# on unix use ' > ' to avoid starting all scripts as subprocesses. 
PIPE_CHAR = ' > '



############### Things users will not need to change ###############


def getFolders():
	return ['00_seq_folder','dNdS','core_genes','nuc', 'genomes']

