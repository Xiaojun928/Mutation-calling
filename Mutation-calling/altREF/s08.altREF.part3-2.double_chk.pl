#!/usr/bin/env perl

use strict;
use warnings;

use Bio::SeqIO;

my %seq = ();
# my $fasta_in = Bio::SeqIO->new(-file=>"Thermococcus_eurythermalis_A501.gbff",-format=>"genbank");
my $fasta_in = Bio::SeqIO->new(-file=>"Thermococcus_eurythermalis_A501.genome.fna",-format=>"fasta");
while(my $chr = $fasta_in->next_seq)
{
  $seq{$chr->id}{'old'} = $chr->seq;
}$fasta_in->close();

# $fasta_in = Bio::SeqIO->new(-file=>"Thermococcus_eurythermalis_A501.new.gbff",-format=>"genbank");
$fasta_in = Bio::SeqIO->new(-file=>"Thermococcus_eurythermalis_A501.new.genome.fna",-format=>"fasta");
while(my $chr = $fasta_in->next_seq)
{
  $seq{$chr->id}{'new'} = $chr->seq;
}$fasta_in->close();

foreach my $chr (sort keys %seq)
{
  my @old = split(//,$seq{$chr}{'old'});
  my @new = split(//,$seq{$chr}{'new'});
  for(my $i=0; $i<=$#old; $i++)
  {
    print "$chr\t". ($i+1) ."\t$old[$i]\t$new[$i]\n" if $old[$i] ne $new[$i];
  }
}
