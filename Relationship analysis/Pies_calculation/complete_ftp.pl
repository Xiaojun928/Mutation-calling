#!/usr/bin/perl -w

my $dir =$ARGV[0];
open IN,"$dir/ftp" || die "can't open $!";
while(<IN>)
{
	chomp;
	my @arr=split("/");
	my $ftp=$_."/".$arr[9]."_genomic.fna.gz";
	print $ftp."\n";
}
close IN;

system('rm $dir/ftp');
