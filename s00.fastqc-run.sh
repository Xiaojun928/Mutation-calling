#!/bin/bash

DIR_IN="/home-db/pub/ma_db/20180416_hyperthermophilic_archaea/" # change the dir
DIR_OUT="."

FQS=($(find $DIR_IN -maxdepth 1 -type f -name "*.fastq.gz"))

for FQ in "${FQS[@]}"
do
  SUB=$(echo $FQ|sed 's/.*\///g'|sed 's/gz$/lsf/g')
  echo -e "#!/bin/bash -l\n#SBATCH -n 1\n\ntime /home-user/software/fastqc/latest/fastqc -o $DIR_OUT $FQ" > $SUB
  chmod +x $SUB
  sbatch --exclude=cl004 $SUB # node cl004 has problem with java
done
