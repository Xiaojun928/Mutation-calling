#!/usr/bin/env perl

use strict;
use warnings;

use File::Find::Rule;

my $pup = $ARGV[0];
my $out = $pup.".cons";

open(PUP_IN,"<",$pup) or die "Can't open $pup: $!";
open(FH_OUT,">",$out) or die "Can't open $out: $!";
while(my $line = <PUP_IN>)
{
  chomp($line);
  my ($chr,$pos,$ref,$depth,$map,$qual) = split(/\t/,$line);
  my @map = split(//,$map);

  my %overall = ();

  for(my $i=0; $i<=$#map; $i++)
  {
    if($map[$i] eq "^")
    {
      $i++; # skip the character after "^"; the mapping quality
    }elsif($map[$i] =~ /[+-]+/)
    {
      print "$chr\t$pos\t$map[$i]\t";
      $i++;
      my $len = "";
      while($map[$i] =~ /[0-9]+/)
      {
        $len .= $map[$i];
        $i++
      }
      print "$len\t".join("",@map[$i..$i+$len-1]),"\n";
      $i += $len-1;
    }elsif($map[$i] =~ /[\.\,ACGTacgt]+/)
    {
      $overall{$ref}{'f'}++ if $map[$i] eq ".";
      $overall{$ref}{'r'}++ if $map[$i] eq ",";
      $overall{$ref}{'all'}++ if $map[$i] eq "." || $map[$i] eq ",";
      $overall{uc($map[$i])}{'f'}++ if $map[$i] =~ /[ACGT]+/;
      $overall{uc($map[$i])}{'r'}++ if $map[$i] =~ /[acgt]+/;
      $overall{uc($map[$i])}{'all'}++ if $map[$i] =~ /[ACGTacgt]+/;
    }
  }

  my $afcnt = (exists $overall{'A'} && exists $overall{'A'}{'f'})? $overall{'A'}{'f'}:0;
  my $arcnt = (exists $overall{'A'} && exists $overall{'A'}{'r'})? $overall{'A'}{'r'}:0;
  my $cfcnt = (exists $overall{'C'} && exists $overall{'C'}{'f'})? $overall{'C'}{'f'}:0;
  my $crcnt = (exists $overall{'C'} && exists $overall{'C'}{'r'})? $overall{'C'}{'r'}:0;
  my $gfcnt = (exists $overall{'G'} && exists $overall{'G'}{'f'})? $overall{'G'}{'f'}:0;
  my $grcnt = (exists $overall{'G'} && exists $overall{'G'}{'r'})? $overall{'G'}{'r'}:0;
  my $tfcnt = (exists $overall{'T'} && exists $overall{'T'}{'f'})? $overall{'T'}{'f'}:0;
  my $trcnt = (exists $overall{'T'} && exists $overall{'T'}{'r'})? $overall{'T'}{'r'}:0;
  my $tot = $afcnt+$arcnt+$cfcnt+$crcnt+$gfcnt+$grcnt+$tfcnt+$trcnt;
  
  if($tot>0)
  {
    my ($overall_max) = sort{$overall{$b}{'all'}<=>$overall{$a}{'all'}} keys %overall;
    my $flg = ($ref ne $overall_max && $overall{$overall_max}{'all'}/$tot>=0.5)? "!":"";
    print FH_OUT "$chr\t$pos\t$ref\t$overall_max|A($afcnt:$arcnt)|C($cfcnt:$crcnt)|G($gfcnt:$grcnt)|T($tfcnt:$trcnt)$flg\n";
  }
}
close(PUP_IN) or die "Can't close $pup: $!";
close(FH_OUT) or die "Can't close $out: $!"; 

