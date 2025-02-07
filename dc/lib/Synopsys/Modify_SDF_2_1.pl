#!/cad/pub/bin/perl

die  "Usage: $0 input_file\n" if $#ARGV != 0;

$input = $ARGV[0];
open (IN, "$ARGV[0]") || die "Could not open file $ARGV[0]: $!\n" ;
open (OUT, ">temp") || die "Could not open file temp: $!\n" ;
$flag=0;
while (<IN>) {
      if (/(x\d+x)/) {
          s/x(\d+)x/\[$1\]/sg;
      }
	if( /^\s+\(CELLTYPE/ && /(FF|LAT)/ && /HD/) {
	$flag=1;
	}
	if($flag==1 && !/^\(CELL/ ) {
        s/\(COND shcheck\S+ === 1\'b1 (\(\S+edge \S+\))\)/$1/sg ;
        s/\(COND shcheck\S+ === 1\'b1 (\(\S+edge \S+\))\)/$1/sg ;
        s/IOPATH \(\S+edge (\S+)\)/IOPATH $1/sg ;
	print OUT;
	next;
	} else {
	$flag=0;
	print OUT;
	}
}
close(IN);
close(OUT);
$input_bak=$input.".bak";
system("mv $input $input_bak");
system("mv temp $input");
