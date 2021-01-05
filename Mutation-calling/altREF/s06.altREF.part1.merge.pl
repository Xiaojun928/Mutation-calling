#!/usr/bin/env perl

use strict;
use warnings;

use Bio::SeqIO;
use List::Util qw(min);

my $samtools_path = "/home-user/software/local/bin";

my $dir_in = "01_BWA";
my $ref_gnm = "Thermococcus_eurythermalis_A501.genome.fna";

# merge
my $list = "bams.list";
my $merge = "MERGE.bam";
my $sub = "merge.slm";
system("ls -l $dir_in/*rnd0.bam | sed 's/.* //g' > $list");
open(SUB_OUT,">",$sub) or die "Can't open $sub: $!";
print SUB_OUT "#!/bin/bash -l\n#SBATCH -n 32\n\n";
print SUB_OUT "time $samtools_path/samtools merge -b $list --reference $ref_gnm --threads 32 $merge\n";
print SUB_OUT "time $samtools_path/samtools index $merge\n";
close(SUB_OUT) or die "Can't close $sub: $!";
system("chmod +x $sub");
#system("sbatch $sub");

# mpile; split
my $step = 20000;
my $fasta_in = Bio::SeqIO->new(-file=>"$ref_gnm",-format=>"fasta");
while(my $seq = $fasta_in->next_seq)
{
  for(my $start=1; $start<=$seq->length; $start+=$step)
  {
    my $end = min($start+$step-1,$seq->length);
    my $sub = "$start.".$seq->id.".slm";
    my $out = "MERGE.pileup.".$seq->id.".$start";
    open(SUB_OUT,">",$sub) or die "Can't open $sub: $!";
    print SUB_OUT "#!/bin/bash -l\n#SBATCH -n 1\n\n";
    print SUB_OUT "time $samtools_path/samtools mpileup -C50 -d 10000000 --fasta-ref $ref_gnm --min-MQ 20 --min-BQ 20 --output $out $merge -r ".$seq->id.":$start-$end\n";
    close(SUB_OUT) or die "Can't close $sub: $!";
    system("chmod +x $sub");
    #system("sbatch $sub");
  }
}


