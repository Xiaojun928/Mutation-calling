#!/bin/bash

DIR_IN="/home-db/pub/ma_db/20180416_hyperthermophilic_archaea/"
DIR_OUT="."

FRS=($(find $DIR_IN -maxdepth 1 -type f -name "*_R1.fastq.gz"))

for FR in "${FRS[@]}"
do
  SUB=$(echo $FR | sed 's/.*\///g' | sed 's/_R1.fastq.gz/.slm/g')
  RR=$(echo $FR | sed 's/_R1/_R2/g')
  ADPT=$(echo $FR | sed 's/.*\///g' | sed 's/_R1.fastq.gz/.adapter/g')

  echo -e "#!/bin/bash -l\n#SBATCH -n 1\n\ntime /home-user/software/bbmap/bbmerge.sh in1=$FR in2=$RR outa=$ADPT reads=-1\n" > $SUB
  chmod +x $SUB
  sbatch --exclude=cl004 $SUB
done

