## Mutation-calling

Mutation-accumulation (MA) experiments followed by whole-genome sequencing (WGS) are considered an approximately unbiased method for mutation determination, as this approach allows all but lethal mutations to accumulate (Ref).

This pipeline was contributed by **Ying Sun** (fuhuisuen@gmail.com) to perform mutation calling using the data from MA/WGS.

Ref: [Eyre-Walker A, Keightley PD. \(2007\). The distribution of fitness effects of new mutations. Nat Rev Genet 8:610–618](https://www.nature.com/articles/nrg2146)

## Relationship analysis
1. After the mutation calling, some genes showing excess base-substitution mutations can be identified using bootstrap_check_mut_hotspots.py, which is contributed by [Liao Tianhua](https://github.com/444thLiao)
2. *Ne* estimation from the Pies of panmictic population
3. Linear regression between *Ne* and mutation rate µ, µ and genome size (GnmSize), GnmSize and *Ne*


