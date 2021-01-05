#!/bin/bash

JAVA_DIR="/home-user/software/jre/bin/"
GATK_DIR="/home-user/software/gatk/latest"
BAMTOOLS_DIR="/home-user/software/local/bin/"

DIR_IN="01_BWA"
DIR_OUT="01_BWA"

BOOT=0

mkdir -p $DIR_OUT # create the output directory

BAMS=($(find $DIR_IN -maxdepth 1 -type f -name "*.sort.bam"))

for BAM in "${BAMS[@]}"
do
	HEAD=$(echo $BAM | sed 's/.*\///g' | sed 's/.sort.bam$//g')
	SUB=$DIR_OUT"/"$HEAD".slm"
	BAM_RD=$DIR_OUT"/"$HEAD".rhead.sam"
	BAM_CLEAN=$DIR_OUT"/"$HEAD".clean.sam"
	BAM_SORT=$DIR_OUT"/"$HEAD".clean.sort.bam"
	BAM_DEDUP=$DIR_OUT"/"$HEAD".clean.sort.dedup.rnd"$BOOT".bam"
	MTX_DEDUP=$DIR_OUT"/"$HEAD".clean.sort.dedup.rnd"$BOOT".mtx"

	# read group
	RGLB=$(echo $HEAD | sed 's/_.*//g' | sed 's/^//g') # Read-Group library (= sample name)
	RGPL="illumina" # Read-Group platform
	RGSM=$(echo $HEAD | sed 's/_.*//g' | sed 's/^//g') # Read-Group sample name
	RGPU=$RGSM # Read-Group platform unit

	echo -e "#!/bin/bash -l\n\n#SBATCH -n 1\n" > $SUB
	echo -e "export PATH=$JAVA_DIR:\$PATH\n" >> $SUB
	echo -e "time $GATK_DIR/gatk AddOrReplaceReadGroups --INPUT $BAM --OUTPUT $BAM_RD --RGLB=$RGLB --RGPL=$RGPL --RGPU=$RGPU --RGSM=$RGSM" >> $SUB
	echo -e "time $GATK_DIR/gatk CleanSam --INPUT $BAM_RD --OUTPUT $BAM_CLEAN" >> $SUB
	echo -e "time $GATK_DIR/gatk SortSam --INPUT $BAM_CLEAN --OUTPUT $BAM_SORT --SORT_ORDER coordinate" >> $SUB
	echo -e "time $GATK_DIR/gatk MarkDuplicates --INPUT $BAM_SORT --OUTPUT $BAM_DEDUP --METRICS_FILE $MTX_DEDUP --REMOVE_DUPLICATES true\n" >> $SUB
	echo -e "time $BAMTOOLS_DIR/samtools index $BAM_DEDUP" >> $SUB
	chmod +x $SUB
	#sbatch $SUB
done

