#!/bin/bash

JAVA_DIR="/home-user/software/jre/bin/"
GATK_DIR="/home-user/software/gatk/latest"

DIR_IN1="../01_BWA"
DIR_IN2="03_GATK"
DIR_OUT="03_GATK"
REF_GNM="../Thermococcus_eurythermalis_A501.new.genome.fna" # use the updated reference genome

BOOT=0
SNP_VCF=$DIR_IN2"/Combo.rnd"$BOOT".snp.pseudo.flt.pass.vcf" # produced by s06.bootBQSR-06.VariantFiltration.part2.pl
INDEL_VCF=$DIR_IN2"/Combo.rnd"$BOOT".indel.pseudo.flt.pass.vcf"

mkdir -p $DIR_OUT # create the output directory

# BaseRecalibrator
BAMS=($(find $DIR_IN1 -maxdepth 1 -type f -name "*dedup.rnd$BOOT\.bam"))

for BAM in "${BAMS[@]}"
do
  HEAD=$(echo $BAM | sed 's/.*\///g' | sed "s/.rnd$BOOT\.bam$//g")
  SUB=$DIR_OUT"/"$HEAD".slm"
  OUT=$DIR_OUT"/"$HEAD".rnd"$BOOT".recal" # recalibrated report

  echo -e "#!/bin/bash -l\n\n#SBATCH -n 1\n" > $SUB
  echo -e "export PATH=$JAVA_DIR:\$PATH\n" >> $SUB
  echo -e "time $GATK_DIR/gatk BaseRecalibrator --input $BAM --output $OUT --reference $REF_GNM --known-sites $SNP_VCF --known-sites $INDEL_VCF" >> $SUB

  chmod +x $SUB
  sbatch $SUB
done

