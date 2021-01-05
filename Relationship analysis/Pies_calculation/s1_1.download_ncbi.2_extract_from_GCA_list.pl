#!/usr/bin/perl 
##This script was contributed by Feng Xiaoyuan to download the genomic fna and gff file from NCBI based on the given GCA list

open IN, "03_gca_list.txt";
while (<IN>) {
	chomp;
	s/\.\d$//;
	s/GCF/GCA/;
	$want{$_} = 1;
}

open IN, "01_genbank.txt";
while (<IN>) {
	chomp;
	($gca,$b,$c,$d,$e,$f,$g,$id1,$id2,$id3) = split "\t";
	$real{$gca} = "$id1  $id2  $id3";
}

open IN, "02_gca_taxid_full_name_ftp.txt";
open OUT, ">03_download.sh";
print OUT "mkdir 04_download\n";
open TABLE, ">03_gca_GNM_name.txt";
`chmod +x 03_download.sh`;
while (<IN>) {
	chomp;
	($gca,$taxid,$full,$real,$name,$ftp) = split "\t";
	($tmp_gca = $gca) =~ s/\.\d$//;
	unless ($want{$tmp_gca}) {next}
	($gnm = $gca) =~ s/GCA_/GNM/;
	$gnm =~ s/\.\d+$//;
	if ($ftp =~ /^.*\/(.*?)$/){ $last = $1 }
	print OUT "wget -O 04_download/$gnm.gbk.gz '$ftp/$last\_genomic.gbff.gz'\n";
	print OUT "gzip -d 04_download/$gnm.gbk.gz\n";
	print OUT "wget -O 04_download/$gnm.fasta.gz '$ftp/$last\_genomic.fna.gz'\n";
	print OUT "gzip -d 04_download/$gnm.fasta.gz\n";
	print OUT "wget -O 04_download/$gnm.faa.gz '$ftp/$last\_protein.faa.gz'\n";
	print OUT "gzip -d 04_download/$gnm.faa.gz\n";
	print TABLE "$gca	$tmp_gca	$gnm	$real{$gca}	$name\n";
}
