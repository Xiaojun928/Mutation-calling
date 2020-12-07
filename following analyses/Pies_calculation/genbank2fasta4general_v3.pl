#!/usr/bin/perl
# perl genbank2fasta4general.pl /path/to/gbk/files

# please make sure that your gbk file is in the standard format
# which should include "translation" feature for each CDS
# as well as the "ORIGIN" part with genomic sequences at the end;
# when you download genbank files from NCBI, please go to the "FASTA" page
# and then download "GenBank (full)"; otherwise the gbk file downloaded from 
# the "GenBank" page is lack of sequences mentioned above;
# and as to some newly assembled genomes, 
# some manual work might be needed to modify the gbk files

# this script was written to 
# (1) extract gene dna and protein sequences
# (2) translation frame checking for the dna sequences

# log
# 04/20/2016: Underscore signs in strain name will be kept (not deleted).

use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;
use Bio::SeqUtils;
use List::Util qw(min max);

my $dir = ($ARGV[0])? $ARGV[0]:"./";
my @embls = <$dir/*.embl>;

foreach my $embl_input (sort @embls)
{
	my $genbank_output = $embl_input;
	$genbank_output =~ s/embl/gbk/g;
	my $in = Bio::SeqIO->new(-file=>"$embl_input",-format=>"embl");
	my $out = Bio::SeqIO->new(-file=>">$genbank_output",-format=>"genbank");
	while(my $seq = $in->next_seq)
	{
		$out->write_seq($seq);
	}
}

my @gbks = <$dir/*.gbk>;

open ERROR, ">MIS_TRANSLATION_FRAME.report" or die $!; # report dna sequences that have problematic translation frame

foreach my $input (@gbks){

	# prepare output file names
	my $organism = `grep \"\/organism=\" $input -m1`; chomp($organism);
	if($organism !~ /\"$/){
                my $nline=`grep \"\/organism=\" $input -m1 -A1|tail -n1`;
                $nline=~s/^\s+//g;chomp($nline);
                $organism .= " ".$nline;
        }
	($organism) = $organism =~ /\"(.*)\"/;
	my $strain = `grep \"\/strain=\" $input -m1 |cut -d\"\\"\" -f2`; chomp($strain);
	$organism = (index($organism,$strain)<0 && $strain!~/[;=]+/)? $organism." ".$strain:$organism;
	$organism =~ s/\.+/\_/g;
	$organism =~ s/[^a-zA-Z0-9\-\_]+/\_/g;
	$organism =~ s/\_+/_/g;

	my $geno_out = $dir."/".$organism.".genome";
	my $prot_out = $dir."/".$organism.".protein";
	my $gene_out = $dir."/".$organism.".gene";
	my $rrna_out = $dir."/".$organism.".rrna";
	my $trna_out = $dir."/".$organism.".trna";

	# create output object
	system("sed '/BioProject/d' $input > tmp.gbk");
	system("sed -i '/^CONTIG/,/^ORIGIN/{//!d}' tmp.gbk;sed -i '/^CONTIG/d' tmp.gbk"); #sed '/PATTERN-1/,/PATTERN-2/{//!d}' input
	my $in = Bio::SeqIO->new(-file=>"tmp.gbk",-format=>"genbank");
	my $GENO_OUT =  Bio::SeqIO->new(-file=>">$geno_out",-format=>"fasta");
	open GENE_OUT, ">$gene_out" or die $!;
	open PROT_OUT, ">$prot_out" or die $!;
	open RRNA_OUT, ">$rrna_out" or die $!;
	open TRNA_OUT, ">$trna_out" or die $!;

	# record the sequences with translation frame error
	my $error_count=0;
	my $error_info="";

	while(my $geno_seq_obj = $in->next_seq){
	
		# output genomic sequences
		$GENO_OUT->write_seq($geno_seq_obj);
		
		# parse features
		for my $feat_obj ($geno_seq_obj->get_SeqFeatures){

			if($feat_obj->primary_tag eq 'CDS'){
				
				my @gene_tags = $feat_obj->get_all_tags;
				my %gene_tags_hash = map { $_ => 1 } @gene_tags;

				if(!exists $gene_tags_hash{"pseudo"} && !exists $gene_tags_hash{"pseudogene"}){
			
					# get sequences and gene location information
					my $gene_seq = $feat_obj->spliced_seq->seq;
					my $gene_strand = $feat_obj->strand;
					my $gene_start = $feat_obj->start;
					my $gene_end = $feat_obj->end;
					my $gene_loc = ($gene_strand == 1)? $geno_seq_obj->id.":".$gene_start."..".$gene_end:$geno_seq_obj->id.":c(".$gene_start."..".$gene_end.")";
					my ($prot_seq) = $feat_obj->get_tag_values("translation");

					# get identifiers
					my ($gene_name) = (exists $gene_tags_hash{"gene"})? $feat_obj->get_tag_values("gene"):("NA");
					my ($gene_tag) = (exists $gene_tags_hash{"locus_tag"})? $feat_obj->get_tag_values("locus_tag"):$gene_name;
					my ($pr_name) = (exists $gene_tags_hash{"protein_id"})? $feat_obj->get_tag_values("protein_id"):$gene_name;
					my $new_id = $organism."|".$gene_tag."|".$pr_name; $new_id =~ s/\ /\_/g;
			
					# get description
					my $prot_desc = "";
					if(exists $gene_tags_hash{"product"}){
						($prot_desc) = $feat_obj->get_tag_values("product");
					}else{
						($prot_desc) = (exists $gene_tags_hash{"note"})? $feat_obj->get_tag_values("note"):"NA";
					}

					# check translation frames
					if(length($gene_seq)%3 == 0){ # dna sequence without translation frame error
						print GENE_OUT ">".$new_id." [".$gene_loc."] [".$prot_desc."]\n".$gene_seq."\n";
						print PROT_OUT ">".$new_id." [".$gene_loc."] [".$prot_desc."]\n".$prot_seq."\n";
					}else{	# dna sequence with translation frame error
						# error information update
						$error_count++;
						$error_info .= $new_id.": dna_len=".length($gene_seq)." 3*prot_len=".(3*length($prot_seq));
					
						my $gene_obj = Bio::Seq->new(-id=>$new_id,-seq=>$gene_seq,-description=>$prot_desc);
							
						# translate the dna sequence in 3 frames (forward strand)
						my @trans_peps=Bio::SeqUtils->translate_3frames($gene_obj);
						# figure out in which frame the dna sequence is translated
						my $lcs_trans=$trans_peps[0]; # translation (protein) object
						my $lcs_len=0; # the length of the longest common sequence between our dna translation and ncbi protein
						foreach my $trans_pep (@trans_peps){
							# to save time, only compare the first 100 amino acids in the translation 
							# unless it is shorter than that, since the lcs subroutine is an exhaustive search method
							# 100 amino acid is supposed to be enough to figure out the right translation
							my $tmp_lcs=lcs(substr($trans_pep->seq,0,min(100,$trans_pep->length)),$prot_seq) or die();
							# if the length of the latest longest common sequence is longer than the previous, update the record
							length($tmp_lcs)>$lcs_len and ($lcs_trans,$lcs_len)=($trans_pep,length($tmp_lcs));
						}
						
						# trim the dna sequence (remove bases before the ORF based on the translation frame start postion 
						# and bases after the ORF, but keep the start and stop condons if any)
						# or add missing based based on genomic sequence information
						my ($sub_gene_start)=$lcs_trans->id=~/-([012])F/; #figure out the start position of the ORF
						my $sub_gene_seq=""; # to record the dna sequnce after trimming or extension
						my $sub_prot_seq=""; # to record the corresponding protein translation after dna modification
						# start dna sequence correction
						if((length($gene_seq)-$sub_gene_start) >= (3*length($prot_seq))){ 
							# if the dna sequence contains the whole ORF,
							# just trim the extra based from the head and the tail of the dna sequence
							for(my $residule=0;$residule<=(length($gene_seq)-3*length($prot_seq)-$sub_gene_start);$residule++){
								my $sub_gene_len=length($gene_seq)-$residule-$sub_gene_start;
								if($sub_gene_len%3 == 0){
									$sub_gene_seq=substr($gene_seq,$sub_gene_start,$sub_gene_len);
									last;
								}
							}
						}else{	
							# if the dna sequence contains partial ORF
							if($gene_strand eq '-1'){
								$sub_gene_seq=substr($geno_seq_obj->seq,max(0,$gene_end-1-$sub_gene_start-3*length($prot_seq)),min($gene_end-$sub_gene_start,3*length($prot_seq)));
								$sub_gene_seq=reverse($sub_gene_seq);
								$sub_gene_seq=~tr/ACGTacgt/TGCAtgca/;
							}else{
								$sub_gene_seq=substr($geno_seq_obj->seq,($gene_start-1+$sub_gene_start),(3*length($prot_seq)));
							}
							if(length($sub_gene_seq)%3 != 0 ){
								for(my $residule=1;$residule<=2;$residule++){
									if((length($sub_gene_seq)-$residule)%3 == 0){
										$sub_gene_seq=substr($sub_gene_seq,0,(-1)*$residule);
										last;
									}
								}
							}
						}
			
						$error_info.="; new dna_len=".length($sub_gene_seq)."\n";
			
						my $new_gene=Bio::Seq->new(-id=>$new_id,-seq=>$sub_gene_seq);
	
						# after trimming, the translation frame should all be 5'->3' 1st frame.
						# translate the trimmed dna sequence and compare with the existing ncbi protein
						my @new_trans_peps=Bio::SeqUtils->translate_3frames($new_gene);
						my $new_trans_pep=$new_trans_peps[0];
						($sub_prot_seq)=$new_trans_pep->seq=~/([^\*]+)\*?$/;
						if($sub_prot_seq ne $prot_seq){
							$error_info.="WARNING: protein translation not match the original one!\n";
							$error_info.=$new_id."\n".$sub_prot_seq."\n".$prot_seq."\n";
						}

						print GENE_OUT ">".$new_id." [".$gene_loc."] [".$prot_desc."]\n".$sub_gene_seq."\n";
						print PROT_OUT ">".$new_id." [".$gene_loc."] [".$prot_desc."]\n".$sub_prot_seq."\n";

					} # the end of if the length of dna sequence is not a multiple of 3
	
				} # not a pseudo CDS

			}elsif($feat_obj->primary_tag eq 'rRNA'){
				
				# get sequencces
				my $rrna_seq = $feat_obj->spliced_seq->seq;
				my $gene_strand = $feat_obj->strand;
				my $gene_start = $feat_obj->start;
				my $gene_end = $feat_obj->end;
				my $gene_loc = ($gene_strand == 1)? $geno_seq_obj->id.":".$gene_start."..".$gene_end:$geno_seq_obj->id.":c(".$gene_start."..".$gene_end.")";

				# get identifiers
				my @gene_tags = $feat_obj->get_all_tags;
				my %gene_tags_hash = map { $_ => 1 } @gene_tags;
				my ($gene_name) = (exists $gene_tags_hash{"gene"})? $feat_obj->get_tag_values("gene"):("NA");
				my ($gene_tag) = (exists $gene_tags_hash{"locus_tag"})? $feat_obj->get_tag_values("locus_tag"):$gene_name;
				my $new_id = $organism."|".$gene_tag; $new_id =~ s/\ /\_/g;
				
				# get description
				my ($rrna_desc)=(exists $gene_tags_hash{"product"})? $feat_obj->get_tag_values("product"):"NA";

				# create output sequences
				print RRNA_OUT ">".$new_id." [".$gene_loc."] [".$rrna_desc."]\n".$rrna_seq."\n";

			}elsif($feat_obj->primary_tag eq 'tRNA'){

				# get sequencces
				my $trna_seq = $feat_obj->spliced_seq->seq;
				my $gene_strand = $feat_obj->strand;
				my $gene_start = $feat_obj->start;
				my $gene_end = $feat_obj->end;
				my $gene_loc = ($gene_strand == 1)? $geno_seq_obj->id.":".$gene_start."..".$gene_end:$geno_seq_obj->id.":c(".$gene_start."..".$gene_end.")";

				# get identifiers
				my @gene_tags = $feat_obj->get_all_tags;
				my %gene_tags_hash = map { $_ => 1 } @gene_tags;
				my ($gene_name) = (exists $gene_tags_hash{"gene"})? $feat_obj->get_tag_values("gene"):("NA");
				my ($gene_tag) = (exists $gene_tags_hash{"locus_tag"})? $feat_obj->get_tag_values("locus_tag"):$gene_name;
				my $new_id = $organism."|".$gene_tag; $new_id =~ s/\ /\_/g;

				# get description
				my ($trna_desc)=(exists $gene_tags_hash{"product"})? $feat_obj->get_tag_values("product"):"NA";

                                # create output sequences
				print TRNA_OUT ">".$new_id." [".$gene_loc."] [".$trna_desc."]\n".$trna_seq."\n";

                        }


		}#end of get_SeqFeatures

	}# end of while $gbk->next_seq

	system("rm tmp.gbk");

	if($error_count > 0){
		$error_info=$organism.": $error_count\n".$error_info."//\n\n";
		$error_info=~s/^.*\//@/g;
		print ERROR $error_info;
	}

	close(GENE_OUT);
	close(PROT_OUT);

}# end of foreach @gbks

close(ERROR);

sub lcs { # longest common substring
	my ($strA,$strB)=@_;
	$strA=~s/\*/\./g;
	$strB=~s/\*/\./g;
	my @matches=();
	for my $start (0..length $strA){
		for my $sub_len ($start+1..length $strA){
				my $substr=substr($strA,$start,$sub_len);
				push @matches, $strB=~m[($substr)]g;
			}
	}
	my $len=0;
	my $longest="NA";
	length > $len and ($longest, $len) = ($_, length) for @matches;
	return $longest;
}
