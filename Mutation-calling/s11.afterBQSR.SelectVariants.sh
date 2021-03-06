#!/bin/bash

JAVA_DIR="/home-user/software/jre/bin/"
GATK_DIR="/home-user/software/gatk/latest"

export PATH=$JAVA_DIR:$GATK_DIR:$PATH

DIR_IN="03_GATK"
DIR_OUT="03_GATK"

mkdir -p $DIR_OUT # create the output directory

BOOT=3
REF_GNM="../Thermococcus_eurythermalis_A501.new.genome.fna" # use the updated reference genome

VCFS=($(find $DIR_IN -maxdepth 1 -type f -name "*rnd$BOOT.vcf"))

for VCF in "${VCFS[@]}"
do
  HEAD=$(echo $VCF | sed 's/.*\///g' | sed 's/.vcf$//g')
  SUB=$DIR_OUT"/"$HEAD".slm"
  echo -e "#!/bin/bash\n" > $SUB

  # select SNPs
  SNP=$DIR_OUT"/"$HEAD".snp.vcf"
  echo -e "time $GATK_DIR/gatk SelectVariants --variant $VCF --output $SNP --select-type-to-include SNP --reference $REF_GNM\n" >> $SUB

  # select INDELs
  INDEL=$DIR_OUT"/"$HEAD".indel.vcf"
  echo -e "time $GATK_DIR/gatk SelectVariants --variant $VCF --output $INDEL --select-type-to-include INDEL --reference $REF_GNM\n" >> $SUB

  chmod +x $SUB
  sbatch $SUB
done

