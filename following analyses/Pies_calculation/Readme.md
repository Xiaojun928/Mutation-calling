To estimate the effective population size (*Ne*), we followed the formular:

Pies =2×Ne×µ

where Pies is the nucleotide diversity at silent (synonymous) sites among randomly sampled members of a species and µ is the unbiased spontaneous mutation rate. 
> Microbial species commonly harbor genetically structured populations, which has a major influence on Pies and thus *Ne* estimation. 
It is therefore important to identify strains allowed for free recombination when calculating *Ne* for a prokaryotic species.
The program [PopCOGenT](https://github.com/philarevalo/PopCOGenT) can identify members from a prokaryotic species constituting a panmictic population. 

ref: [Unexpectedly high mutation rate of a deep-sea hyperthermophilic anaerobic archaeon.](https://www.biorxiv.org/content/10.1101/2020.09.09.287623v2)

This pipeline was created to calculate the Pies for a prokaryotic species with panmictic population dataset. In total, three (or four) steps were included.
- step1. Get the public genome afflicated with the same named species from NCBI
  - 1.1 search and downlaod the gbff/gbk files
- step2. Run the [PopCOGenT](https://github.com/philarevalo/PopCOGenT) to get a panmictic population with as many as possible genomes
  - 1.1 run the PopCOGenT for all avaliable genomes and choose the main cluster with most genomes. (Ps.Only one strain from each clonal complex would be maintained)
  - 1.2 annotate the genomes (optional)
- step3. Pies calculation for the panmictic population
  - 3.1 Orthologous gene families identification
  - 3.2 Alignemnt of amino acid sequences and generation of nucleotide alignments
  - 3.3 Pairwise ds (synonymous substitution rate) calculation and summary of Pies
- step4. Bootstrap resampling for the populations with less than 10 genomes to calculate the Pies (optional)
  - 4.1 resample (with replacemnet) the genomes from the panmictic population
  - 4.2 repeat the step3
  

