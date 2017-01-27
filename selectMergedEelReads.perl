#!/usr/bin/perl -w
use strict;

# selectMergedEelReads.perl merged.fastq jellyfish.dump readlength jellyfishcutoff maxkmerfraction
# outputs fasta
# ignores reads if more than maxkmerfraction is composed of kmers <jellyfishcutoff

(my $fastq, my $hist, my $readlen, my $cutoff, my $fraction) = @ARGV;

my $fasta = $fastq."_".$readlen."_".$cutoff."_".$fraction.".fasta";

open HIST, "<$hist";
my %kmer;
my $klen = 0;
while (<HIST>) {
	chomp;
	my @x = split /\t/,$_;
	next if ($x[1] < $cutoff);
	$kmer{$x[0]} = $x[1];
	if (not $klen) { $klen = length($x[0]);}
	}
close HIST;
print scalar keys %kmer," kmers indexed\n";

open FASTQ, "<$fastq";
open FASTA, ">$fasta";
open STATS, ">$fasta"."_stats";
my $outcount = 0; my $incount = 0;

while (<FASTQ>) {
	my $seq = (<FASTQ>);
	my $devnull = (<FASTQ>); $devnull = (<FASTQ>);
	chomp($seq);
	if ($seq =~ /^N*([ATCG]*)N*$/) { $seq = $1; } else { next; }
	my $seqlen = 0;
	if (length($seq)) { $seqlen = length($seq); }
	$incount++;
	next if ($seqlen < $readlen);
	next if ($seq =~ /N/);
	$seqlen = $seqlen - $klen +1; 
	my $score = 0; my $count = 0; my $total = 0;
	for (my $i = 0; $i <= $seqlen; $i++) {
		$count++;
		my $currentk = substr($seq,$i,$klen);
		if (exists $kmer{$currentk}) {
			$total += $kmer{$currentk};
			if ($kmer{$currentk} >= $cutoff) {
				$score++;
				}
			}
		elsif (exists $kmer{revcomp($currentk)}) {
			$total += $kmer{revcomp($currentk)};
			if ($kmer{revcomp($currentk)} >= $cutoff) {
				$score++;
				}
			}
		}
	print STATS join("\t",($score/$count,$seqlen,$total)),"\n"; 
	next if ($score/$count > $fraction);
	$outcount++;
	print FASTA ">$outcount\n$seq\n";
	}

close FASTQ;
close FASTA;
print "$outcount reads approved out of $incount\n";

exit;
		







sub revcomp {
	my $sq = shift(@_);
	if ((length $sq) eq 0) {return "";}
	$sq =~ tr/ATCGN/TAGCN/;
	return (scalar reverse($sq));
}

