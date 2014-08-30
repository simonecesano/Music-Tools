#!/Users/cesansim/perl5/perlbrew/perls/perl-5.18.2/bin/perl

use File::Spec;
use strict;

my $file = $ARGV[0];
my %opt;

$\ = "\n";

if (-d $file) {
    opendir(my $dh, $file) || die "can't opendir $file: $!";
    my @mp3 = map {  "$file/$_" } grep { /\.mp3/ && -f "$file/$_"; } readdir($dh);
    closedir $dh;

    for (@mp3) {
	my $mp3 = File::Spec->rel2abs( $_ );
	print $mp3 if $opt{v};
	add_file($mp3);
    }
} else {
    $file = File::Spec->rel2abs( $file ) ;
    print $file if $opt{v};
    add_file($file);
}

sub add_file {
    my $file = shift;
    print qq/osascript -e 'tell application "iTunes" to add POSIX file "$file"'/ if $opt{v};
    print qx/osascript -e 'tell application "iTunes" to add POSIX file "$file"'/;
}
