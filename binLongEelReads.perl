#!/usr/bin/perl -w
use strict;

my $input = pop @ARGV; # fasta

open INPUT, "<$input";

# crop all reads to lengths 270, 275, 280, 285

open O270, ">eel_selected_270.fasta";
open O275, ">eel_selected_275.fasta";
open O280, ">eel_selected_280.fasta";
open O285, ">eel_selected_285.fasta";

my %count;

while (<INPUT>) {
	chomp;
	my $seq = (<INPUT>);
	chomp($seq);
	my $seqlength = length($seq);
	if ($seqlength >= 270) {
		print O270 "$_\n",substr($seq,0,270),"\n";
		$count{270}++;
		if ($seqlength >= 275) {
			print O275 "$_\n",substr($seq,0,275),"\n";
			$count{275}++;
			if ($seqlength >= 280) {
				print O280 "$_\n",substr($seq,0,280),"\n";
				$count{280}++;
				if ($seqlength >= 285) {
					print O285 "$_\n",substr($seq,0,285),"\n";
					$count{285}++;
					}
				}
			}
		}
	}

close INPUT; close O270; close O275; close O280; close O285;
foreach (sort keys %count) {
	print "length $_ $count{$_}\n";
	}
