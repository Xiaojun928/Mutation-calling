##This script was contributed by Liao Tianhua (https://github.com/444thLiao) to identify 
##genes with significantly more base-substituition mutations during the MA experiments

import random
import sys
from collections import defaultdict

import pandas as pd
from tqdm import tqdm
import numpy as np

def parse_tab(infile):
    df = pd.read_excel(infile, sheet_name='SNP')

    return df


def count_mut(df,
              mut_type="both",
              region_type="CDS"):
    " count mutation of each gene in single line"
    sub_df = df.loc[df["Type"] == region_type, :]
    assert len(df["Line"].unique()) == 1
    gene2num_mut = defaultdict(int)

    for idx, row in sub_df.iterrows():
        gene = row["Gene Position"].split(' ')[0]
        if mut_type == "both":
            gene2num_mut[gene] += 1
        elif mut_type == "non" and row["Syn/Nonsyn"] == "non":
            gene2num_mut[gene] += 1
        elif mut_type == "syn" and row["Syn/Nonsyn"] == "syn":
            gene2num_mut[gene] += 1
        else:
            pass
    return dict(gene2num_mut)


def bootstraping_test(total_df, num_sampling=1,
                      num_repeat=100000,
                      mut_type="both", region_type="CDS"):
    all_lines = total_df["Line"].unique()
    gb_lines = total_df.groupby("Line")
    line2gene2num_mut = {}
    gene2avg_mut = defaultdict(int)
    for num_line, idx in gb_lines.groups.items():
        sub_df = total_df.loc[idx, :]
        gene2num_mut = count_mut(
            sub_df, mut_type=mut_type, region_type=region_type)
        for g,num_mut in gene2num_mut.items():
            gene2avg_mut[g] += num_mut
        line2gene2num_mut[num_line] = gene2num_mut
    gene2avg_mut = {k:v/96 for k,v in gene2avg_mut.items()}
    
    all_genes = set([_.split(' ')[0]
                     for _ in total_df["Gene Position"] 
                     if type(_) == str])
    
    gene2pval = {}
    for gene in tqdm(all_genes):
        num_st_mean = 0
        avg_mut = gene2avg_mut[gene]
        for _num in range(num_repeat):
            genes = np.random.choice(list(all_genes), num_sampling)
            sum_avg_mut = sum([gene2avg_mut.get(_g, 0)
                               for _g in genes])
            #str1 = "gene %s : sum is %f avg is %f" % (gene,sum_avg_mut,avg_mut)
            #print (str1)
            if avg_mut <= sum_avg_mut:
                num_st_mean += 1
        pval = num_st_mean / num_repeat
        gene2pval[gene] = pval
    return gene2pval



def main(infile, ofile):
    df = parse_tab(infile)
    
    gene2pval = bootstraping_test(df,
                                  num_sampling=1,
                                  num_repeat=100000,
                                  mut_type="both",
                                  region_type="CDS")
    with open(ofile, 'w') as f1:
        f1.write("\n".join(["%s\t%s" % (gene, pval)
                            for gene, pval in gene2pval.items()]))


if __name__ == '__main__':
    PARAMS = sys.argv[1:]
    infile = PARAMS[0]
    ofile = PARAMS[1]
    main(infile, ofile)
