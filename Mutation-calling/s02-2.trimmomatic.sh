#!/bin/bash

jdir="/home-user/software/jre/bin"
trm="/home-user/software/trimmomatic/v0.36/Trimmomatic-0.36" # where trimmomatic is
dir="/home-db/pub/ma_db/20180416_hyperthermophilic_archaea" # change the dir
frs=($(find $dir -maxdepth 1 -type f -name "*_combined_R1.fastq.gz"))

for fr in "${frs[@]}"
do
  sub=$(echo $fr | sed 's/.*\///g' | sed 's/_R1.fastq.gz$/.slm/g')
  rr=$(echo $fr | sed 's/_R1/_R2/g')
  adpt=$(echo $fr | sed 's/.*\///g' | sed 's/_R1.fastq.gz/.adapter/g')
  adpt="00_READ/"$adpt      
  fp_out=$(echo $fr | sed 's/.*\///g' | sed 's/fastq.gz/trm.pe.fq.gz/g') # output_forward_paired.fq.gz
  fs_out=$(echo $fr | sed 's/.*\///g' | sed 's/fastq.gz/trm.se.fq.gz/g') # output_forward_unpaired.fq.gz 
  rp_out=$(echo $rr | sed 's/.*\///g' | sed 's/fastq.gz/trm.pe.fq.gz/g') # output_reverse_paired.fq.gz
  rs_out=$(echo $rr | sed 's/.*\///g' | sed 's/fastq.gz/trm.se.fq.gz/g') # output_reverse_unpaired.fq.gz

  echo -e "#!/bin/bash\n" > $sub
  echo -e "time $jdir/java -jar $trm/trimmomatic-0.36.jar PE -threads 1 -phred33 $fr $rr $fp_out $fs_out $rp_out $rs_out ILLUMINACLIP:$adpt:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MAXINFO:40:0.8 MINLEN:40" >> $sub
  chmod +x $sub
  sbatch $sub
done

