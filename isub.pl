#!/usr/bin/env perl

use strict;
use warnings;
use Term::ANSIColor qw(:constants);
use Pod::Usage;
use Getopt::Long;

=head1 NAME

isub.pl - An interactive regex find/replace tool

=head1 SYNOPSIS

perl isub.pl [options] <pattern> <repl> <dir>

options:

  --help              Print this message and exit
  --doall             Perform all replacements without asking
  --filter <regex>    Only process filenames that match <regex>
=cut


# Parse command line
my $help;
my $filename_filter = ".";

GetOptions("help"     => \$help,
           "filter=s" => \$filename_filter;

my $extension;

pod2usage(1) if $help;
pod2usage(1) if @ARGV < 3;

##
#
# Main Program
#
##
my ($pattern, $repl, $dir) = @ARGV;
apply_transform_to_dir($pattern, $repl, $dir);


my %AutoReplace = ();


##
#
# For each file in given dir, delegates
# to apply_transform_to_file()
#
##
sub apply_transform_to_dir {
	my ($pattern, $repl, $dir) = @_;
    for my $file (`find -L $dir`) {
        chomp $file;
        next unless $file =~ m/$filename_filter/;
    	apply_transform_to_file($pattern, $repl, $file);
    }
}


##
#
# For each line in given file, delegates
# to apply_transform_to_line() for transform.
# Performs the file IO.
#
##
sub apply_transform_to_file {
	my ($pattern, $repl, $file) = @_;
    print "Process file \"$file\"? [Y|n]: ";
    chomp(my $answer = lc <STDIN>);
    return if $answer =~ m/^n$/;
	open(my $input_fh, '<', $file) or die "Could not open $file: $!\n";
	my $transformed_file = '';
	for my $line (<$input_fh>) {
        $transformed_file .= apply_transform_to_line($pattern, $repl, $line);
	}
    close($input_fh);
	open(my $output_fh, '>', $file) or die "Could not open $file: $!\n";
	print $output_fh $transformed_file;
	close($output_fh);
}


##
#
# If given line matches the pattern, entertains
# user with an interactive session, allowing them
# to apply or skip the transformation.
#
##
sub apply_transform_to_line {
	my ($pattern, $repl, $line) = @_;
	if ($line =~ m/($pattern)/) {
        my $match = $1;
        if (defined $AutoReplace{$1}) {
		    $line =~ s/$pattern/$repl/;
        } else {
        	my ($beg, $end) = ($-[0], $+[0]);
        	my $prebold  = substr($line, 0, $beg);
        	my $boldtext = substr($line, $beg, length $1);
        	my $postbold = substr($line, $end);
        	print "> ", $prebold,
                  BOLD, $boldtext,
                  RESET, $postbold, "\n";
        	print "Transform? [Y|all|n]: ";
	    	chomp(my $answer = lc <STDIN>);
	    	if ($answer eq '' || $answer eq 'y') {
		    	$line =~ s/$pattern/$repl/;
	    	}
			elsif ($answer eq 'all') {
		        $line =~ s/$pattern/$repl/;
                $AutoReplace{$match}++;
            }
		}
    }
    return $line;    
}
