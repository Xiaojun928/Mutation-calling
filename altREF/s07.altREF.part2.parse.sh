#!/bin/bash

rm -f *.slm

pups=($(find 02_altREF -maxdepth 1 -type f -name "MERGE.pileup.*"))

for pup in "${pups[@]}"
do
  sub=$pup".slm"
  echo -e "#!/bin/bash\n" > $sub
  echo -e "time ./s07.cons.MergeBam.part2.parse.pl $pup" >> $sub
  chmod +x $sub
  sbatch $sub
done
