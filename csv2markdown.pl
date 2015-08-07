#!/usr/bin/perl
# Converts comma separated value tables (CSV files) into MarkDown tables. This
# is often useful in publishing on websites.
#
# This uses largely standard, plain-vanilla perl for portability and utility
# on older hardware.

use strict;

#use Getopt::Long;#?

my $padding = 2;
my $header  = 1;

my $infile = shift;

#my $padspace = ' ' x $padding;

open IN, "<$infile" or die "Can't open file $infile for reading.\n";

my @lines;
while(<IN>) {
  push @lines, $_;
}
close(IN);

# We want this to be double quote aware as well as comma aware.
# The handiest way to do that is to start with the double quotes.

my $outer_array = {}; # This will be an array of arrays. Line arrays pushed into here.
my $line_cnt = 0;
foreach my $line ( @lines ) {
  # Let's note the actual pairs before the split so we can find them,
  # even if they contain commas.
  my @quote_sets;
  foreach($line =~ /(".*?")/g){
    my $aa = $_;
    $aa =~ s/"//g;
    push @quote_sets, $aa;
  }
  print "size of quote_sets = ", scalar(@quote_sets), "\n";
  # Do the split.
  my @quote_array = split /"/, $line;
#####DEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUG
  print "For line $line_cnt, quote_array is:\n";
  map { print "==>$_<==\n"; } @quote_array;
  print "And quote_sets is:\n";
  map { print "\t==>$_<==\n"; } @quote_sets; print "\n";
#####DEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUG

  my @full_line_array;
  if( scalar(@quote_array) > 1) { # more than one element if quotes present
    # Just one quick thing: if there's only one double quote,
    # we're badly formed and should quit.
    if(scalar(@quote_sets) < 1) {
      die "Badly formed line with opening quote but no closing quote.\n" . $line;
    }
    # If there's a double quote at the start...
    # the first element will be empty.
    if($quote_array[0] eq '') {
      shift @quote_array; # toss the first element
    }
    # If there's a double quote at the end...
    # the last element will be empty.
    if($quote_array[-1] eq '') {
      pop @quote_array; # toss the last element
    }
    # Now all other positions.
    foreach my $chunk ( @quote_array ) {
#####DEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUG
      print "chunk = $chunk\n";
#####DEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUG
      my $chkcnt = 0;
      map { $chkcnt = 1 if $chunk eq $_; } @quote_sets;
      if($chkcnt) {
        push @full_line_array, $chunk;
      } else {
        my @subquote = split /,/, $chunk;
        map { push @full_line_array, $_; } @subquote;
      }
    }
  } else { # only one element after the quote split, so no quotes, so easy!
    @full_line_array = split /,/, $quote_array[0];
  }
#####DEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUG
  print "full_line_array = ";
  map {print "$_ ";} @full_line_array; print "\n";
#####DEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUG
  $outer_array->{"$line_cnt"} = \@full_line_array;
  $line_cnt++;
}

# Formatting Time!
# We need to know how many columns and how big they are.
#####DEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUG
#map { print $outer_array->{"$_"} }
print "outerarraything ", $outer_array->{"0"}, "\n";
print "outer array keys = ", keys %{$outer_array}, "\n";
print "outer array keys size = ", scalar(keys %{$outer_array}), "\n";
#####DEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUGDEBUG
my @colCnt;
for(my $i=0; $i < scalar(keys %{$outer_array}); $i++) {
  for(my $j=0; $j < scalar(@{$outer_array->{$i}})-1; $j++) {
    my $col_length = length($outer_array->{"$i"}->[$j]);
    print "i = $i, j= $j, col_length = $col_length\n";
    if($col_length > $colCnt[$j] || !defined $colCnt[$j]) {
      $colCnt[$j] = $col_length;
    }
  }
}

# Now we need to print out the lines. We need to start with the header, then
# print the header breaker line, then all subsequent lines. The printing
# of the content lines, header or otherwise, is fundamentally the same, so
# use a function to do that.
# Here's the header.
printLine($outer_array->{"0"}, \@colCnt, $padding);

#print "lines size is ", scalar(@lines), "\n";
#print "outer_array size is ", scalar(keys %{$outer_array}), "\n";
#print "colCnt size is ", scalar(@colCnt), "\n";
map { print "$_\n"; } @colCnt;

# Now the breaker line
print "colCnt0 = $colCnt[0] and padding = $padding\n";
print "-" x ($colCnt[0]+$padding);
map { print "|" . "-" x ($colCnt[$_]+2*$padding); } 1 .. scalar(@colCnt)-1;
print "\n";

# And the rest
for(my $i=1; $i < scalar(keys %{$outer_array}); $i++) {
  printLine($outer_array->{"$i"}, \@colCnt, $padding);
}

sub printLine {
  my $lineRef    = shift; # Array reference for the line contents
  my $colSizeRef = shift; # Array reference for the column sizes
  my $paddingNum = shift;

  #print "lineRef thing: $lineRef\n";
  #print "colSizeRef thing: ", $colSizeRef->[0], "\n";
  print "$lineRef->[0]" . " " x ($colSizeRef->[0]-length($lineRef->[0])) . " " x $paddingNum . "|";
  for( my $i=1; $i < scalar(@{$lineRef})-1; $i++) {
    print " " x $paddingNum;
    print "$lineRef->[$i]" . " " x ($colSizeRef->[$i]-length($lineRef->[$i]));

    if( $i < scalar(@{$lineRef})-2 ) {
      print " " x $paddingNum . "|";
    } else {
      print "\n";
    }
  }
}
