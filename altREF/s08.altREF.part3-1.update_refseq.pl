#!/usr/bin/env perl

use strict;
use warnings;

use File::Find::Rule;
use Bio::SeqIO;

# parse MERGE.pileup.*.cons files
my $dir = "02_altREF";
my @cons = File::Find::Rule->maxdepth(1)->file->name(qr/MERGE.pileup.*.cons$/)->in($dir);
my %pos2alt = ();
for my $cons (@cons)
{
  open(FH_IN,"<",$cons) or die "Can't open $cons: $!";
  while(my $line = <FH_IN>)
  {
    chomp($line);
    if($line =~ /\!$/)
    {
      my ($chr,$pos,$ref,$overall) = split(/\t/,$line);
      my ($overall_max,$amap,$cmap,$gmap,$tmap) = split(/\|/,$overall);
      $pos2alt{$chr}{$pos}{'ref'} = $ref;
      $pos2alt{$chr}{$pos}{'alt'} = $overall_max;
    }
  }close(FH_IN) or die "Can't close $cons: $!";
}

# make new gbff file
my $gbff_input = "Thermococcus_eurythermalis_A501.gbff";
my $gbff_output = $gbff_input;
$gbff_output =~ s/gbff/new.gbff/g;
my $fasta_output = $gbff_input;
$fasta_output =~ s/gbff/new.genome.fna/g;

my $gbff_in = Bio::SeqIO->new(-file=>"$gbff_input",-format=>"genbank");
my $gbff_out = Bio::SeqIO->new(-file=>">$gbff_output",-format=>"genbank");
my $fasta_out = Bio::SeqIO->new(-file=>">$fasta_output",-format=>"fasta");
while(my $chr = $gbff_in->next_seq)
{
  # change the genomic sequence
  if(exists $pos2alt{$chr->id})
  {
    my $nt = "";
    my @nt = split(//,$chr->seq);
    foreach my $pos (sort{$a<=>$b} keys %{$pos2alt{$chr->id}})
    {
      # error warning
      print "WARNING: REF PRE ".$nt[$pos-1]." != REF POS ".$pos2alt{$chr->id}{$pos}{'ref'}."\n" if $nt[$pos-1] ne $pos2alt{$chr->id}{$pos}{'ref'};
      # mut
      $nt = $pos2alt{$chr->id}{$pos}{'alt'}.join("",@nt[1..$#nt]) if $pos==1;
      $nt = join("",@nt[0..($pos-2)]).$pos2alt{$chr->id}{$pos}{'alt'}.join("",@nt[$pos..$#nt]) if $pos>1;
      @nt = split(//,$nt); # update the sequence after each change
      # error warning
      print "WARNING: LEN PRE != LEN POS\n" if $chr->length != length($nt);
    }
    $chr->seq($nt);
  }
  $gbff_out->write_seq($chr);
  $fasta_out->write_seq($chr);
}
$gbff_in->close();
$gbff_out->close();
