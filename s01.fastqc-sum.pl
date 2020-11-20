#!/usr/bin/env perl

use strict;
use warnings;

use File::Find::Rule;

my $dir = "00_READS";
my @fastqc = File::Find::Rule->maxdepth(1)->directory->name(qr/_combined_R[1-2]+_fastqc$/)->in($dir);

open(FH_OUT,">","Fastqc_sum.tab") or die "Can't open Fastqc_sum.tab: $!";
print FH_OUT "SMP\tBasic\tEncoding\tTotal\tPoor\tLen\tGC\tBaseQ\tTileQ\tSeqQ\tBaseContent\tSeqGC\tBaseN\tLenDis\tDupLev\tOverRep\tAdapter\n";
foreach my $fastqc (sort @fastqc)
{
	my ($smp) = $fastqc =~ /a501-([0-9]+)\_/;
	print FH_OUT $smp;
	open(FH_IN,"<","$fastqc/fastqc_data.txt") or die "Can't open fastqc_data.txt: $!";
	while(my $line = <FH_IN>)
	{
		chomp($line);
		if($line =~ /Basic Statistics\s+(\S+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Encoding\s+(\S+.*)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Total Sequences\s+([0-9]+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Sequences flagged as poor quality\s+([0-9]+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Sequence length\s+([0-9]+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /\%GC\s+([0-9\.]+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Per base sequence quality\s+(\S+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Per tile sequence quality\s+(\S+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Per sequence quality scores\s+(\S+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Per base sequence content\s+(\S+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Per sequence GC content\s+(\S+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Per base N content\s+(\S+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Sequence Length Distribution\s+(\S+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Sequence Duplication Levels\s+(\S+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Overrepresented sequences\s+(\S+)/)
		{
			print FH_OUT "\t$1";
		}elsif($line =~ /Adapter Content\s+(\S+)/)
		{
			print FH_OUT "\t$1\n";
		}
	}close(FH_IN) or die "Can't close FH_IN: $!";
}close(FH_OUT) or die "Can't close Fastqc_sum.tab: $!";
