#!/usr/bin/perl

# Assembles air, ASIC, CPU and memory temperatures for each node in the
# cluster at each point in time
use strict;
use Time::Local;

# Start by enumerating the list of systems.  There is a set of 21 nodes
# shared in common by all readings.  We'll use one of those.  
my $enumPath = "ASIC";

my $systemName = "";
my %systemList = ();
my @result = `ls -1 $enumPath`;
my $entry = "";
my $i = 0;
my ($FH, $OUTFH);
my $tmpLine = "";
my @csvLines = ();
my $counter = 0;
my $fileName ="";
my $systemId = 1;

foreach $entry (@result)
{
   chomp($entry);
   $entry =~ /A1_t01_ASIC_(\w+)_ASIC/;
   $systemName = $1;
   $systemList{$systemName} = 0;
}

print "A total of " . keys(%systemList) . " systems were found.\n";

foreach $systemName (keys(%systemList))
{
	# Steps:
	# - create a new csv for the key.
	# - Determine system time of the ASIC1 temperature reading
	# - Convert that time into a double format
	# - For each of the files associated with that system, grab the
	#   non-time value and append it to the current line with a comma
	#   separator
	@csvLines = ();
	for($i=0;$i<3;$i++)
	{
		$fileName = "ASIC/LD_even_A1_t0" . ($i+1) . "_ASIC_" . $systemName . "_ASIC1Temp.csv";
		# Get the time list
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			my $localTime = timelocal($6, $5, $4, $3, $2, $1);
			push @csvLines, [$localTime, $7];
		}
		close(FH);
	}
	
	$counter = 0;	
	for($i=0;$i<3;$i++)
	{
		# Now, go through each relevant file and extract the appropriate data.
		$fileName = "ASIC/LD_even_A1_t0" . ($i+1) . "_ASIC_" . $systemName . "_ASIC1TempStatus.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);		
	}
	
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "ASIC/LD_even_A1_t0" . ($i+1) . "_ASIC_" . $systemName . "_ASIC2Temp.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);	
	}
	
	$counter = 0;
	for($i=0;$i<3;$i++)
	{		
		$fileName = "ASIC/LD_even_A1_t0" . ($i+1) . "_ASIC_" . $systemName . "_ASIC2TempStatus.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);			
	}
	
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "ASIC/LD_even_A1_t0" . ($i+1) . "_ASIC_" . $systemName . "_ASIC3Temp.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);	
	}
			
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "ASIC/LD_even_A1_t0" . ($i+1) . "_ASIC_" . $systemName . "_ASIC3TempStatus.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);	
	}
		
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "ASIC/LD_even_A1_t0" . ($i+1) . "_ASIC_" . $systemName . "_QualityCode.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);	
	}
	
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "Air/LD_even_A1_t0" . ($i+1) . "_NodeAir_" . $systemName . "_AirExchangeTemp.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);	
	}
		
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "Air/LD_even_A1_t0" . ($i+1) . "_NodeAir_" . $systemName . "_AirExchangeTempStatus.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);		
	}
		
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "Air/LD_even_A1_t0" . ($i+1) . "_NodeAir_" . $systemName . "_AirInTemp.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);
	}
		
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "Air/LD_even_A1_t0" . ($i+1) . "_NodeAir_" . $systemName . "_AirInTempStatus.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);
	}
		
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "Air/LD_even_A1_t0" . ($i+1) . "_NodeAir_" . $systemName . "_QualityCode.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);
	}
	
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "CPU/LD_even_A1_t0" . ($i+1) . "_CPU_" . $systemName . "_CPU0Temp.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);				
	}	
	
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "CPU/LD_even_A1_t0" . ($i+1) . "_CPU_" . $systemName . "_CPU0TempStatus.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);			
	}
		
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "CPU/LD_even_A1_t0" . ($i+1) . "_CPU_" . $systemName . "_CPU1Temp.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);				
	}
	
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "CPU/LD_even_A1_t0" . ($i+1) . "_CPU_" . $systemName . "_CPU1TempStatus.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);	
	}
		
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "CPU/LD_even_A1_t0" . ($i+1) . "_CPU_" . $systemName . "_QualityCode.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);	
	}	
	
	for(my $j=0; $j<6;$j++)
	{
		$counter = 0;
		for($i=0;$i<3;$i++)
		{		
			$fileName = "DIMM/LD_even_A1_t0" . ($i+1) . "_DIMM_" . $systemName . "_DIMM" . ($j+1) . "Temp.csv";
			open(FH, "<$fileName") or die "Unable to open $fileName!";
			foreach $tmpLine (<FH>)
			{
				chomp($tmpLine);
				$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
				push @{$csvLines[$counter]}, $7;
				$counter++;
			}
			close(FH);		
		}
		
		$counter = 0;
		for($i=0;$i<3;$i++)
		{		
			$fileName = "DIMM/LD_even_A1_t0" . ($i+1) . "_DIMM_" . $systemName . "_DIMM" . ($j+1) . "TempStatus.csv";
			open(FH, "<$fileName") or die "Unable to open $fileName!";
			foreach $tmpLine (<FH>)
			{
				chomp($tmpLine);
				$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
				push @{$csvLines[$counter]}, $7;
				$counter++;
			}
			close(FH);							
		}
	}
		
	$counter = 0;
	for($i=0;$i<3;$i++)
	{	
		$fileName = "DIMM/LD_even_A1_t0" . ($i+1) . "_DIMM_" . $systemName . "_QualityCode.csv";
		open(FH, "<$fileName") or die "Unable to open $fileName!";
		foreach $tmpLine (<FH>)
		{
			chomp($tmpLine);
			$tmpLine =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d\d).\d\d\d,(.+)/;
			push @{$csvLines[$counter]}, $7;
			$counter++;
		}
		close(FH);				
	}
	
	$fileName = "output/$systemName" . ".csv";
	
	open(OUTFH, ">$fileName") or die "Can't open output file!";
	for(my $idx = 0; $idx < scalar(@csvLines); $idx++)
	{
		print OUTFH $systemId . ",";
		for(my $idx2 = 0; $idx2 < scalar(@{$csvLines[$idx]} - 1); $idx2++)
		{
			print OUTFH $csvLines[$idx][$idx2] . ",";
		}
		print OUTFH$csvLines[$idx][scalar(@{$csvLines[$idx]})-1] . "\n";
	}
	close(OUTFH);
	
	$systemId++;
}   
