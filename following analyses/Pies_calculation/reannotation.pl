#!/usr/bin/perl

use File::Basename;
#re-annot

$dir = $ARGV[0];
`mkdir $dir/reannotation`;
@files = `ls $dir/genomes/*fna`;
foreach $file (@files) {
	chomp $file;
	unless ($file=~/G\S+\.fna/) { next; }
	$ID = basename($file,".fna");
	`mkdir $dir/reannotation/$ID`;
	#re annot here
	$script = "$dir/reannotation/$ID/$ID.sh";
	open OUT, ">$script";
	print OUT "#!/bin/bash\n";
	print OUT "#SBATCH -n 1\n\n";
	
	open IN, "$file";
	open SEQ, ">$dir/reannotation/$ID/$ID.fasta";
	while (<IN>) {
		if (/>(\S+) /) {
			print SEQ ">$1\n";
		}
		else { print SEQ }
	}
#	print OUT "cp 05_annotation/$file/$file.fasta 06_reannotation/$file/$file.fasta\n";
	
	print OUT "prokka --fast --noanno --addgenes --locustag $ID --metagenome --cpus 1 --force --prefix $ID --outdir $dir/reannotation/$ID $dir/reannotation/$ID/$ID.fasta\n";
	`chmod +x $script`;
	`sbatch $script`;
}

