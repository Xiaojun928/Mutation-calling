#!/bin/bash

REF="Thermococcus_eurythermalis_A501.genome.fna"
FQ_DIR="00_READ"
OUT_DIR="01_BWA"
FRS=($(find $FQ_DIR -maxdepth 1 -type f -name "*_R1.trm.pe.fq.gz"))

# Index database sequences in the FASTA format.
time /home-user/software/bwa/latest/bwa index $REF

mkdir -p $OUT_DIR

# BWA mem
for FR in "${FRS[@]}"
do
  RR=$(echo $FR | sed 's/_R1\./_R2\./g')
  SM=$(echo $FR | sed 's/.*\///g' | sed 's/_R1.trm.pe.fq.gz/.sam/g')
  BM=$(echo $FR | sed 's/.*\///g' | sed 's/_R1.trm.pe.fq.gz/.bam/g')
  ST=$(echo $FR | sed 's/.*\///g' | sed 's/_R1.trm.pe.fq.gz/.sort.bam/g')
  SUB=$(echo $FR | sed 's/.*\///g' | sed 's/_R1.trm.pe.fq.gz/.slm/g')

  echo -e "#!/bin/bash -l\n\n#SBATCH -n 1\n" > $SUB
  echo -e "time /home-user/software/bwa/latest/bwa mem $REF $FR $RR > $OUT_DIR/$SM" >> $SUB
  echo -e "time /home-user/software/local/bin/samtools view -hb -o $OUT_DIR/$BM $OUT_DIR/$SM" >> $SUB
  echo -e "time /home-user/software/local/bin/samtools sort -o $OUT_DIR/$ST $OUT_DIR/$BM" >> $SUB
  echo -e "time /home-user/software/local/bin/samtools index $OUT_DIR/$ST" >> $SUB
  # be careful!
  # echo -e "rm -f $SM $BM" >> $SUB

  chmod +x $SUB
  sbatch $SUB
done
