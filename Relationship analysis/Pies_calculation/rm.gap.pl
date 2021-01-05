#!/usr/bin/perl  

$dir = $ARGV[0];
system "ls $dir/*.nucalign > list.txt";
open FILE, "<", "list.txt";

while(<FILE>)
{
	chomp;
	if(/core_genes\/(\S+)\.nucalign$/)
	{
		open IN, "<", "$dir/$1.nucalign";
		open OUT, ">", "$dir/$1.nucalign.rmgap";
		@ids=();
		@seqs=();
		$c=0;
		while(<IN>)
		{
			chomp;
			if(/^>(\S+)$/)
			{
				$c++;
				push @ids,$1;
				$seq=<IN>;
				chomp $seq;
				push @seqs,$seq;
			}
		}
		$len=length $seq;

		@new;
		for($x=0; $x<$c; $x++)
		{
			$new[$x]=[];
		}

		for($i=0; $i<$len; $i++)
		{
			$flag=1;
			for($x=0; $x<$c; $x++)
			{
				$site=substr $seqs[$x],$i,1;
				if($site eq '-')
				{
					$flag=0;
				}
			}
			if($flag==1)
			{
				for($x=0; $x<$c; $x++)
				{
					$site=substr $seqs[$x],$i,1;
					push @{$new[$x]},$site;
				}
			}
		}

		for($x=0; $x<$c; $x++)
		{
			print OUT ">$ids[$x]\n";
			$new_seq=join '',@{$new[$x]};
			print OUT "$new_seq\n";
		}
		close IN;
		close OUT;
	}
}

close FILE;
system "rm list.txt";
exit 0;
		
