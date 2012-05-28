#!/usr/bin/perl

use strict;

if(scalar(@ARGV) != 2)
{
	print "usage: extractClusterSegments.pl <trial number> <num clusters>\n";
	exit(1);
}

my $trial = $ARGV[0];
my $numClusters = $ARGV[1];
my %clusterData = ();
my $idx = 0;
my $FILE = "";
my $fileName = "";
my $timeIdx = "";
my $tmp = "";
my $cluster = "";

for ($idx = 0; $idx < $numClusters; $idx++)
{
	$fileName = "cluster_" . $idx . ".txt";
	open FH, "<$fileName" or die "Unable to open $fileName!";
	foreach (<FH>)
	{
		if($_ =~ /t0(\d)_SEC_(\d+)/)
		{
			if($1 == $trial)
			{
				$clusterData{$2} = $idx;
			}
		}
	}
	close FH;
}

foreach $tmp (sort {$a <=> $b} keys %clusterData)
{
	$cluster = $clusterData{$tmp};
	print $cluster . "\n";
}

