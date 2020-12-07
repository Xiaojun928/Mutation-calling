#!/usr/bin/perl -w

my $dir = $ARGV[0];
my @list = `ls $dir/dNdS/*dNdS`;

open OUT, ">$dir/dS_summary.txt";
#print OUT "famid\tgenome1\tgenome2\tdS\n";
print OUT "famid\tmean_dS\n";
foreach my $file (@list)
{	
	chomp $file;
	my ($famid)=$file=~/\S+\/(\S+).dNdS/;
	my $ds = 0;
	my $count = 0;
	open IN, $file || die "can't open $!";
	while(<IN>)
	{
	 next if(/gene/);
	 my @a=split(/\t/);
	 #print OUT $famid."\t".$a[0]."\t".$a[1]."\t".$a[5];
	 $ds += $a[5];
	 $count ++;
	}
	close IN;

	my $mean_ds = $ds / $count;
	print OUT $famid."\t".$mean_ds."\n";
}
close OUT;
