#!/bin/bash

JAVA_DIR="/home-user/software/jre/bin/"
GATK_DIR="/home-user/software/gatk/latest"
SAMTOOLS_DIR="/home-user/software/local/bin"

DIR_IN="../01_BWA"
DIR_OUT="03_GATK"
REF_GNM="../Thermococcus_eurythermalis_A501.new.genome.fna" # use the updated reference genome

BOOT=0
PLOIDY=1

mkdir -p $DIR_OUT # create the output directory

# create reference genome dictionary
REF_DICT=$(echo $REF_GNM | sed 's/fna$/dict/g')
if [[ ! -e $REF_DICT ]]; then
  time $GATK_DIR/gatk CreateSequenceDictionary --REFERENCE $REF_GNM
fi
# create reference genome index
REF_INDX=$REF_GNM".fai"
if [[ ! -e $REF_INDX ]]; then
  time $SAMTOOLS_DIR/samtools faidx $REF_GNM
fi

# create single sample GVCF file
BAMS=($(find $DIR_IN -maxdepth 1 -type f -name "*dedup.rnd$BOOT\.bam"))

for BAM in "${BAMS[@]}"
do
  HEAD=$(echo $BAM | sed 's/.*\///g' | sed "s/.rnd$BOOT\.bam$//g")
  SUB=$DIR_OUT"/"$HEAD".slm"
  OUT=$DIR_OUT"/"$HEAD".rnd"$BOOT".vcf"

  echo -e "#!/bin/bash -l\n\n#SBATCH -n 4\n" > $SUB
  echo -e "export PATH=$JAVA_DIR:\$PATH\n" >> $SUB
  echo -e "time $GATK_DIR/gatk HaplotypeCaller --input $BAM --output $OUT --reference $REF_GNM --sample-ploidy $PLOIDY --native-pair-hmm-threads 4" >> $SUB
  chmod +x $SUB
  sbatch $SUB
done

