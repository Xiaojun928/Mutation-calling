#!/usr/bin/perl 
## This script was contributed by Feng Xiaoyuan to download the lastest taxdump from the NCBI


print "Usage: perl download_ncbi.pl download|update\n";
($update) = @ARGV;

#download ncbi taxonomy and genbank list
if ($update eq "download") {
	use POSIX;
	$download_time = strftime "%Y%m%d", localtime;
	`wget -O 00_taxonomy.$download_time.tar.gz 'ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz'`;
	`tar zxvf 00_taxonomy.*.tar.gz`;
	`mv names.dmp 01_taxonomy.names.txt`;
	`mv nodes.dmp 01_taxonomy.nodes.txt`;
	`rm citations.dmp delnodes.dmp division.dmp gc.prt gencode.dmp merged.dmp readme.txt`;
	`wget -O 01_genbank.txt 'ftp://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_genbank.txt'`;
	`wget -O 01_refseq.txt 'ftp://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_refseq.txt'`;
	`dos2unix 01_genbank.txt 01_refseq.txt 01_taxonomy.names.txt 01_taxonomy.nodes.txt`;
	$update = "update";
}

if ($update eq "update") {
	#make taxonomy hash list %taxonomy_full
	$root = 1;
	open IN, "01_taxonomy.nodes.txt";
	while (<IN>) {
		chomp;
		if (/^(\d+)\t\|\t(\d+)\t/) {($child,$parent) = ($1,$2)}
		$taxonomy_parent{$child} = $parent;
	}
	open IN, "01_taxonomy.nodes.txt";
	open OUT, ">02_taxonomy_full.txt";
	while (<IN>) {
		chomp;
		if (/^(\d+)\t\|\t(\d+)\t/) {($child,$parent) = ($1,$2)}
		if ($child == $root){next}
		for ($taxonomy_full="",$temp=$child;$temp != $root;$temp=$taxonomy_parent{$temp}) {
			$taxonomy_full .= "$temp;;";
		}
		print OUT "$child\t$taxonomy_full\n";
	$taxonomy_full{$child} = $taxonomy_full;
	}
	
	#make taxonomy name list %taxonomy_name
	open IN, "01_taxonomy.names.txt";
	open OUT, ">02_taxonomy_name.txt";
	while (<IN>) {
		unless (/scientific name/) {next}
		chomp;
		if (/^(\d+)\t\|\t(.+?)\t/) {($node,$name) = ($1,$2)}
		print OUT "$node\t$name\n";
		$taxonomy_name{$node} = $name;
	}
	
	#output
	open IN, "01_genbank.txt";
	<IN>;<IN>;
	open OUT, ">02_gca_taxid_full_name_ftp.txt";
	while (<IN>) {
		@array = split "\t";
		($gca, $gcf, $taxid, $ftp) = ($array[0], $array[17], $array[5], $array[19]);
		unless ($ftp =~ /ftp/) {next}
		unless ($gcf =~ /GCF/) {next}
		$taxonomy_real = "";
		@taxonomy_real = split ";;", $taxonomy_full{$taxid};
		@taxonomy_real = reverse @taxonomy_real;
		foreach $temp (@taxonomy_real) { $taxonomy_real .= "$taxonomy_name{$temp};;" }
		print OUT "$gca	$gcf	$taxid	$taxonomy_full{$taxid}	$taxonomy_real	$taxonomy_name{$taxid}	$ftp\n";
	}
}
