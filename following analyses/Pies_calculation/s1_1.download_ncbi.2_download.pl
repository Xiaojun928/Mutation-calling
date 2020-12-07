#!/usr/bin/perl 
##This script was contributed by Feng Xiaoyuan to download the genomic fna and gff file from NCBI based on the taxonomy_id

#search wanted taxonomy UID in NCBI, e.g. 204455 is the UID for Rhodobacterales
print "Usage: perl ../download_ncbi.2_download.pl tax_id_file\n";
$file = $ARGV[0];
if(!$file){print "Pls input a file containing tax ids\n"}

open IN, "$file";
my @wantUID=<IN>;
chomp @wantUID;
close IN;

open IN, "01_genbank.txt";
	while (<IN>) {
		chomp;
		($gca,$b,$c,$d,$e,$f,$g,$id1,$id2,$id3,$h,$level) = split "\t";
		$real{$gca} = "$id1  $id2  $id3";
#		$wgs{$gca}=$level;
		#print $level."\n";
	}
close IN;

foreach $wantUID (@wantUID) {
	`mkdir Genbank_$wantUID`;
	open OUT, ">Genbank_$wantUID/03_download.sh";
	print OUT "#!/bin/bash\n";
	#open TABLE, ">03_gca_GNM_name.txt";
	`chmod +x Genbank_$wantUID/03_download.sh`;
	
	open IN, "02_gca_taxid_full_name_ftp.txt";
	while (<IN>) {
		chomp;
		($gca,$gcf,$taxid,$full,$real,$name,$ftp) = split "\t";
		unless ($full =~ /;$wantUID;/ or $full =~ /^$wantUID;/) {next}
		#$gnm++;
		if ($ftp =~ /^.*\/(.*?)$/){ $last = $1 }
		#($gnm = $gca) =~ s/GCA_//;
		#$gnm =~ s/\.\d+$//;
		#print OUT "wget -O Genbank_$wantUID/GNM$gnm.gbk.gz '$ftp/$last\_genomic.gbff.gz'\n";
		#print OUT "gzip -d Genbank_$wantUID/GNM$gnm.gbk.gz\n";
		print OUT "wget -P ./ '$ftp/$last\_genomic.fna.gz'\n";
		#print OUT "wget -P ./ '$ftp/$last\_genomic.gff.gz'\n";
		print OUT "gunzip $last\_genomic.fna.gz\n";
		#print OUT "gzip -d ./ $last\_genomic.gff.gz\n";
#		print TABLE "$gca	GNM$gnm	$real{$gca}	$name\n";
	}
}
