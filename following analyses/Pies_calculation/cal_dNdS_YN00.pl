#!/usr/bin/perl -w
###extract dN dS results from the YN00 method
  my $num_genes=$ARGV[0];
  my $dir = $ARGV[1];

  opendir DH,"$dir/core_genes" or die "can't opendir $!";
  my @list= grep{/nucalign.rmgap$/ && -f "$dir/core_genes/$_"} readdir(DH);
  closedir DH;
 
 foreach my $file(@list)
 {
 	
	my ($famid)=$file=~/(OG\S+).nucalign/;
	open DNDS,">$dir/dNdS/$famid.dNdS" or die "can't open";
	print DNDS "gene1\tgene2\tN\tS\tdN\tdS\n";
	chomp $file;
	print $file."\n";
	open IN,"$dir/core_genes/$file" or die "can't open $!";	
####transfer as phylip format
	open OUT,"> $dir/YN00/seqs.phylip";
	my $len=0;
	while(<IN>)
	{
	  chomp;
	 #if(/>\S+\|(\S+)\|.*$/ && $len == 0)
	 if(/>\S+(genomic_\S+)$/ && $len == 0)
	 {
	  my $name =$1;
	  my $line=<IN>;
	  $line=~s/\s//g;
	  $len=length($line);
	  print OUT "$num_genes $len\n";
	  print OUT "$name\n$line\n";
	 }	
	 elsif(/>\S+(genomic_\S+)$/ && $len != 0)
	 {
	  my $name=$1;
	  my $line=<IN>;
	  $line=~s/\s//g;
	  print OUT "$name\n$line\n";
	 }
	}
	
	close IN;
	close OUT;
#####run YN00 
	chdir("$dir/YN00");
	system("/home-user/software/paml/v4.9/paml4.9e/bin/yn00 yn00.ctl");	
	chdir("$dir");
#### extract YN00 output
	open YIN,"$dir/YN00/yn.out" or die "can't open $!";
	my @dnds;
	my @names;
	while(<YIN>)
	{
	  if(/^\s+\d+\s+\d+\s+(\S+)\s+(\S+)\s+\S+\s+\S+\s+\S+\s+(\S+)\s+\+\-\s+\S+\s+(\S+)\s+\+\-/) 
	  {
		push @dnds,"$2\t$1\t$3\t$4";   ### keep the number of sits and dN, dS in the same order
		#print "$2\t$1\t$3\t$4";
	  }
	  if(/vs/)
	  {
		$_=~/\((\S+)\).*\((\S+)\)/;  ###modify the regular expression based on you data
		push @names,"$1\t$2";
		#print "$1\t$2\n";
	  }
	}
	close YIN;
	for(my $i=0;$i<=$#names;$i++)
	{
		print DNDS $names[$i]."\t".$dnds[$i]."\n";
	}
 }
	close DNDS;
